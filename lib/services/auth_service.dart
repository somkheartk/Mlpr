import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mlpr/consts/AppConfig.dart';

class AuthService {
  final _storage = FlutterSecureStorage();
  final String baseUrl =
      AppConfig.LPR_BACKEND_URL; // Ensure this is defined in your .env file

  // Fetch home screen data
  Future<dynamic> fetchHomeScreenData() async {
    String? token = await _storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/login',
      ), // Replace '/home' with the actual endpoint
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return _processResponse(response);
  }

  // Save data securely
  Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Read data securely
  Future<String?> readSecureData(String key) async {
    return await _storage.read(key: key);
  }

  // Delete secure data
  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  Future<dynamic> _processResponse(http.Response response) async {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
