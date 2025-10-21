// lib/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // For emulator use 10.0.2.2; for desktop/local use localhost
  static const String base = 'http://10.0.2.2:8080';

  static Future<Map<String, dynamic>> signup(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$base/v1/signup');
    final r = await http.post(
      url,
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'content-type': 'application/json'},
    );
    return {'status': r.statusCode, 'body': jsonDecode(r.body)};
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$base/v1/login');
    final r = await http.post(
      url,
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'content-type': 'application/json'},
    );
    return {'status': r.statusCode, 'body': jsonDecode(r.body)};
  }

  static Future<Map<String, dynamic>> secret(String token) async {
    final url = Uri.parse('$base/v1/secret');
    final r = await http.get(url, headers: {'authorization': 'Bearer $token'});
    return {'status': r.statusCode, 'body': jsonDecode(r.body)};
  }
}
