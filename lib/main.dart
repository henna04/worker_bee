import 'package:flutter/material.dart';
import 'package:worker_bee/view/customNavigation/custom_navigation_view.dart';
import 'package:worker_bee/view/login/admin_login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workerbee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffdbdbdb),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AdminLoginScreen(),
    );
  }
}
