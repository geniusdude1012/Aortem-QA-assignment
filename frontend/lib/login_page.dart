// lib/login_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/api_client.dart';
import 'package:frontend/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtl = TextEditingController();
  final _pwCtl = TextEditingController();
  bool _loading = false;
  String? _token;
  String? _error;

  Future<void> _doLogin() async {
    final email = _emailCtl.text.trim();
    final password = _pwCtl.text;

    // Input validation
    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      print('🔄 [1] Starting login process...');
      print('📧 Email: $email');

      // Add timeout to prevent hanging
      final resp = await ApiClient.login(email, password).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Login request timed out');
        },
      );

      print('✅ [2] API Response received: $resp');

      setState(() {
        _loading = false;
      });

      // Debug the response structure
      print('📊 Status code: ${resp['status']}');
      print('📦 Response body type: ${resp['body'].runtimeType}');
      print('📦 Response body: ${resp['body']}');

      if (resp['status'] == 200) {
        if (resp['body']['ok'] == true) {
          final token = resp['body']['token'];
          setState(() {
            _token = token;
          });
          print('🎉 [3] Login successful! Token: $token');

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));
        } else {
          final message = resp['body']?['message'] ?? 'Login failed';
          print('❌ [3] Login failed - OK is false: $message');
          _showError(message);
        }
      } else {
        final message =
            resp['body']?['message'] ?? 'HTTP Error ${resp['status']}';
        print('❌ [3] HTTP Error: ${resp['status']} - $message');
        _showError(message);
      }
    } on TimeoutException catch (e) {
      print('⏰ [ERROR] Request timeout: $e');
      setState(() {
        _loading = false;
      });
      _showError('Request timeout. Please check your connection.');
    } on FormatException catch (e) {
      print('📄 [ERROR] JSON format error: $e');
      setState(() {
        _loading = false;
      });
      _showError('Invalid response from server.');
    } catch (e) {
      print('🚨 [ERROR] Unexpected error: $e');
      print('🚨 [ERROR] Error type: ${e.runtimeType}');
      setState(() {
        _loading = false;
      });
      _showError('Connection failed: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _testConnection() async {
    print('🔍 Testing connection to server...');
    try {
      // Test if server is reachable
      final testResp = await ApiClient.login(
        'test@test.com',
        'test',
      ).timeout(const Duration(seconds: 5));
      print('✅ Server is reachable: $testResp');
    } catch (e) {
      print('❌ Server connection test failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Test connection when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextField(
              controller: _emailCtl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwCtl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                hintText: 'Enter your password',
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _doLogin,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Login', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    ),
              child: const Text('Don\'t have an account? Sign up'),
            ),

            // Debug info
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_token != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Login Successful!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Token: $_token',
                      style: const TextStyle(fontFamily: 'Monospace'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _pwCtl.dispose();
    super.dispose();
  }
}
