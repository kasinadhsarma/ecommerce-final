# Getting Started Guide

This document provides instructions on how to set up, build, and run the e-commerce application.

## Prerequisites

Before you begin, ensure that you have the following installed:

1. **Flutter SDK**: Version 3.0.0 or higher
   - [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

2. **Dart SDK**: Version 3.0.0 or higher (included with Flutter SDK)

3. **Android Studio**: For Android development
   - [Android Studio Download](https://developer.android.com/studio)

4. **Visual Studio Code**: Recommended IDE for Flutter development
   - [VS Code Download](https://code.visualstudio.com/)
   - Install the Flutter and Dart extensions for VS Code

5. **Git**: For version control
   - [Git Download](https://git-scm.com/downloads)

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/ecommerce-final.git
cd ecommerce-final
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

The application uses Firebase for authentication, cloud storage, and messaging. You need to set up Firebase for both Android and web platforms:

#### For Android:

1. Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/)
2. Add an Android app to your Firebase project:
   - Use package name: `com.example.myapp` (or your custom app ID)
   - Download the `google-services.json` file
   - Place the file in the `android/app/` directory

#### For Web:

1. Add a Web app to your Firebase project
2. Copy the Firebase configuration values (apiKey, authDomain, etc.)
3. Update the Firebase options in `lib/main.dart` or `lib/firebase_options.dart`

### 4. Configure Stripe (for payments)

1. Create a Stripe account if you don't have one already
2. Obtain your Stripe publishable key and secret key
3. Update the Stripe keys in the application:
   - For web: Update in `lib/services/stripe_web_service.dart`
   - For mobile: Update in your backend service or secure storage

## Running the Application

### For Android:

1. Connect an Android device or start an emulator
2. Run the following command:

```bash
flutter run
```

### For Web:

```bash
flutter run -d chrome
```

## Building for Production

### Android APK:

```bash
flutter build apk
```

The built APK will be located at `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle:

```bash
flutter build appbundle
```

The built AAB will be located at `build/app/outputs/bundle/release/app-release.aab`

### Web:

```bash
flutter build web
```

The built web application will be located in the `build/web` directory.

## Project Structure Overview

Here's a brief overview of the project structure:

- `android/`: Android-specific code and configurations
- `assets/`: Static assets like images and icons
- `lib/`: Main Dart code
  - `main.dart`: Application entry point
  - `models/`: Data models
  - `providers/`: State management
  - `screens/`: UI screens
  - `services/`: External service integrations
  - `utils/`: Utility functions
  - `widgets/`: Reusable UI components
- `test/`: Test files
- `web/`: Web-specific code and configurations

## Development Workflow

1. **Feature Development**:
   - Create a new branch for each feature
   - Implement the feature with appropriate tests
   - Submit a pull request for review

2. **Testing**:
   - Run unit tests: `flutter test`
   - Run widget tests: `flutter test test/widget_test.dart`
   - Perform manual testing on both Android and web platforms

3. **Code Style**:
   - Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
   - Run `flutter analyze` to identify and fix potential issues

## Troubleshooting

### Common Issues:

1. **Build Failures**:
   - Ensure Flutter and Dart versions are up to date
   - Run `flutter clean` and try building again
   - Check for missing dependencies or configuration files

2. **Firebase Integration Issues**:
   - Verify that `google-services.json` is in the correct location
   - Check that Firebase configuration values are correctly set in the code
   - Ensure the package name matches your Firebase configuration

3. **Web Compilation Errors**:
   - Refer to `web_compilation_fix_guide.md` for solutions to web-specific compilation issues

4. **Plugin Compatibility**:
   - Ensure all plugins support your target platforms
   - Check the [Flutter Plugins](https://pub.dev/flutter/packages) for compatibility information

## Support

For questions or assistance, please contact:

- Project Maintainer: [maintainer@example.com](mailto:maintainer@example.com)
- Issue Tracker: [GitHub Issues](https://github.com/yourusername/ecommerce-final/issues)
