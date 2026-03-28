package com.example.virtual_try_on_app.mediapipe;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.SystemClock;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import com.google.mediapipe.framework.image.BitmapImageBuilder;
import com.google.mediapipe.framework.image.MPImage;
import com.google.mediapipe.tasks.core.BaseOptions;
import com.google.mediapipe.tasks.vision.core.RunningMode;
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker;
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult;
import com.google.mediapipe.tasks.components.containers.Landmark;
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark;
import com.google.mediapipe.tasks.components.containers.Category;

import com.example.virtual_try_on_app.utils.ImageUtils;

public class MediaPipeHandTracker implements AutoCloseable {

	public interface HandResultListener {
		void onHandLandmarks(List<NormalizedLandmark> normalizedLandmarks, List<Landmark> worldLandmarks, Category handedness);

	}

	private final ExecutorService executor = Executors.newSingleThreadExecutor();
	private final Object lock = new Object();
	private HandLandmarker handLandmarker;

	private final HandResultListener listener;
	private int frameIndex = 0;
	private volatile boolean closed = false;
	// Process every Nth frame
	private final int frameStep;

	public MediaPipeHandTracker(Context context, HandResultListener listener, int frameStep) {
		this.listener = listener;
		this.frameStep = Math.max(0, frameStep);
		init(context);
	}

	private void init(Context context) {
		try {
	        HandLandmarker.HandLandmarkerOptions options =
		        HandLandmarker.HandLandmarkerOptions.builder()
			        .setBaseOptions(
				        BaseOptions.builder()
					        .setModelAssetPath("flutter_assets/assets/MLModels/hand_landmarker/hand_landmarker.task")
					        .build())
    			    .setRunningMode(RunningMode.LIVE_STREAM)
	    		    .setNumHands(1)
					// Process frame with high confidence score
		    	    .setMinHandDetectionConfidence(0.8f)
			        .setMinHandPresenceConfidence(0.8f)
		    	    .setMinTrackingConfidence(0.8f)
		    	    .setResultListener(this::onResult)
			    .build();
			handLandmarker = HandLandmarker.createFromOptions(context, options);
		} catch (Exception e) {
			System.err.println("Error initializing Mediapipe: " + e.getMessage());
		}
	}

	public void processFrame(android.media.Image image) {
		if (closed || (frameIndex++ % (frameStep + 1)) != 0) {
			image.close();
			return;
		}
		final long timeStamp = SystemClock.uptimeMillis();
		executor.execute(() -> {
			try {
				if (closed || handLandmarker == null) return;
				Bitmap bmp = ImageUtils.yuvToBitmap(image);
				// Rotating image due toPortrait View
				bmp = ImageUtils.rotateBitmap(bmp, 90f);
				if (bmp == null) return;
				MPImage mpImage = new BitmapImageBuilder(bmp).build();
				handLandmarker.detectAsync(mpImage, timeStamp);
			} catch (Exception e) {
				System.err.println("Error processing frame (Mediapipe): " + e.getMessage());
			} finally {
				try { image.close(); } catch (Exception ignore) {}
			}
		});
	}

    // Process results & Pass to ARCore
	private void onResult(HandLandmarkerResult result, MPImage mpImage) {
		try {
			if (result == null) return;
			List<NormalizedLandmark> landmarksLocal2D = result.landmarks().get(0);
			List<Landmark> landmarksWorld3D = result.worldLandmarks().get(0);
			Category handedness = result.handedness().get(0).get(0);
			if (landmarksLocal2D == null || landmarksLocal2D.isEmpty() || landmarksWorld3D == null || landmarksWorld3D.isEmpty() || landmarksLocal2D.size() != landmarksWorld3D.size()) return;
			if (listener != null) {
				android.os.Handler main = new android.os.Handler(android.os.Looper.getMainLooper());
				main.post(() -> listener.onHandLandmarks(landmarksLocal2D, landmarksWorld3D, handedness));
			}
		} catch (Exception e) {
			System.err.println("Error processing results (Mediapipe): " + e.getMessage());
		}
	}

	public boolean isClosed() { return closed; }

	@Override
	public void close() {
		if (closed) return;
		closed = true;
		executor.shutdown();
		try {
			if (!executor.awaitTermination(200, TimeUnit.MILLISECONDS)) {
				executor.shutdownNow();
			}
		} catch (InterruptedException ie) {
			executor.shutdownNow();
			Thread.currentThread().interrupt();
		}
		// Close landmarker
		synchronized (lock) {
			try {
				if (handLandmarker != null) {
					handLandmarker.close();
				}
			} catch (Exception ignore) {}
			handLandmarker = null;
		}
	}
}
