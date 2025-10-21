// lib/server.dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'dart:io';

void main(List<String> args) async {
  final router = Router();

  // Root route
  router.get('/', (Request request) {
    return Response.ok(
      jsonEncode({'ok': true, 'message': '🚀 Backend running successfully!'}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Login route - ADD /v1
  router.post('/v1/login', (Request request) async {
    final body = await request.readAsString();
    print('📩 Login body: $body');

    // Parse the JSON to verify structure
    final jsonBody = jsonDecode(body);
    print('📧 Email: ${jsonBody['email']}');

    return Response.ok(
      jsonEncode({
        'ok': true,
        'token': 'abc123',
        'message': 'Login successful',
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Signup route - ADD /v1
  router.post('/v1/signup', (Request request) async {
    final body = await request.readAsString();
    print('📩 Signup body: $body');

    // Parse the JSON to verify structure
    final jsonBody = jsonDecode(body);
    print('📧 Email: ${jsonBody['email']}');

    return Response.ok(
      jsonEncode({'ok': true, 'message': 'Signup successful'}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Middleware
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('✅ Server running on port ${server.port}');
}
