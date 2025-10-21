// lib/login_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/api_client.dart';
import 'package:frontend/signup_page.dart';
import 'package:frontend/welcome_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtl = TextEditingController();
  final _pwCtl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _debugInfo;

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
      _debugInfo = 'Starting login process...';
    });

    try {
      print('🔄 [1] Starting login process...');
      print('📧 Email: $email');
      setState(() {
        _debugInfo = 'Sending request to server...';
      });

      final resp = await ApiClient.login(email, password).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Login request timed out');
        },
      );

      print('✅ [2] API Response received: $resp');

      setState(() {
        _loading = false;
        _debugInfo = 'Response received from server';
      });

      print('📊 Status code: ${resp['status']}');
      print('📦 Response body: ${resp['body']}');
      print('🔑 OK value: ${resp['body']['ok']}');

      if (resp['status'] == 200) {
        if (resp['body']['ok'] == true) {
          final token = resp['body']['token'];
          final message = resp['body']['message'] ?? 'Login successful';
          print('🎉 [3] Login successful! Token: $token');

          setState(() {
            _debugInfo = 'Login successful! Redirecting...';
          });

          // Show success message briefly
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );

          // Wait a moment then navigate to welcome page
          await Future.delayed(const Duration(milliseconds: 1000));

          // Navigate to welcome page with user data
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WelcomePage(userEmail: email, token: token),
              ),
            );
          }
        } else {
          final message = resp['body']?['message'] ?? 'Login failed';
          print('❌ [3] Login failed - OK is false: $message');
          setState(() {
            _debugInfo = 'Login failed: $message';
          });
          _showError(message);
        }
      } else {
        final message =
            resp['body']?['message'] ?? 'HTTP Error ${resp['status']}';
        print('❌ [3] HTTP Error: ${resp['status']} - $message');
        setState(() {
          _debugInfo = 'HTTP Error: ${resp['status']}';
        });
        _showError(message);
      }
    } on TimeoutException catch (e) {
      print('⏰ [ERROR] Request timeout: $e');
      setState(() {
        _loading = false;
        _debugInfo = 'Request timeout - server not responding';
      });
      _showError('Request timeout. Please check if server is running.');
    } on FormatException catch (e) {
      print('📄 [ERROR] JSON format error: $e');
      setState(() {
        _loading = false;
        _debugInfo = 'Invalid response format from server';
      });
      _showError('Invalid response from server.');
    } catch (e) {
      print('🚨 [ERROR] Unexpected error: $e');
      print('🚨 [ERROR] Error type: ${e.runtimeType}');
      setState(() {
        _loading = false;
        _debugInfo = 'Connection failed: ${e.toString()}';
      });
      _showError(
        'Cannot connect to server. Please make sure the server is running.',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _testConnection() async {
    print('🔍 Testing connection to server for login...');
    setState(() {
      _debugInfo = 'Testing server connection...';
    });

    try {
      final testResp = await ApiClient.testConnection().timeout(
        const Duration(seconds: 5),
      );
      print('✅ Server is reachable for login: ${testResp['status']}');
      setState(() {
        _debugInfo = 'Server connected successfully!';
      });
    } catch (e) {
      print('❌ Server connection test failed for login: $e');
      setState(() {
        _debugInfo = 'Server connection failed: $e';
        _error =
            'Cannot connect to server. Please make sure it\'s running on http://localhost:8080';
      });
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
            // Debug info
            if (_debugInfo != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Debug Info:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _debugInfo!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'Monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Error display
            if (_error != null) ...[
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
              const SizedBox(height: 16),
            ],

            // Email field
            TextField(
              controller: _emailCtl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            // Password field
            TextField(
              controller: _pwCtl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 18),

            // Login button
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

            // Signup button
            TextButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    ),
              child: const Text('Don\'t have an account? Sign up'),
            ),
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
