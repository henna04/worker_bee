import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
<<<<<<< HEAD
import 'package:worker_bee/view/home/home_view.dart';
import 'package:worker_bee/view/login/login_view.dart';
=======
import 'package:worker_bee/view/auth_check.dart';
>>>>>>> e22e63be569c07dcf729a02bc777576f9a694039
import 'package:worker_bee/viewmodel/chat_provider.dart';
import 'package:worker_bee/viewmodel/thme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(),
        )
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, value, child) => MaterialApp(
          title: 'Workerbee',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: value.themeMode,
<<<<<<< HEAD
          home: const HomeView(), // Changed this line
=======
          home: const AuthCheck(), 
>>>>>>> e22e63be569c07dcf729a02bc777576f9a694039
        ),
      ),
    );
  }
}
