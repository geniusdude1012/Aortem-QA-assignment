// lib/signup_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/api_client.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailCtl = TextEditingController();
  final _pwCtl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _debugInfo;

  Future<void> _doSignup() async {
    final email = _emailCtl.text.trim();
    final password = _pwCtl.text;

    // Input validation
    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password');
      return;
    }

    // Email validation
    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    // Password validation
    if (password.length < 6) {
      _showError('Password should be at least 6 characters long');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _debugInfo = 'Starting signup process...';
    });

    try {
      print('🔄 [1] Starting signup process...');
      print('📧 Email: $email');
      setState(() {
        _debugInfo = 'Sending request to server...';
      });

      final resp = await ApiClient.signup(email, password).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Signup request timed out');
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
          final message = resp['body']['message'] ?? 'Signup successful';
          print('🎉 [3] Signup successful! Message: $message');

          setState(() {
            _debugInfo = 'Signup successful! Redirecting...';
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Wait for the snackbar to show, then navigate back
          await Future.delayed(const Duration(milliseconds: 1500));

          // Navigate back to login page
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          final message = resp['body']?['message'] ?? 'Signup failed';
          print('❌ [3] Signup failed - OK is false: $message');
          setState(() {
            _debugInfo = 'Signup failed: $message';
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
      _showError(
        'Request timeout. Please check if server is running on port 8080.',
      );
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

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
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

  void _showSuccessAndNavigate(String message) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back after a short delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _testConnection() async {
    print('🔍 Testing connection to server for signup...');
    setState(() {
      _debugInfo = 'Testing server connection...';
    });

    try {
      final testResp = await ApiClient.testConnection().timeout(
        const Duration(seconds: 5),
      );
      print('✅ Server is reachable for signup: ${testResp['status']}');
      setState(() {
        _debugInfo = 'Server connected successfully!';
      });
    } catch (e) {
      print('❌ Server connection test failed for signup: $e');
      setState(() {
        _debugInfo = 'Server connection failed: $e';
        _error =
            'Cannot connect to server. Please make sure it\'s running on http://localhost:8080';
      });
    }
  }

  void _testManualConnection() async {
    print('🧪 Manual connection test started...');
    setState(() {
      _debugInfo = 'Running manual connection tests...';
    });

    String testResults = '';

    // Test 1: Direct HTTP call
    try {
      print('🧪 Test 1: Direct HTTP call to server...');
      final response = await http
          .get(Uri.parse('http://localhost:8080/'))
          .timeout(const Duration(seconds: 5));
      testResults += '✅ Test 1 - SUCCESS: Status ${response.statusCode}\n';
      print(
        '🧪 Test 1 - SUCCESS: Status ${response.statusCode}, Body: ${response.body}',
      );
    } catch (e) {
      testResults += '❌ Test 1 - FAILED: $e\n';
      print('🧪 Test 1 - FAILED: $e');
    }

    // Test 2: ApiClient test
    try {
      print('🧪 Test 2: ApiClient test connection...');
      final result = await ApiClient.testConnection();
      testResults += '✅ Test 2 - SUCCESS: Status ${result['status']}\n';
      print('🧪 Test 2 - SUCCESS: $result');
    } catch (e) {
      testResults += '❌ Test 2 - FAILED: $e\n';
      print('🧪 Test 2 - FAILED: $e');
    }

    setState(() {
      _debugInfo = testResults;
    });
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
      appBar: AppBar(
        title: const Text('Sign Up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _loading
              ? null
              : () {
                  print('← Navigating back to login page');
                  Navigator.pop(context);
                },
        ),
      ),
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
              autofillHints: const [AutofillHints.email],
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
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Password must be at least 6 characters long',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 18),

            // Signup button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _doSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // Test connection button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _testManualConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Test Connection',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Additional info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Make sure backend server is running on http://localhost:8080\n• After successful signup, you will be redirected to login',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
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
