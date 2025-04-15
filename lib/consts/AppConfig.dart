import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final String LPR_BACKEND_URL =
      dotenv.env['LPR_BACKEND_URL'] ?? "http://localhost:8000";
}

// Usage example:
// final endpoint = AppConfig.LPR_BACKEND_URL;
