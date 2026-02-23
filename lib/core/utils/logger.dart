import 'package:flutter/foundation.dart';

/// Simple debug-only logger utility.
void log(String message, {String tag = 'SnapKhata'}) {
  if (kDebugMode) {
    debugPrint('[$tag] $message');
  }
}
