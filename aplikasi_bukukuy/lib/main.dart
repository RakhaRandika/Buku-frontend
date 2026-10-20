import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'service/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Kalau sudah pernah login, langsung masuk ke Beranda
  await AuthService.restoreSession();
  runApp(const BukukuyApp());
}

class BukukuyApp extends StatelessWidget {
  const BukukuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bukukuy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: AuthService.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}

class AppColors {
  static const navy = Color(0xFF1E1A4D);
  static const navyLight = Color(0xFF2A2560);
  static const background = Color(0xFFFAF8F3);
  static const orange = Color(0xFFF97316);
  static const border = Color(0xFFE5E5E5);
  static const red = Color(0xFFDC2626);
  static const blue = Color(0xFF3B82F6);
  static const green = Color(0xFF22C55E);
}
