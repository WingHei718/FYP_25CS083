package com.example.virtual_try_on_app.arcore;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.example.virtual_try_on_app.MainActivity;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

// Create ARView and Connect to Flutter
public class ARCoreViewFactory extends PlatformViewFactory {
    private final MainActivity mainActivity;

    public ARCoreViewFactory(MainActivity mainActivity) {
        super(StandardMessageCodec.INSTANCE);
        this.mainActivity = mainActivity;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        ARCoreView view = new ARCoreView(context);
        view.setPlaneDetectedCallback(mainActivity::onPlaneDetected);
        mainActivity.setARcoreView(view);
        return new ARCorePlatformView(context, view, mainActivity);
    }
}

class ARCorePlatformView implements PlatformView {
    private final ARCoreView view;
    private final FrameLayout container;
    private final MainActivity mainActivity;

    ARCorePlatformView(Context context, ARCoreView view, MainActivity mainActivity) {
        this.view = view;
        this.mainActivity = mainActivity;
        
        this.container = new FrameLayout(context);
        this.container.addView(view, 
            new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 
                ViewGroup.LayoutParams.MATCH_PARENT)
            );
        this.container.addView(view.getHandPointsOverlayView(), 
            new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 
                ViewGroup.LayoutParams.MATCH_PARENT)
            );
    }

    @Override
    public View getView() {
        return container;
    }

    @Override
    public void dispose() {
        view.destroyView();
        if (mainActivity.getARcoreView() == view) {
            mainActivity.setARcoreView(null);
        }
    }

    @Override
    public void onFlutterViewAttached(View flutterView) {
        view.post(() -> {view.resumeView();});
    }

    @Override
    public void onFlutterViewDetached() {
        view.pauseView();
    }
}