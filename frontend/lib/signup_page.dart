// lib/signup_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/api_client.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailCtl = TextEditingController();
  final _pwCtl = TextEditingController();
  bool _loading = false;

  Future<void> _doSignup() async {
    setState(() {
      _loading = true;
    });
    final resp = await ApiClient.signup(_emailCtl.text.trim(), _pwCtl.text);
    setState(() {
      _loading = false;
    });

    if (resp['status'] == 200 && resp['body']['ok'] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signup success')));
      Navigator.pop(context);
    } else {
      final message = resp['body']?['message'] ?? 'Signup failed';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextField(
              controller: _emailCtl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwCtl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _loading ? null : _doSignup,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
