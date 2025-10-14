// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// écrans
import 'screens/auth/LoginRegister.dart';
import 'screens/categories/categories_page.dart'; // 👈 au lieu de homepage.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          isDense: true,
        ),
      ),
      home: const LoginPage(),
      routes: {
        '/categories': (_) => const CategoriesPage(), // 👈 nouvelle route par défaut
      },
    );
  }
}