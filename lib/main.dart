import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/adminView/dashboard_screen.dart';
import 'package:worker_bee/view/login/login_view.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://dcgjcioztrkkjpeucgyo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjZ2pjaW96dHJra2pwZXVjZ3lvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg1MDczMjEsImV4cCI6MjA1NDA4MzMyMX0.d8BdZAm7bWOZ41NMhGqhiET4xeUsS1D-Aaj_vzA5D4Q',
  );
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
      home: DashboardScreen(),
    );
  }
}
