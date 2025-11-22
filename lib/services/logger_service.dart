import 'package:flutter/foundation.dart';

class LoggerService {
  static void info(String message) => debugPrint('[INFO] $message');
  static void warning(String message) => debugPrint('[WARN] $message');
  static void error(String message) => debugPrint('[ERROR] $message');
}
