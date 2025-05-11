import 'package:flutter/foundation.dart';

/// This class provides utility methods to check platform capabilities
class WebCompatibilityHelper {
  /// Check if Firebase is available in the current environment
  static bool get isFirebaseAvailable => !kIsWeb;

  /// Check if local authentication is available in the current environment
  static bool get isLocalAuthAvailable => !kIsWeb;

  /// Check if the platform is web
  static bool get isWebPlatform => kIsWeb;
}
