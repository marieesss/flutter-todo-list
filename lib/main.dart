// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'firebase_options.dart';

// écrans
import 'screens/auth/LoginRegister.dart';
import 'screens/categories/categories_page.dart';

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
      darkTheme: AppTheme.darkBW(context),
      themeMode: ThemeMode.dark,
      home: const LoginPage(),
      routes: {'/categories': (_) => const CategoriesPage()},
    );
  }
}
