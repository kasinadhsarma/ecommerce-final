# JavaScript Interoperability Guide

This document provides guidelines for using JavaScript interoperability in the Ecommerce app, particularly for web-specific functionality.

## Available Utilities

The app uses two main utility files for JavaScript interoperability:

1. `js_interop_utils.dart` - Contains utility functions for web platform
2. `no_op_js_interop.dart` - Provides no-op implementations for mobile platforms

## Importing the Utilities

Use conditional imports to ensure platform compatibility:

```dart
import 'utils/js_interop_utils.dart' if (dart.library.io) 'utils/no_op_js_interop.dart';
```

This ensures that:
- On web platforms: The actual JS interop implementations are used
- On mobile platforms: No-op implementations are used to prevent runtime errors

## Core Functions

The following utility functions are available:

### 1. Promise Handling

```dart
Future<T> handleThenable<T>(dynamic jsPromise)
```

Use this to convert JavaScript Promises to Dart Futures:

```dart
// Example
final jsPromise = callJsMethod(jsObject, 'someAsyncMethod', []);
final result = await handleThenable(jsPromise);
```

### 2. JavaScript-Dart Type Conversion

```dart
dynamic convertJsToDart(dynamic jsObject)
dynamic convertDartToJs(dynamic dartObject)
```

Use these to convert between JavaScript and Dart objects:

```dart
// Convert Dart Map to JavaScript object
final jsOptions = convertDartToJs({
  'key1': 'value1',
  'key2': 'value2'
});

// Convert JavaScript object to Dart
final dartResult = convertJsToDart(jsResponse);
```

### 3. JavaScript Method Calls

```dart
dynamic callJsMethod(dynamic jsObject, String method, List<dynamic> args)
```

Use this to call JavaScript methods:

```dart
// Example
final window = getProperty(js_util.globalThis, 'window');
final result = callJsMethod(window, 'open', ['https://example.com', '_blank']);
```

### 4. JavaScript Property Access

```dart
dynamic getProperty(dynamic jsObject, String property)
void setProperty(dynamic jsObject, String property, dynamic value)
```

Use these to access and set JavaScript properties:

```dart
// Example
final window = getProperty(js_util.globalThis, 'window');
final location = getProperty(window, 'location');
setProperty(location, 'href', 'https://example.com');
```

### 5. JavaScript Function Creation

```dart
dynamic createJsFunction(Function dartFunction)
```

Use this to create JavaScript functions from Dart functions:

```dart
// Example
final callback = createJsFunction((result) {
  print('Callback result: $result');
});

// Now `callback` can be passed to JavaScript APIs
callJsMethod(jsObject, 'methodThatExpectsCallback', [callback]);
```

## Best Practices

1. **Always wrap JS interop code in try-catch blocks**:
   ```dart
   try {
     // JS interop code here
   } catch (e) {
     debugPrint('JS interop error: $e');
   }
   ```

2. **Use platform checks before executing web-specific code**:
   ```dart
   if (kIsWeb) {
     // Web-specific code
   } else {
     // Mobile fallback
   }
   ```

3. **Provide fallbacks for mobile platforms**

4. **Keep JavaScript interactions isolated** in service classes

5. **Log detailed information** for debugging JS interop issues

## Common Use Cases

### Firebase Authentication

The Firebase Auth web SDK requires JavaScript interoperability for handling promises and auth objects.

### Payment Processing

Stripe and other payment gateways use JS SDKs on web platforms.

### Local Storage

Web applications use localStorage for persistent storage.

### Browser Navigation

Managing browser navigation and history requires JS interop.
