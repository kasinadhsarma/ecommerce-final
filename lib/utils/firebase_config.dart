import 'package:flutter/foundation.dart';

class AppFirebaseConfig {
  static bool get isFirebaseEnabled => !kIsWeb;
}
