// lib/main.dart
import 'package:flutter/material.dart';
import 'package:frontend/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aortem QA App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
