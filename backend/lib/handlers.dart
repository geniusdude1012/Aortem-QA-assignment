// lib/handlers.dart
import 'dart:convert';
import 'dart:math';
import 'package:shelf/shelf.dart';

final Map<String, String> _users = {}; // email -> password
final Map<String, String> _tokens = {}; // token -> email

String _randomToken() {
  final r = Random();
  final bytes = List<int>.generate(24, (_) => r.nextInt(256));
  return base64Url.encode(bytes);
}

Future<Response> signupHandler(Request req) async {
  try {
    final payload =
        jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final email = payload['email']?.toString();
    final password = payload['password']?.toString();

    if (email == null ||
        password == null ||
        email.isEmpty ||
        password.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'ok': false, 'message': 'Missing email or password'}),
        headers: {'content-type': 'application/json'},
      );
    }

    if (_users.containsKey(email)) {
      return Response(
        409,
        body: jsonEncode({'ok': false, 'message': 'User already exists'}),
        headers: {'content-type': 'application/json'},
      );
    }

    _users[email] = password;
    final token = _randomToken();
    _tokens[token] = email;

    return Response.ok(
      jsonEncode({'ok': true, 'message': 'Signup successful', 'token': token}),
      headers: {'content-type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'ok': false, 'message': 'Invalid payload'}),
      headers: {'content-type': 'application/json'},
    );
  }
}

Future<Response> loginHandler(Request req) async {
  try {
    final payload =
        jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final email = payload['email']?.toString();
    final password = payload['password']?.toString();

    if (email == null || password == null) {
      return Response(
        400,
        body: jsonEncode({'ok': false, 'message': 'Missing email or password'}),
        headers: {'content-type': 'application/json'},
      );
    }

    if (!_users.containsKey(email)) {
      return Response(
        404,
        body: jsonEncode({'ok': false, 'message': 'User not found'}),
        headers: {'content-type': 'application/json'},
      );
    }

    if (_users[email] != password) {
      return Response(
        401,
        body: jsonEncode({'ok': false, 'message': 'Invalid password'}),
        headers: {'content-type': 'application/json'},
      );
    }

    final token = _randomToken();
    _tokens[token] = email;

    return Response.ok(
      jsonEncode({'ok': true, 'message': 'Login successful', 'token': token}),
      headers: {'content-type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'ok': false, 'message': 'Invalid payload'}),
      headers: {'content-type': 'application/json'},
    );
  }
}

Future<Response> protectedHandler(Request req) async {
  final auth = req.headers['authorization'];
  if (auth == null || !auth.startsWith('Bearer ')) {
    return Response(
      401,
      body: jsonEncode({'ok': false, 'message': 'Missing token'}),
      headers: {'content-type': 'application/json'},
    );
  }
  final token = auth.substring(7);
  if (!_tokens.containsKey(token)) {
    return Response(
      403,
      body: jsonEncode({'ok': false, 'message': 'Invalid token'}),
      headers: {'content-type': 'application/json'},
    );
  }
  final email = _tokens[token]!;
  return Response.ok(
    jsonEncode({'ok': true, 'email': email}),
    headers: {'content-type': 'application/json'},
  );
}
