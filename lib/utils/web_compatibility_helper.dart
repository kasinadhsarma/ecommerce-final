import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:js_util' as js_util;

/// Converts a JavaScript Promise (Thenable) to a Dart Future.
Future<T> handleThenable<T>(dynamic jsPromise) {
  return js_util.promiseToFuture<T>(jsPromise);
}

/// This class provides utility methods to check platform capabilities and
/// implement platform-specific behavior
class WebCompatibilityHelper {
  /// Check if the platform is web
  static bool get isWeb => kIsWeb;

  /// Check if the platform is mobile
  static bool get isMobile => !kIsWeb;

  /// Check if Firebase is available in the current environment
  static bool get isFirebaseAvailable =>
      true; // We've updated the setup to work on both web and mobile

  /// Check if local authentication is available in the current environment
  static bool get isLocalAuthAvailable => !kIsWeb;

  /// Firebase authentication helper
  static Future<void> initializeFirebase() async {
    // Implementation will be different based on platform
    if (isWeb) {
      // Web specific initialization is handled in index.html and main.dart
    } else {
      // Mobile specific initialization is handled in main.dart
    }
  }

  /// Biometric authentication shim for web
  static Future<bool> canAuthenticateWithBiometrics() async {
    if (isWeb) {
      // Web does not support biometrics, return false
      return false;
    } else {
      // In a real implementation, we would delegate to the actual biometric service
      return true;
    }
  }

  /// Notification permission shim for web
  static Future<bool> requestNotificationPermission() async {
    if (isWeb) {
      // Implement web-specific notification permission request
      return false; // Placeholder implementation
    } else {
      // Mobile-specific code would go here
      return true; // Placeholder implementation
    }
  }

  /// Platform-specific UI adjustments
  static EdgeInsets safePadding(BuildContext context) {
    if (isWeb) {
      // Custom padding for web
      return const EdgeInsets.all(8.0);
    } else {
      // Use MediaQuery for mobile
      return MediaQuery.of(context).padding;
    }
  }
}
