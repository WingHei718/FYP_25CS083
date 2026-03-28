# Keep ARCore classes
-keep class com.google.ar.** { *; }
-keep class com.google.ar.core.** { *; }
-keep class com.google.ar.sceneform.** { *; }

# Keep TensorFlow Lite classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }

# Keep Sceneform animation classes
-keep class com.google.ar.sceneform.animation.** { *; }
-keep class com.google.ar.sceneform.assets.** { *; }
-keep class com.google.ar.sceneform.rendering.** { *; }
-keep class com.google.ar.sceneform.utilities.** { *; }

# Keep desugar runtime classes
-keep class com.google.devtools.build.android.desugar.runtime.** { *; }

# Keep MediaPipe classes
-keep class com.google.mediapipe.** { *; }
-keep class com.google.protobuf.** { *; }

# Don't warn about missing classes
-dontwarn com.google.ar.sceneform.**
-dontwarn org.tensorflow.lite.**
-dontwarn com.google.mediapipe.**