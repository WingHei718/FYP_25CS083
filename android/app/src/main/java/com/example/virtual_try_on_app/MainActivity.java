package com.example.virtual_try_on_app;

import androidx.annotation.NonNull;
import com.example.virtual_try_on_app.arcore.ARCoreManager;
import com.example.virtual_try_on_app.arcore.ARCoreView;
import com.example.virtual_try_on_app.arcore.ARCoreViewFactory;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example/arcore";
    private ARCoreManager arCoreManager;
    private ARCoreView arCoreView;
    private MethodChannel methodChannel;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        arCoreManager = ARCoreManager.getInstance();
        arCoreManager.setActivity(this);

    arCoreView = new ARCoreView(this);

        flutterEngine.getPlatformViewsController().getRegistry().registerViewFactory("arcore_view", new ARCoreViewFactory(this));

        methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        methodChannel.setMethodCallHandler(
            (call, result) -> {
                switch (call.method) {
                    case "startARSession":
                        arCoreManager.startARSession(result);
                        break;
                    case "closeARSession":
                        arCoreManager.closeARSession();
                        result.success("AR Session Closed");
                        break;
                    case "loadModel":
                        if (call.arguments instanceof Map) {
                            Map<String, Object> args = (Map<String, Object>) call.arguments;
                            String modelPath = (String) args.get("modelPath");
                            if (modelPath != null) {
                                arCoreView.loadModel(modelPath);
                                result.success("Model loading initiated");
                            } else {
                                result.error("INVALID_ARGS", "Invalid model path or position", null);
                            }
                        } else {
                            result.error("INVALID_ARGS", "Args must be a map", null);
                        }
                        break;

                    case "enableHandTracking":
                        arCoreView.enableHandTracking();
                        result.success("Hand tracking enabled");
                        break;

                    case "disableHandTracking":
                        arCoreView.disableHandTracking();
                        result.success("Hand tracking disabled");
                        break;

                    case "enableTestingMode":
                        arCoreView.enableTestingMode();
                        result.success("Testing mode enabled");
                        break;
                    
                    case "disableTestingMode":
                        arCoreView.disableTestingMode();
                        result.success("Testing mode disabled");
                        break;

                    case "setFinger":
                        if (call.arguments instanceof Map) {
                            Map<String, Object> args = (Map<String, Object>) call.arguments;
                            String finger = (String) args.get("finger");
                            if (finger != null) {
                                arCoreView.setFinger(finger);
                                result.success("Finger set to " + finger);
                            } else {
                                result.error("INVALID_ARGS", "Null finger name", null);
                            }
                        } else {
                            result.error("INVALID_ARGS", "Args must be a map", null);
                        }
                        break;

                    case "clearPoints":
                        arCoreView.clearPoints();
                        result.success("Hand Points cleared");
                        break;
                    default:
                        result.notImplemented();
                }
            }
        );
    }

    public ARCoreView getARcoreView() {
        return arCoreView;
    }

    public void setARcoreView(ARCoreView view) {
        this.arCoreView = view;
    }

    public void onPlaneDetected() {
        if (methodChannel != null) {
            runOnUiThread(() -> methodChannel.invokeMethod("planeDetected", null));
        }
    }

}