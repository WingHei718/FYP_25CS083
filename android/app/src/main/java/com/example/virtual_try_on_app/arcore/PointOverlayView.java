package com.example.virtual_try_on_app.arcore;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.view.View;

import java.util.ArrayList;
import java.util.List;

public class PointOverlayView extends View {
    private final Paint paint;
    private final List<float[]> points;
    private final Object lock = new Object();

    public PointOverlayView(Context context) {
        super(context);
        points = new ArrayList<>();
        paint = new Paint();
        paint.setColor(android.graphics.Color.BLUE);
        paint.setStyle(Paint.Style.FILL);
        paint.setAntiAlias(true);
    }
    
    public void replaceAll(List<float[]> batch) {
        synchronized (lock) {
            points.clear();
            points.addAll(batch);
        }
        postInvalidateOnAnimation();
    }

    public void clearPoints() {
        synchronized (lock) {
            points.clear();
        }
        postInvalidateOnAnimation();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        List<float[]> snapshot;
        synchronized (lock) {
            snapshot = new ArrayList<>(points);
        }
        for (float[] point : snapshot) {
            canvas.drawCircle(point[0], point[1], 10, paint);
        }
    }
}