import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:js_util' as js_util;
import 'js_interop_utils.dart';

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
      try {
        // Implement web-specific notification permission request
        // This is a simplified example - real implementation would use the browser's Notification API
        final jsWindow = js_util.getProperty(js_util.globalThis, 'window');
        final hasNotification = js_util.hasProperty(jsWindow, 'Notification');
        
        if (hasNotification) {
          final permission = js_util.getProperty(
              js_util.getProperty(jsWindow, 'Notification'), 'permission');
          
          if (permission == 'granted') {
            return true;
          } else if (permission == 'denied') {
            return false;
          } else {
            // Request permission
            final result = await handleThenable(
                js_util.callMethod(
                    js_util.getProperty(jsWindow, 'Notification'), 
                    'requestPermission', 
                    []));
            return result == 'granted';
          }
        }
        return false;
      } catch (e) {
        debugPrint('Error requesting notification permission: $e');
        return false;
      }
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
  
  /// Local storage helper - uses different implementations for web vs. mobile
  static Future<bool> saveToLocalStorage(String key, dynamic value) async {
    if (isWeb) {
      try {
        // Web implementation using localStorage
        final jsWindow = js_util.getProperty(js_util.globalThis, 'window');
        final localStorage = js_util.getProperty(jsWindow, 'localStorage');
        
        // Convert value to JSON string
        final jsonString = value is String ? value : value.toString();
        
        // Save to localStorage
        js_util.callMethod(localStorage, 'setItem', [key, jsonString]);
        return true;
      } catch (e) {
        debugPrint('Error saving to localStorage: $e');
        return false;
      }
    } else {
      // Mobile implementation would use shared_preferences or other local storage
      // This is a placeholder
      return true;
    }
  }
  
  /// Get item from local storage
  static Future<String?> getFromLocalStorage(String key) async {
    if (isWeb) {
      try {
        // Web implementation using localStorage
        final jsWindow = js_util.getProperty(js_util.globalThis, 'window');
        final localStorage = js_util.getProperty(jsWindow, 'localStorage');
        
        // Get from localStorage
        final value = js_util.callMethod(localStorage, 'getItem', [key]);
        return value == null ? null : value.toString();
      } catch (e) {
        debugPrint('Error getting from localStorage: $e');
        return null;
      }
    } else {
      // Mobile implementation would use shared_preferences or other local storage
      // This is a placeholder
      return null;
    }
  }
  
  /// Remove item from local storage
  static Future<bool> removeFromLocalStorage(String key) async {
    if (isWeb) {
      try {
        // Web implementation using localStorage
        final jsWindow = js_util.getProperty(js_util.globalThis, 'window');
        final localStorage = js_util.getProperty(jsWindow, 'localStorage');
        
        // Remove from localStorage
        js_util.callMethod(localStorage, 'removeItem', [key]);
        return true;
      } catch (e) {
        debugPrint('Error removing from localStorage: $e');
        return false;
      }
    } else {
      // Mobile implementation would use shared_preferences or other local storage
      // This is a placeholder
      return true;
    }
  }
  
  /// Navigate to URL (useful for payment redirects in web)
  static void navigateToUrl(String url) {
    if (isWeb) {
      try {
        final jsWindow = js_util.getProperty(js_util.globalThis, 'window');
        js_util.callMethod(jsWindow, 'open', [url, '_blank']);
      } catch (e) {
        debugPrint('Error navigating to URL: $e');
      }
    } else {
      // Mobile implementation would use url_launcher or similar
      debugPrint('URL navigation on mobile not implemented');
    }
  }
}
}
