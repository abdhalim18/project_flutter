import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static Future<void> load() => dotenv.load(fileName: '.env');

  /// URL backend POS (folder backend/, di-deploy ke Neon Functions).
  static String get apiBaseUrl => _require('API_BASE_URL');

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing $key. Copy .env.example to .env and fill in the backend URL.',
      );
    }
    return value;
  }
}
