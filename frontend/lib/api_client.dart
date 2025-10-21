// lib/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String base = 'http://localhost:8080';

  static Future<Map<String, dynamic>> signup(
    String email,
    String password,
  ) async {
    try {
      final url = Uri.parse('$base/signup');
      print('🔧 [ApiClient] Making signup request to: $url');
      print(
        '🔧 [ApiClient] Request data: email=$email, password=${'*' * password.length}',
      );

      final r = await http.post(
        url,
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'content-type': 'application/json'},
      );

      print('🔧 [ApiClient] Response status: ${r.statusCode}');
      print('🔧 [ApiClient] Response body: ${r.body}');

      return {'status': r.statusCode, 'body': jsonDecode(r.body)};
    } catch (e) {
      print('🔧 [ApiClient] Error during signup: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final url = Uri.parse('$base/login');
      print('🔧 [ApiClient] Making login request to: $url');

      final r = await http.post(
        url,
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'content-type': 'application/json'},
      );

      print('🔧 [ApiClient] Response status: ${r.statusCode}');
      print('🔧 [ApiClient] Response body: ${r.body}');

      return {'status': r.statusCode, 'body': jsonDecode(r.body)};
    } catch (e) {
      print('🔧 [ApiClient] Error during login: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final url = Uri.parse('$base/');
      print('🔧 [ApiClient] Testing connection to: $url');
      final r = await http.get(url).timeout(const Duration(seconds: 5));
      print('🔧 [ApiClient] Connection test response: ${r.statusCode}');
      return {'status': r.statusCode, 'body': jsonDecode(r.body)};
    } catch (e) {
      print('🔧 [ApiClient] Connection test failed: $e');
      rethrow;
    }
  }
}
