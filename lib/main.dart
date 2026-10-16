import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/view/auth_check.dart';
import 'package:worker_bee/viewmodel/chat_provider.dart';
import 'package:worker_bee/viewmodel/thme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
    url: 'https://qddzlhdbdpcnnpoxwnvo.supabase.co',
    anonKey: 'sb_publishable_YqcQAC7HP1b0ODSte2FnAQ_vOE0jBv4',
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
          home: const AuthCheck(), // Changed this line
        ),
      ),
    );
  }
}
