@JS()
library firebase_interop;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

// Export JS utility functions needed by firebase_auth_web
export 'package:js/js_util.dart' show promiseToFuture, dartify, jsify;

// Helper function for Promise handling
Future<T> handleThenable<T>(dynamic jsPromise) {
  return js_util.promiseToFuture<T>(jsPromise);
}
