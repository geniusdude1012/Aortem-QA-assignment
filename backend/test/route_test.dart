// backend/test/routes_test.dart
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';

void main() {
  group('Route Tests with Middleware', () {
    test('GET /healthz returns correct response with CORS', () async {
      final router = Router();

      router.get('/healthz', (Request request) {
        return Response.ok(
          jsonEncode({'status': 'ok'}),
          headers: {'Content-Type': 'application/json'},
        );
      });

      final handler = const Pipeline()
          .addMiddleware(_createCorsMiddleware())
          .addHandler(router);

      final response = await handler(
        Request('GET', Uri.parse('http://localhost:8081/healthz')),
      );

      expect(response.statusCode, equals(200));
      expect(response.headers['Content-Type'], equals('application/json'));
      expect(response.headers['Access-Control-Allow-Origin'], equals('*'));

      final body = await response.readAsString();
      final jsonBody = jsonDecode(body);

      expect(jsonBody['status'], equals('ok'));
    });

    test('POST /login handles valid credentials', () async {
      final router = Router();

      router.post('/login', (Request request) async {
        final body = await request.readAsString();
        final jsonBody = jsonDecode(body);

        final email = jsonBody['email'];
        final password = jsonBody['password'];

        if (email == 'test@example.com' && password == 'password123') {
          return Response.ok(
            jsonEncode({
              'ok': true,
              'token': 'jwt_test_token',
              'message': 'Login successful',
            }),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          return Response.ok(
            jsonEncode({'ok': false, 'message': 'Invalid credentials'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      });

      final handler = const Pipeline()
          .addMiddleware(_createCorsMiddleware())
          .addHandler(router);

      // Test valid credentials
      final successResponse = await handler(
        Request(
          'POST',
          Uri.parse('http://localhost:8081/login'),
          body: jsonEncode({
            'email': 'test@example.com',
            'password': 'password123',
          }),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      expect(successResponse.statusCode, equals(200));
      final successBody = jsonDecode(await successResponse.readAsString());
      expect(successBody['ok'], equals(true));
      expect(successBody['token'], equals('jwt_test_token'));

      // Test invalid credentials
      final failResponse = await handler(
        Request(
          'POST',
          Uri.parse('http://localhost:8081/login'),
          body: jsonEncode({'email': 'wrong@example.com', 'password': 'wrong'}),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      expect(failResponse.statusCode, equals(200));
      final failBody = jsonDecode(await failResponse.readAsString());
      expect(failBody['ok'], equals(false));
    });

    test('POST /signup creates new user', () async {
      final users = <Map<String, String>>[];

      final router = Router();

      router.post('/signup', (Request request) async {
        final body = await request.readAsString();
        final jsonBody = jsonDecode(body);

        final email = jsonBody['email'];
        final password = jsonBody['password'];

        // Check if user exists
        if (users.any((user) => user['email'] == email)) {
          return Response.ok(
            jsonEncode({'ok': false, 'message': 'User already exists'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Add new user
        users.add({'email': email, 'password': password});

        return Response.ok(
          jsonEncode({'ok': true, 'message': 'Signup successful'}),
          headers: {'Content-Type': 'application/json'},
        );
      });

      final handler = const Pipeline()
          .addMiddleware(_createCorsMiddleware())
          .addHandler(router);

      // Test new user signup
      final response1 = await handler(
        Request(
          'POST',
          Uri.parse('http://localhost:8081/signup'),
          body: jsonEncode({
            'email': 'new@example.com',
            'password': 'password123',
          }),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      expect(response1.statusCode, equals(200));
      final body1 = jsonDecode(await response1.readAsString());
      expect(body1['ok'], equals(true));

      // Test duplicate user
      final response2 = await handler(
        Request(
          'POST',
          Uri.parse('http://localhost:8081/signup'),
          body: jsonEncode({
            'email': 'new@example.com',
            'password': 'password123',
          }),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      expect(response2.statusCode, equals(200));
      final body2 = jsonDecode(await response2.readAsString());
      expect(body2['ok'], equals(false));
    });

    test('GET /v1/secret requires authentication', () async {
      final router = Router();

      router.get('/v1/secret', (Request request) {
        final authHeader = request.headers['authorization'];

        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return Response(
            401,
            body: jsonEncode({'ok': false, 'message': 'Unauthorized'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final token = authHeader.substring(7);

        if (token == 'valid_token') {
          return Response.ok(
            jsonEncode({'ok': true, 'uid': 'user_123'}),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          return Response(
            403,
            body: jsonEncode({'ok': false, 'message': 'Invalid token'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      });

      final handler = const Pipeline()
          .addMiddleware(_createCorsMiddleware())
          .addHandler(router);

      // Test without token
      final unauthorizedResponse = await handler(
        Request('GET', Uri.parse('http://localhost:8081/v1/secret')),
      );
      expect(unauthorizedResponse.statusCode, equals(401));

      // Test with invalid token
      final forbiddenResponse = await handler(
        Request(
          'GET',
          Uri.parse('http://localhost:8081/v1/secret'),
          headers: {'authorization': 'Bearer invalid_token'},
        ),
      );
      expect(forbiddenResponse.statusCode, equals(403));

      // Test with valid token
      final authorizedResponse = await handler(
        Request(
          'GET',
          Uri.parse('http://localhost:8081/v1/secret'),
          headers: {'authorization': 'Bearer valid_token'},
        ),
      );
      expect(authorizedResponse.statusCode, equals(200));
      final authBody = jsonDecode(await authorizedResponse.readAsString());
      expect(authBody['ok'], equals(true));
      expect(authBody['uid'], equals('user_123'));
    });

    test('OPTIONS requests return CORS headers', () async {
      final router = Router();

      router.options('/login', (Request request) {
        return Response.ok(
          '',
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers':
                'Origin, Content-Type, Authorization',
          },
        );
      });

      final handler = const Pipeline()
          .addMiddleware(_createCorsMiddleware())
          .addHandler(router);

      final response = await handler(
        Request('OPTIONS', Uri.parse('http://localhost:8081/login')),
      );

      expect(response.statusCode, equals(200));
      expect(response.headers['Access-Control-Allow-Origin'], equals('*'));
    });
  });
}

// CORS Middleware (same as above)
Middleware _createCorsMiddleware() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.method == 'OPTIONS') {
        return Response.ok(
          '',
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers':
                'Origin, Content-Type, Authorization',
          },
        );
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
