// This file provides no-op implementations of JS interop functions for non-web platforms

/// Converts a Dart Future to a JS Promise (no-op on mobile)
Future<T> handleThenable<T>(dynamic _) {
  throw UnsupportedError('JS interop is not supported on this platform');
}

/// Convert a JavaScript object to a Dart object (no-op on mobile)
dynamic convertJsToDart(dynamic jsObject) {
  return jsObject;
}

/// Convert a Dart object to a JavaScript object (no-op on mobile)
dynamic convertDartToJs(dynamic dartObject) {
  return dartObject;
}

/// Call a JavaScript function with Dart arguments (no-op on mobile)
dynamic callJsMethod(dynamic _, String method, List<dynamic> args) {
  throw UnsupportedError('JS interop is not supported on this platform');
}

/// Get a property from a JavaScript object (no-op on mobile)
dynamic getProperty(dynamic _, String property) {
  throw UnsupportedError('JS interop is not supported on this platform');
}

/// Set a property on a JavaScript object (no-op on mobile)
void setProperty(dynamic _, String property, dynamic value) {
  throw UnsupportedError('JS interop is not supported on this platform');
}

/// Create a JavaScript function from a Dart function (no-op on mobile)
dynamic createJsFunction(Function dartFunction) {
  return dartFunction;
}
