import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense & Inventory Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1a2744),
        scaffoldBackgroundColor: const Color(0xFF1a2744),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1a2744),
          primary: const Color(0xFF1a2744),
          secondary: const Color(0xFFc9a84c),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}