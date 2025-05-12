# Android Platform Documentation

This document provides detailed information about the Android-specific implementation of the e-commerce application.

## Directory Structure

The Android-specific code is located in the `android/` directory at the root of the project. This directory follows the standard Android project structure:

```
android/
├── app/
│   ├── build.gradle.kts
│   ├── google-services.json
│   └── src/
│       ├── debug/
│       ├── main/
│       │   ├── AndroidManifest.xml
│       │   ├── kotlin/
│       │   └── res/
│       └── profile/
├── build.gradle.kts
├── gradle.properties
├── local.properties
└── settings.gradle.kts
```

## Key Configuration Files

### build.gradle.kts (Project Level)

The top-level build file where you can add configuration options common to all sub-projects/modules.

Key configurations:
- Gradle version
- Repository sources
- Dependencies common to all modules

### app/build.gradle.kts (Module Level)

The app-level build file that contains Android-specific configurations.

Key configurations:
- Application ID: `com.example.myapp`
- Compile SDK version
- Min SDK version
- Target SDK version
- Firebase integration through Google services plugin
- Java 11 compatibility
- Core library desugaring for Java 8+ features

```kotlin
plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.myapp"
    compileSdk = flutter.compileSdkVersion
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }
    
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    
    defaultConfig {
        applicationId = "com.example.myapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }
}
```

### google-services.json

The Firebase configuration file containing API keys, client IDs, and other Firebase-specific settings. This file is essential for Firebase services like Authentication, Cloud Messaging, and Analytics.

### AndroidManifest.xml

Defines the application's package name, components, permissions, and features. 

Key configurations:
- Required permissions (internet, camera, etc.)
- Activity definitions
- Service definitions for Firebase services
- Deep link configurations
- Screen orientation settings

## Android-Specific Features

### Firebase Integration

The application utilizes Firebase services on Android:

```dart
// From main.dart
if (!kIsWeb) {
  // Mobile (Android) initialization
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
```

### Biometric Authentication

The app implements biometric authentication for Android using the `local_auth` package.

Key implementation details:
- Fingerprint authentication
- Face recognition (where supported)
- Fallback to device PIN/password

### Device Orientation Control

The application enforces portrait orientation on Android:

```dart
await SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
]);
```

### Local Notifications

Android notifications are implemented using the `flutter_local_notifications` package:

- Shopping cart reminders
- Order status updates
- Promotional notifications
- User account alerts

## Performance Considerations

### Multi-dex Support

Enabled to support large app size and numerous method references:

```kotlin
multiDexEnabled = true
```

### Image Optimization

The application implements:
- Cached image loading for product listings
- Progressive image loading for better user experience
- Proper image resolution management for different device densities

### Memory Management

- Efficient list rendering with lazy loading
- Background process management
- Resource cleanup when the app is in the background

## Testing on Android

### Emulator Testing

Instructions for testing on Android emulators:
1. Launch an emulator from Android Studio's AVD Manager
2. Run the application with `flutter run` or via IDE

### Physical Device Testing

Steps for testing on physical Android devices:
1. Enable USB debugging on the device
2. Connect the device via USB
3. Run the application with `flutter run` or via IDE

### Release Build Testing

Instructions for testing release builds:
1. Generate a release build with `flutter build apk`
2. Install the APK on a test device
3. Verify all functionality in release mode
