package com.example.virtual_try_on_app.arcore;


import android.content.Context;
import android.net.Uri;
import android.view.MotionEvent;
import android.view.ViewGroup;

import java.util.List;
import java.util.concurrent.CompletableFuture;

import com.google.ar.core.Anchor;
import com.google.ar.core.Camera;
import com.google.ar.core.Frame;
import com.google.ar.core.TrackingState;
import com.google.ar.core.Session;
import com.google.ar.core.HitResult;
import com.google.ar.core.Pose;
import com.google.ar.core.Plane;
import com.google.ar.core.Config;
import com.example.virtual_try_on_app.MainActivity;
import com.google.ar.core.exceptions.CameraNotAvailableException;
import com.google.ar.sceneform.ArSceneView;
import com.google.ar.sceneform.AnchorNode;
import com.google.ar.sceneform.HitTestResult;
import com.google.ar.sceneform.FrameTime;
import com.google.ar.sceneform.Scene;
import com.google.ar.sceneform.math.Vector3;
import com.google.ar.sceneform.math.Quaternion;
import com.google.ar.sceneform.rendering.ModelRenderable;
import com.google.ar.sceneform.rendering.PlaneRenderer;
import com.google.ar.sceneform.assets.RenderableSource;
import com.google.ar.sceneform.ux.TransformationSystem;
import com.google.ar.sceneform.ux.TransformableNode;
import com.google.ar.sceneform.ux.FootprintSelectionVisualizer;

import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmark;
import com.google.mediapipe.tasks.components.containers.Landmark;
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark;
import com.google.mediapipe.tasks.components.containers.Category;

import com.example.virtual_try_on_app.mediapipe.MediaPipeHandTracker;
import com.example.virtual_try_on_app.utils.VectorUtils;

public class ARCoreView extends ArSceneView {
    private Session session;
    private TransformableNode modelNode;
    private final PointOverlayView pointOverlayView;
    private Anchor anchor;
    private AnchorNode anchorNode;
    private final TransformationSystem transformationSystem;
    private MediaPipeHandTracker mediaPipeHandTracker;
    private boolean testingMode = false;
    private boolean isPlaneDetected = false;
    private Runnable planeDetectedCallback;

    public ARCoreView(Context context) {
        super(context);
        // Restore state
        this.testingMode = ARCoreManager.getInstance().isTestingMode();
        this.targetFinger = ARCoreManager.getInstance().getTargetFinger();

        pointOverlayView = new PointOverlayView(context);
        
        // For gesture handling by ARCore Sceneform
        transformationSystem = new TransformationSystem(getResources().getDisplayMetrics(), new FootprintSelectionVisualizer());
        getScene().addOnPeekTouchListener(new Scene.OnPeekTouchListener() {
            @Override
            public void onPeekTouch(HitTestResult hitTestResult, MotionEvent motionEvent) {
                transformationSystem.onTouch(hitTestResult, motionEvent);
            }
        });

        getScene().addOnUpdateListener(this::onFrameUpdate);

        mediaPipeHandTracker = new MediaPipeHandTracker(context, this::updateRingTransformation, 2);

        // Disable plane rendering if needed
        getPlaneRenderer().setEnabled(testingMode);
    }

    public void setPlaneDetectedCallback(Runnable callback) {
        this.planeDetectedCallback = callback;
    }
    
    public PointOverlayView getPointOverlayView() {
        return pointOverlayView;
    }

    private void bindSession(Session session) {
        try {
            super.setupSession(session);
            System.out.println("Session bound to ArSceneView successfully");
        } catch (Exception e) {
            System.err.println("Error binding session to ArSceneView: " + e.getMessage());
            e.printStackTrace();
        }
    }
    public void resumeView() {
        try {
            session = ARCoreManager.getInstance().getSession();
            if (session != null) {
                bindSession(session);
                resume();
                post(() -> {
                    try {
                        if (session != null) {
                            session.resume();
                        }
                    } catch (CameraNotAvailableException e) {
                        System.err.println("Camera is not available during post-resume: " + e.getMessage());
                        postDelayed(() -> {
                            try {
                                if (session != null) {
                                    session.resume();
                                }
                            } catch (CameraNotAvailableException retryE) {
                                System.err.println("Camera still not available after retry: " + retryE.getMessage());
                            }
                        }, 100);
                    } catch (Exception e) {
                        System.err.println("Error during post-resume: " + e.getMessage());
                    }
                });
            } else {
                System.err.println("Session is null in resumeView");
                resume();
            }
        } catch (CameraNotAvailableException e) {
            System.err.println("Camera not available: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error resuming view: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void pauseView() {
        pause();
        if (session != null) {
            try {
                session.pause();
            } catch (Exception e) {
                System.err.println("Error pausing session: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }

    public void destroyView() {
        try {
            // Remove listeners & Clear scene
            getScene().removeOnUpdateListener(this::onFrameUpdate);

            if (anchorNode != null) {
                anchorNode.setParent(null);
                anchorNode = null;
            }

            modelNode = null;
            if (mediaPipeHandTracker != null) {
                mediaPipeHandTracker.close();
                mediaPipeHandTracker = null;
            }

            // Pause & destroy the ArSceneView
            pause();
            destroy();
        } catch (Exception e) {
            System.err.println("Error destroying ARCoreView: " + e.getMessage());
            e.printStackTrace();
        }
    }
    public Quaternion getCameraQuaternion() {
        Frame frame = getArFrame();
        if (frame == null) {
            return Quaternion.identity();
        }
        Pose cameraPose = frame.getCamera().getPose();
        float[] cameraRotationArray = cameraPose.getRotationQuaternion();
        Quaternion cameraRotation = new Quaternion(cameraRotationArray[0], cameraRotationArray[1], cameraRotationArray[2], cameraRotationArray[3]);
        return cameraRotation.normalized();
    }

    private void onFrameUpdate(FrameTime frameTime) {
        if (!isPlaneDetected) {
            Frame frame = getArFrame();
            if (frame != null && session != null) {
                for (Plane plane : session.getAllTrackables(Plane.class)) {
                    if (plane.getTrackingState() == TrackingState.TRACKING) {
                        isPlaneDetected = true;
                        if (planeDetectedCallback != null) {
                            planeDetectedCallback.run();
                        }
                        if (getContext() instanceof MainActivity) {
                            ((MainActivity) getContext()).onPlaneDetected();
                        }
                        break;
                    }
                }
            }
        }

        if (handTrackingEnabled && mediaPipeHandTracker != null) {
            Frame frame = getArFrame();
            if (frame != null) {
                try {
                    Camera camera = frame.getCamera();
                    if (camera.getTrackingState() == TrackingState.TRACKING) {
                        android.media.Image image = frame.acquireCameraImage();
                        if (handTrackingEnabled && mediaPipeHandTracker != null && !mediaPipeHandTracker.isClosed()) {
                            mediaPipeHandTracker.processFrame(image);
                        } else {
                            image.close();
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Error processing frame: " + e.getMessage());
                }
            }
        }
    }

    private void updateAnchor(float x, float y) {
        Frame frame = getArFrame();
        if (frame == null) {
            return;
        }

        boolean anchorCreated = false;
        try {
            List<HitResult> hitResults = frame.hitTest(x, y);
            if (hitResults != null && !hitResults.isEmpty()) {
                anchor = hitResults.get(0).createAnchor();
                anchorCreated = true;
            }
        } catch (Exception e) {
            System.err.println("Depth hit test failed: " + e.getMessage());
        }

        if (!anchorCreated) {
            try {
                // Set a short & reasonable distance
                float approximateDistance = 0.3f;
                List<HitResult> hit = frame.hitTestInstantPlacement(x, y, approximateDistance);
                if (hit != null && !hit.isEmpty()) {
                    anchor = hit.get(0).createAnchor();
                } else {
                    Pose cameraPose = frame.getCamera().getPose();
                    Pose objectPose = cameraPose.compose(Pose.makeTranslation(0, 0, -approximateDistance));
                    anchor = session.createAnchor(objectPose);
                }
            } catch (Exception e) {
                System.err.println("Depth hit test failed: " + e.getMessage());
                return;
            }
        }

        if (anchorNode == null) {
            anchorNode = new AnchorNode(anchor);
        } else  {
            anchorNode.setAnchor(anchor);
        }
        anchorNode.setParent(getScene());
    }

    public void loadModel(String modelPath) {
        String assetPath = "flutter_assets/" + modelPath;
        updateAnchor(getWidth() / 2, getHeight() / 2);
        // Some blender models are too large
        float defaultScale = 0.02f;
        CompletableFuture<ModelRenderable> modelFuture =
                ModelRenderable.builder().setSource(
                        getContext(), RenderableSource.builder().setSource(
                                getContext(), Uri.parse(assetPath), RenderableSource.SourceType.GLB)
                                        .setRecenterMode(RenderableSource.RecenterMode.NONE).setScale((float) defaultScale).build())
                        .build();

        modelFuture.thenAccept(renderable -> {
            if (renderable == null) {
                System.out.println("Fail to load 3D Model");
                return;
            }
            if (modelNode == null) {
                modelNode = new TransformableNode(transformationSystem);
                modelNode.getTranslationController().setEnabled(true);
                modelNode.getRotationController().setEnabled(true);
                modelNode.getScaleController().setEnabled(true);
                modelNode.setLocalScale(new Vector3(defaultScale, defaultScale, defaultScale));
                modelNode.getScaleController().setMinScale(defaultScale*0.5f);
                modelNode.getScaleController().setMaxScale(defaultScale*5f);
                modelNode.getScaleController().setSensitivity(0.3f);
            }
            modelNode.setParent(anchorNode);
            //Disable shadow of the model
            renderable.setShadowReceiver(false);
            renderable.setShadowCaster(false);
            modelNode.setRenderable(renderable);
            if (renderable.getCollisionShape() != null) {
                modelNode.setCollisionShape(renderable.getCollisionShape());
            }
            if (anchor != null) {
                // Initialize the view of the model through rotations
                Quaternion cameraRotation = getCameraQuaternion();
                Vector3 localZ = Quaternion.rotateVector(cameraRotation, Vector3.forward());
                Quaternion rotZ = Quaternion.axisAngle(localZ, -90f);
                Quaternion finalRotation = Quaternion.multiply(rotZ, cameraRotation);

                Vector3 localX = Quaternion.rotateVector(finalRotation, Vector3.right());
                Quaternion rotX = Quaternion.axisAngle(localX, 90f);
                finalRotation = Quaternion.multiply(rotX, finalRotation);

                modelNode.setWorldRotation(finalRotation);
                modelNode.setWorldPosition(new Vector3(anchor.getPose().tx(), anchor.getPose().ty(), anchor.getPose().tz()));
            }
        });
    }

    public Vector3 getCameraForward() {
        Frame frame = getArFrame();
        if (frame == null) {
            return Vector3.forward();
        }
        Pose cameraPose = frame.getCamera().getPose();
        float[] zAxis = cameraPose.getZAxis();
        // -Z is camera forward
        return new Vector3(-zAxis[0], -zAxis[1], -zAxis[2]).normalized();
    }

    public void drawhand(List<NormalizedLandmark> landmarks) {
        float viewWidth = getWidth();
        float viewHeight = getHeight();
        List<float[]> batch = new java.util.ArrayList<>(landmarks.size()+1);
        for (int i = 0; i < landmarks.size(); i++) {
            float x = landmarks.get(i).x() * viewWidth;
            float y = landmarks.get(i).y() * viewHeight;
            batch.add(new float[]{x, y});
        }
        pointOverlayView.replaceAll(batch);
    }

    private String targetFinger = "ring";

    public void setFinger(String finger) {
        this.targetFinger = finger;
        ARCoreManager.getInstance().setTargetFinger(finger);
    }

    private int[] mapFingerKeypointsIndex() {
        int mcp, pip, dip;
        switch (targetFinger.toLowerCase()) {
            case "thumb":
                mcp = HandLandmark.THUMB_MCP;
                pip = HandLandmark.THUMB_IP;
                dip = HandLandmark.THUMB_TIP;
                break;
            case "index":
                mcp = HandLandmark.INDEX_FINGER_MCP;
                pip = HandLandmark.INDEX_FINGER_PIP;
                dip = HandLandmark.INDEX_FINGER_DIP;
                break;
            case "middle":
                mcp = HandLandmark.MIDDLE_FINGER_MCP;
                pip = HandLandmark.MIDDLE_FINGER_PIP;
                dip = HandLandmark.MIDDLE_FINGER_DIP;
                break;
            case "pinky":
                mcp = HandLandmark.PINKY_MCP;
                pip = HandLandmark.PINKY_PIP;
                dip = HandLandmark.PINKY_DIP;
                break;
            case "ring":
            default:
                mcp = HandLandmark.RING_FINGER_MCP;
                pip = HandLandmark.RING_FINGER_PIP;
                dip = HandLandmark.RING_FINGER_DIP;
                break;
        }
        return new int[]{mcp, pip, dip};
    }

    public void updateRingTransformation(List<NormalizedLandmark> normalizedLandmarks, List<Landmark> worldLandmarks, Category handedness) {
        if (!handTrackingEnabled) {
            return;
        }
        if (testingMode) {
            drawhand(normalizedLandmarks);
        }
        // For Thumb: using MCP, IP, TIP
        // For Other Fingers: using MCP, PIP, DIP
        int[] indices = mapFingerKeypointsIndex();
        int mcp = indices[0];
        int pip = indices[1];
        int dip = indices[2];

        NormalizedLandmark mcpLandmark2D = normalizedLandmarks.get(mcp);
        NormalizedLandmark pipLandmark2D = normalizedLandmarks.get(pip);
        Landmark mcpLandmark = worldLandmarks.get(mcp);
        Landmark pipLandmark = worldLandmarks.get(pip);
        float viewWidth = getWidth();
        float viewHeight = getHeight();
        float targetx = (mcpLandmark2D.x() + pipLandmark2D.x()) / 2 * viewWidth;
        float targety = (mcpLandmark2D.y() + pipLandmark2D.y()) / 2 * viewHeight;

        updateAnchor(targetx, targety);
        if (modelNode != null && anchor != null) {
            modelNode.setWorldPosition(new Vector3(anchor.getPose().tx(), anchor.getPose().ty(), anchor.getPose().tz()));
            Quaternion cameraRot = getCameraQuaternion();

            // Check front / back of hand
            Landmark wrist = worldLandmarks.get(HandLandmark.WRIST);
            Landmark indexMcp = worldLandmarks.get(HandLandmark.INDEX_FINGER_MCP);
            Landmark pinkyMcp = worldLandmarks.get(HandLandmark.PINKY_MCP);

            Vector3 palmNormal;
            if (handedness.categoryName().equals("Right")) {
                palmNormal = VectorUtils.getNormalVector(
                    VectorUtils.getLandmarkVector(wrist, indexMcp),
                    VectorUtils.getLandmarkVector(wrist, pinkyMcp)
                );
            } else {
                palmNormal = VectorUtils.getNormalVector(
                    VectorUtils.getLandmarkVector(wrist, pinkyMcp),
                    VectorUtils.getLandmarkVector(wrist, indexMcp)
                );
            }

            Vector3 worldPalmNormal = Quaternion.rotateVector(cameraRot, palmNormal);
            Vector3 cameraForward = getCameraForward();
            float dot = Vector3.dot(worldPalmNormal, cameraForward);
            boolean isPalm = dot < 0;

            // From Base to Tip
            Vector3 fingerDir = VectorUtils.getLandmarkVector(pipLandmark, mcpLandmark);
            // Transform to world space
            Vector3 worldFingerDir = Quaternion.rotateVector(cameraRot, fingerDir);

            Landmark targetDip = worldLandmarks.get(dip);
            Landmark targetPip = worldLandmarks.get(pip);
            Landmark targetMcp = worldLandmarks.get(mcp);

            Vector3 fingerXDir;

            if (isPalm) {
                fingerXDir = VectorUtils.getNormalVector(
                        VectorUtils.getLandmarkVector(targetPip, targetDip),
                        VectorUtils.getLandmarkVector(targetPip, targetMcp)
                );
            } else {
                fingerXDir = VectorUtils.getNormalVector(
                        VectorUtils.getLandmarkVector(targetPip, targetMcp),
                        VectorUtils.getLandmarkVector(targetPip, targetDip)
                );
            }
            // Different anatomical orientation for thumb
            if (targetFinger.equals("thumb")) {
                fingerXDir = fingerXDir.negated();
            }

            Vector3 worldFingerXDir = Quaternion.rotateVector(cameraRot, fingerXDir);

            // When wearing the ring, the finger should passes from -Z to +Z in Blender
            Quaternion finalRotation = Quaternion.axisAngle(Vector3.right(), 180f);

            // Align model's local Z to finger
            finalRotation = Quaternion.multiply(Quaternion.lookRotation(worldFingerDir, worldFingerXDir), finalRotation).normalized();

            // Adjust rotation according to orientation of hand
            Vector3 localY = Quaternion.rotateVector(finalRotation, Vector3.up());
            Quaternion rotY;
            if (isPalm) {
                rotY = Quaternion.axisAngle(localY, 90f);
            } else {
                rotY = Quaternion.axisAngle(localY, -90f);
            }
            finalRotation = Quaternion.multiply(rotY, finalRotation);

            modelNode.setWorldRotation(finalRotation);
        }
    }


    public void clearPoints() {
        pointOverlayView.clearPoints();
    }

    private boolean handTrackingEnabled = true;

    public void enableHandTracking() {
        handTrackingEnabled = true;
        if (mediaPipeHandTracker == null) {
            try {
                mediaPipeHandTracker = new MediaPipeHandTracker(getContext(), this::updateRingTransformation, 2);
            } catch (Exception e) {
                System.err.println("Failed to enable hand tracking: " + e.getMessage());
                handTrackingEnabled = false;
            }
        }
    }

    public void disableHandTracking() {
        handTrackingEnabled = false;
        pointOverlayView.clearPoints();
        if (mediaPipeHandTracker != null) {
            try {
                mediaPipeHandTracker.close();
            } catch (Exception e) {System.out.println(e);}
            mediaPipeHandTracker = null;
        }
    }

    public void enableTestingMode() {
        testingMode = true;
        ARCoreManager.getInstance().setTestingMode(true);
        PlaneRenderer planeRenderer = getPlaneRenderer();
        if (planeRenderer != null) {
            planeRenderer.setEnabled(true);
        }
    }

    public void disableTestingMode() {
        testingMode = false;
        ARCoreManager.getInstance().setTestingMode(false);
        pointOverlayView.clearPoints();
        PlaneRenderer planeRenderer = getPlaneRenderer();
        if (planeRenderer != null) {
            planeRenderer.setEnabled(false);
        }
    }
}