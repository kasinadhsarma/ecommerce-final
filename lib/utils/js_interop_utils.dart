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

/// Convert a JavaScript object to a Dart object.
dynamic convertJsToDart(dynamic jsObject) {
  return js_util.dartify(jsObject);
}

/// Convert a Dart object to a JavaScript object.
dynamic convertDartToJs(dynamic dartObject) {
  return js_util.jsify(dartObject);
}

/// Call a JavaScript function with Dart arguments
dynamic callJsMethod(dynamic jsObject, String method, List<dynamic> args) {
  return js_util.callMethod(jsObject, method, args);
}

/// Get a property from a JavaScript object
dynamic getProperty(dynamic jsObject, String property) {
  return js_util.getProperty(jsObject, property);
}

/// Set a property on a JavaScript object
void setProperty(dynamic jsObject, String property, dynamic value) {
  js_util.setProperty(jsObject, property, value);
}

/// Create a JavaScript function from a Dart function.
/// This is useful for callback functions.
dynamic createJsFunction(Function dartFunction) {
  return js_util.allowInterop(dartFunction);
}
