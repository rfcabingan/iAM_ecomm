import 'dart:convert';
import 'package:http/http.dart' as http;

/// Use this class for GET, POST, PUT, DELETE calls across your app.
class IAMHelperClient {
  //  Replace with iam actual API base URL or load from env/config file.
  static const String _baseUrl = 'https://api.yourdomain.com/v1';

  // Common headers for all requests (add tokens dynamically if needed)
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// --- GET Request ---
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      final response = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  /// --- POST Request ---
  static Future<Map<String, dynamic>> post(
    String endpoint,
    dynamic data,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      final response = await http
          .post(uri, headers: _defaultHeaders, body: json.encode(data))
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  /// --- PUT Request ---
  static Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      final response = await http
          .put(uri, headers: _defaultHeaders, body: json.encode(data))
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  /// --- DELETE Request ---
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      final response = await http
          .delete(uri, headers: _defaultHeaders)
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  /// --- Handle and Decode Response ---
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? json.decode(response.body) : {};

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else if (statusCode == 401) {
      throw Exception('Unauthorized: Please check your credentials.');
    } else if (statusCode == 403) {
      throw Exception('Forbidden: You do not have permission.');
    } else if (statusCode == 404) {
      throw Exception('Not Found: ${body['message'] ?? 'Endpoint not found.'}');
    } else if (statusCode >= 500) {
      throw Exception('Server Error: Please try again later.');
    } else {
      throw Exception('Unexpected error: $statusCode → ${response.body}');
    }
  }
}
