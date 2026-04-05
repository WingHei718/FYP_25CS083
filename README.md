# FYP_25CS083

## Installation & Requirements

<ins>Android SDK:</ins>
Android 16.0, Android SDK Build-Tools 36.0.0

<ins>Check Installed Java:</ins>

Windows: Navigate to C:\Program Files\Java\ and C:\Program Files (x86)\Java\
Mac: type /usr/libexec/java_home -V in terminal

<ins>Please use one of the followings:</ins>
-  Oracle OpenJDK 22.0.2
-  Oracle OpenJDK 17.0.12
-  JetBrains Runtime 21.0.8

<ins>Select Java Version:</ins>

Android Studio: Settings -> Build, Execution, Deployment -> Build Tools -> Gradle -> Gradle JDK

VSCode: Add "java.configuration.runtimes" in the settings.json

<ins>Flutter (3.22.0)</ins>

You may download from the official cite directly: https://docs.flutter.dev/install/archive

For better sdk management, you may also use flutter sidekick: https://github.com/leoafarias/sidekick

Android Studio: Settings -> Languages & Frameworks -> flutter -> flutter SDK path

## Run & Build

You may try the application in demo/app-release.apk.

Android Studio (Please Choose one of the followings): 

1.  Build -> Flutter -> Build Apk
2.  Run Flutter Run "main.dart" in Release Mode
3.  Click Debug 'main.dart'

For the release mode, you may require a keystore.properties file inside the android folder
1.  Generate the jks file, e.g.keytool -genkey -v -keystore my-release-key.jks -alias alias_name -keyalg RSA -keysize 2048 -validity 10000
2.  Set up the file as followings:

```txt
storePassword=<password>
keyPassword=<password>
keyAlias=<alias_name>
storeFile=<path/to/keystore.jks>
```

## Notice
This project focuses on Android only and may not build successfully for IOS even with Flutter codes.

For more details related to versions, please nevigate to android/app/build.gradle.
