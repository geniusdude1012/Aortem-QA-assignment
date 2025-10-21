// lib/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8080'; // For Android emulator
  // Use 'http://127.0.0.1:8080' for iOS/web

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return {'status': res.statusCode, 'body': jsonDecode(res.body)};
    } catch (e) {
      print('❌ API Error: $e');
      return {
        'status': 500,
        'body': {'ok': false, 'message': 'Connection failed'},
      };
    }
  }

  static Future<Map<String, dynamic>> signup(
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return {'status': res.statusCode, 'body': jsonDecode(res.body)};
    } catch (e) {
      print('❌ API Error: $e');
      return {
        'status': 500,
        'body': {'ok': false, 'message': 'Connection failed'},
      };
    }
  }
}
