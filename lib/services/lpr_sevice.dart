import 'package:mlpr/consts/AppConfig.dart';
import 'package:http/http.dart' as http;

class LprService {
  final String baseUrl =
      AppConfig.LPR_BACKEND_URL; // Ensure this is defined in your .env file

  // Fetch LPR data
  Future<dynamic> fetchLprData(String imagePath) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/lpr'),
      body: {'image': imagePath},
    );
    return _processResponse(response);
  }

  // Search LPR data
  Future<dynamic> searchLprData(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/lpr/search?q=$query'),
    );
    return _processResponse(response);
  }

  // Send captured image for LPR processing
  Future<dynamic> sendCapturedImage(String imagePath) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/lpr/capture'),
      body: {'image': imagePath},
    );
    return _processResponse(response);
  }

  // Fetch paginated LPR data for the home page
  Future<dynamic> fetchPaginatedLprData(int page) async {
    final response = await http.get(Uri.parse('$baseUrl/api/lpr?page=$page'));
    return _processResponse(response);
  }

  // Process the HTTP response
  dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch LPR data: ${response.statusCode}');
    }
  }
}
