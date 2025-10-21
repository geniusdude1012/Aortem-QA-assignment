// lib/server.dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'dart:io';

// Simple in-memory user storage
final List<Map<String, String>> _users = [];

void main(List<String> args) async {
  final router = Router();

  // Root route - for testing connection
  router.get('/', (Request request) {
    print('Root endpoint hit');
    return Response.ok(
      jsonEncode({
        'ok': true,
        'message': 'Backend running successfully!',
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    );
  });

  // Login route - UPDATED: Don't show password in logs
  router.post('/login', (Request request) async {
    print('Login endpoint hit');
    final body = await request.readAsString();

    try {
      final jsonBody = jsonDecode(body);
      final email = jsonBody['email']?.toString() ?? '';
      final password = jsonBody['password']?.toString() ?? '';

      // Safe logging - don't show password
      print('Login request for email: $email');
      print('Password length: ${password.length} characters');

      // Check if user exists
      final user = _users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (user.isNotEmpty) {
        print('Login successful for: $email');
        return Response.ok(
          jsonEncode({
            'ok': true,
            'token': 'jwt_token_${DateTime.now().millisecondsSinceEpoch}',
            'message': 'Login successful',
            'user': {'email': email},
          }),
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        );
      } else {
        print('Login failed for: $email - Invalid credentials');
        return Response.ok(
          jsonEncode({'ok': false, 'message': 'Invalid email or password'}),
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        );
      }
    } catch (e) {
      print('Login error: $e');
      return Response.badRequest(
        body: jsonEncode({'ok': false, 'message': 'Invalid JSON format'}),
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }
  });

  // Signup route - UPDATED: Don't show password in logs
  router.post('/signup', (Request request) async {
    print('Signup endpoint hit');
    final body = await request.readAsString();

    try {
      final jsonBody = jsonDecode(body);
      final email = jsonBody['email']?.toString() ?? '';
      final password = jsonBody['password']?.toString() ?? '';

      // Safe logging - don't show password
      print('Signup request for email: $email');
      print('Password length: ${password.length} characters');

      // Check if user already exists
      final existingUser = _users.where((user) => user['email'] == email);
      if (existingUser.isNotEmpty) {
        print('User already exists: $email');
        return Response.ok(
          jsonEncode({
            'ok': false,
            'message': 'User with this email already exists',
          }),
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        );
      }

      // Add new user
      _users.add({
        'email': email,
        'password': password,
        'createdAt': DateTime.now().toIso8601String(),
      });

      print('New user registered: $email');
      print('Total users: ${_users.length}');

      return Response.ok(
        jsonEncode({
          'ok': true,
          'message':
              'Signup successful! You can now login with your credentials.',
          'userCount': _users.length,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    } catch (e) {
      print('Signup error: $e');
      return Response.badRequest(
        body: jsonEncode({'ok': false, 'message': 'Invalid JSON format'}),
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }
  });

  // Get all users (for debugging) - UPDATED: Don't show passwords
  router.get('/users', (Request request) {
    print('Users endpoint hit');

    // Create safe user list without passwords
    final safeUsers = _users
        .map((user) => {'email': user['email'], 'createdAt': user['createdAt']})
        .toList();

    return Response.ok(
      jsonEncode({
        'ok': true,
        'users': safeUsers, // Only show safe user data
        'count': _users.length,
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    );
  });

  // Clear all users (for testing)
  router.delete('/users', (Request request) {
    print('Clear users endpoint hit');
    final count = _users.length;
    _users.clear();
    return Response.ok(
      jsonEncode({
        'ok': true,
        'message': 'Cleared all users',
        'clearedCount': count,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    );
  });

  // CORS handlers for all endpoints
  router.options('/login', (Request request) => _corsResponse());
  router.options('/signup', (Request request) => _corsResponse());
  router.options('/users', (Request request) => _corsResponse());

  // Add CORS middleware and logging
  final handler = const Pipeline()
      .addMiddleware(_corsMiddleware())
      .addMiddleware(logRequests())
      .addHandler(router);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);

  print(' ====================================');
  print(' Server running on http://localhost:${server.port}');
  print(' ====================================');
  print(' Available routes:');
  print('   GET    /');
  print('   POST   /login');
  print('   POST   /signup');
  print('   GET    /users (debug - safe data only)');
  print('   DELETE /users (clear all)');
  print(' ====================================');
  print(' Security: Passwords are not logged');
  print(' ====================================');
}

Response _corsResponse() {
  return Response.ok(
    '',
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
    },
  );
}

Middleware _corsMiddleware() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.method == 'OPTIONS') {
        return _corsResponse();
      }
      return null;
    },
    responseHandler: (Response response) {
      return response.change(
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
        },
      );
    },
  );
}
