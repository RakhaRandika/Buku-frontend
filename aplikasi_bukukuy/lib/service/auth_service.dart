import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'api_service.dart';

// Menyimpan sesi login di HP supaya user tidak perlu login ulang
// setiap kali aplikasi dibuka.
class AuthService {
  static const _tokenKey = 'auth_token';

  static String? token;
  static User? currentUser;

  static bool get isLoggedIn => token != null && currentUser != null;

  static Future<void> login(String email, String password) async {
    final data = await ApiService.login(email, password);
    await _simpanSesi(data);
  }

  static Future<void> register(
    String nama,
    String email,
    String password,
  ) async {
    final data = await ApiService.register(nama, email, password);
    await _simpanSesi(data);
  }

  // Dipanggil saat aplikasi dibuka: cek token lama masih berlaku atau tidak
  static Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_tokenKey);
    if (saved == null) return;

    token = saved;
    try {
      currentUser = await ApiService.me(saved);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        // Token kedaluwarsa / akun dihapus -> harus login ulang
        await logout();
      } else {
        // Server tidak bisa dihubungi: jangan buang sesi, coba lagi nanti
        token = null;
      }
    }
  }

  static Future<void> logout() async {
    token = null;
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> _simpanSesi(Map<String, dynamic> data) async {
    token = data['token'];
    currentUser = User.fromJson(data['user']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token!);
  }
}
