import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'service/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        scaffoldBackgroundColor: Color(0xFFFAF8F3),
        useMaterial3: true,
      ),
      home: AuthService.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
