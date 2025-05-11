import 'package:flutter/foundation.dart';
import 'dart:js_util' as js_util; // Using an alias for clarity

// These functions are often expected by Firebase web packages.
// The firebase_core_web package itself exports them from dart:js_util.
// Defining or re-exporting them here can sometimes help with resolution
// issues if older packages are not correctly finding them.

/// Converts a JavaScript Promise (Thenable) to a Dart Future.
Future<T> handleThenable<T>(dynamic thenable) {
  return js_util.promiseToFuture<T>(thenable);
}

/// Converts a JavaScript object to its Dart equivalent.
dynamic dartify(dynamic jsObject) {
  return js_util.dartify(jsObject);
}

/// This class provides utility methods to check platform capabilities
class WebCompatibilityHelper {
  /// Check if Firebase is available in the current environment
  static bool get isFirebaseAvailable => !kIsWeb;

  /// Check if local authentication is available in the current environment
  static bool get isLocalAuthAvailable => !kIsWeb;

  /// Check if the platform is web
  static bool get isWebPlatform => kIsWeb;
}
