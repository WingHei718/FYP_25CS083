package com.example.virtual_try_on_app.utils;

import com.google.ar.sceneform.math.Vector3;
import com.google.mediapipe.tasks.components.containers.Landmark;

public class VectorUtils {
    
    public static Vector3 getNormalVector(Vector3 a, Vector3 b){
        return Vector3.cross(a, b).normalized();
    }
    
    public static Vector3 getLandmarkVector(Landmark p1, Landmark p2) {
        // Calculate vector from p1 to p2
        // Flip Y to match ARCore camera space (Y up)
        // Mediapipe Y: Down->Positive, Up->Negative
        // Mediapipe Z: Forward->Positive, Back->Negative
        float dx = p2.x() - p1.x();
        float dy = p2.y() - p1.y();
        float dz = p2.z() - p1.z();
        return new Vector3(dx, -dy, -dz).normalized();
    }
}
