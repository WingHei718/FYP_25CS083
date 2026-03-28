package com.example.virtual_try_on_app.arcore;

import android.app.Activity;
import com.google.ar.core.ArCoreApk;
import com.google.ar.core.ArCoreApk.Availability;
import com.google.ar.core.Session;
import com.google.ar.core.Config;
import com.google.ar.core.exceptions.CameraNotAvailableException;
import com.google.ar.core.exceptions.UnavailableApkTooOldException;
import com.google.ar.core.exceptions.UnavailableArcoreNotInstalledException;
import com.google.ar.core.exceptions.UnavailableDeviceNotCompatibleException;
import com.google.ar.core.exceptions.UnavailableSdkTooOldException;
import com.google.ar.core.exceptions.UnavailableUserDeclinedInstallationException;
import com.google.ar.core.exceptions.UnsupportedConfigurationException;
import io.flutter.plugin.common.MethodChannel;
import java.util.List;
import com.google.ar.core.CameraConfig;

public class ARCoreManager {
    private static ARCoreManager instance;
    private Session arSession;
    private Activity activity;
    private boolean installRequested;
    private boolean isTestingMode = false;
    private String targetFinger = "ring";

    public boolean isTestingMode() {
        return isTestingMode;
    }

    public void setTestingMode(boolean testingMode) {
        isTestingMode = testingMode;
    }

    public String getTargetFinger() {
        return targetFinger;
    }

    public void setTargetFinger(String targetFinger) {
        this.targetFinger = targetFinger;
    }

    public static ARCoreManager getInstance() {
        if (instance == null) {
            instance = new ARCoreManager();
        }
        return instance;
    }

    private ARCoreManager() {}

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    public Session getSession() {
        return arSession;
    }

    public void startARSession(MethodChannel.Result result) {
        try {
            if (arSession != null) {
                arSession.close();
                arSession = null;
            }

            Availability availability = ArCoreApk.getInstance().checkAvailability(activity);

            if (availability != Availability.SUPPORTED_INSTALLED) {
                switch (ArCoreApk.getInstance().requestInstall(activity, !installRequested)) {
                    case INSTALL_REQUESTED:
                        installRequested = true;
                        result.error("ARCORE_NOT_SUPPORTED", "Device does not support ARCore", null);
                        return;
                    case INSTALLED:
                        break;
                }
            }

            arSession = new Session(activity);
            Config config = new Config(arSession);
            config.setUpdateMode(Config.UpdateMode.LATEST_CAMERA_IMAGE);
            config.setFocusMode(Config.FocusMode.AUTO);

            config.setPlaneFindingMode(Config.PlaneFindingMode.HORIZONTAL_AND_VERTICAL);
            config.setLightEstimationMode(Config.LightEstimationMode.AMBIENT_INTENSITY);

            // Depth Mode
            if (arSession.isDepthModeSupported(Config.DepthMode.AUTOMATIC)) {
                config.setDepthMode(Config.DepthMode.AUTOMATIC);
            } else {
                config.setDepthMode(Config.DepthMode.DISABLED);
            }

            config.setInstantPlacementMode(Config.InstantPlacementMode.LOCAL_Y_UP);

            // Set Camera Resolution
            List<CameraConfig> cameraConfigs = arSession.getSupportedCameraConfigs();
            if (!cameraConfigs.isEmpty()) {
                CameraConfig selectedConfig = cameraConfigs.get(0);
                for (CameraConfig cameraConfig : cameraConfigs) {
                    // Set to higher resolution
                    if (cameraConfig.getImageSize().getWidth() >= 1280 && cameraConfig.getImageSize().getHeight() >= 720) {
                        selectedConfig = cameraConfig;
                        break;
                    }
                }
                System.out.println("Selected camera config: " + selectedConfig.getImageSize().getWidth() + "x" + selectedConfig.getImageSize().getHeight());
                arSession.setCameraConfig(selectedConfig);
            }
            arSession.configure(config);
            arSession.resume();
            result.success("AR Session Started");
        } catch (UnavailableArcoreNotInstalledException e) {
            result.error("ARCORE_NOT_INSTALLED", "ARCore is not installed", e.getMessage());
        } catch (UnavailableDeviceNotCompatibleException e) {
            result.error("DEVICE_NOT_COMPATIBLE", "Device is not compatible with ARCore", e.getMessage());
        } catch (UnavailableSdkTooOldException e) {
            result.error("SDK_TOO_OLD", "ARCore SDK is too old", e.getMessage());
        } catch (UnavailableApkTooOldException e) {
            result.error("APK_TOO_OLD", "ARCore APK is too old", e.getMessage());
        } catch (UnavailableUserDeclinedInstallationException e) {
            result.error("USER_DECLINED", "User declined ARCore installation", e.getMessage());
        } catch (CameraNotAvailableException e) {
            result.error("CAMERA_NOT_AVAILABLE", "Camera is not available", e.getMessage());
        } catch (UnsupportedConfigurationException e) {
            result.error("UNSUPPPORTED_CONFIGURATION", "Unsupported Configuration", e.getMessage());
        } catch (Exception e) {
            result.error("UNKNOWN_ERROR", "Failed to start AR session", e.getMessage());
        }
    }

    public void closeARSession() {
        if (arSession != null) {
            arSession.close();
            arSession = null;
        }
    }
}