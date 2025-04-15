import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mlpr/consts/AppConfig.dart';
import 'package:mlpr/routes/app_routes.dart';

class CarService {
  final String baseUrl =
      AppConfig.LPR_BACKEND_URL; // Ensure this is defined in your .env file

  Future<Map<String, dynamic>> fetchCarData(int page, int pageSize) async {
    final url = Uri.parse('$baseUrl/api/Lpr?page=$page&pageSize=$pageSize');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      return decodedData is Map ? Map<String, dynamic>.from(decodedData) : {};
    } else {
      throw Exception('Failed to fetch car data');
    }
  }
}
