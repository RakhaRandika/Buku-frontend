import 'dart:math';

import '../data/dummy_books.dart';
import '../models/book.dart';
import '../models/user.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

// =======================================================================
// VERSI DUMMY — tidak ada koneksi internet / backend sama sekali.
// Semua "database" cuma List/Set yang hidup di memori selama app berjalan
// (hilang kalau app di-restart).
//
// Nama method & bentuk data yang dikembalikan SENGAJA dibuat identik
// dengan versi asli (yang manggil http ke backend Express+Supabase),
// supaya layar lain (login_screen, home_screen, dll) tidak perlu
// diubah sama sekali. Nanti kalau backend asli sudah siap, tinggal
// timpa isi file ini dengan versi yang pakai http lagi.
// =======================================================================
class ApiService {
  static final Random _random = Random();

  // "Tabel" buku dummy di memori
  static final List<Book> _books = List.of(dummyBooks);

  // "Tabel" favorit dummy -> cuma simpan id buku yang difavoritkan
  static final Set<int> _favoriteIds = {};

  // Delay kecil biar terasa seperti manggil API beneran (loading spinner dsb kelihatan)
  static Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 500));

  // ---------------- AUTH ----------------

  // Dummy: email & password apa saja (asal tidak kosong, sudah dicek di
  // login_screen) selalu dianggap berhasil login.
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    await _delay();
    final nama = email.contains('@') ? email.split('@').first : email;
    return {
      'token': 'dummy-token-${_random.nextInt(999999)}',
      'user': {'id_user': 1, 'nama': nama, 'email': email},
    };
  }

  static Future<Map<String, dynamic>> register(
    String nama,
    String email,
    String password,
  ) async {
    await _delay();
    return {
      'token': 'dummy-token-${_random.nextInt(999999)}',
      'user': {'id_user': 1, 'nama': nama, 'email': email},
    };
  }

  static Future<User> me(String token) async {
    await _delay();
    // Dummy: token apa saja dianggap valid, selalu kembalikan user yang sama
    return User(idUser: 1, nama: 'Pembaca Bukukuy', email: 'demo@bukukuy.app');
  }

  // ---------------- BUKU ----------------

  static Future<List<Book>> getBooks({String? search}) async {
    await _delay();
    if (search == null || search.trim().isEmpty) {
      return List.of(_books);
    }
    final q = search.trim().toLowerCase();
    return _books
        .where(
          (b) =>
              b.judul.toLowerCase().contains(q) ||
              b.penulis.toLowerCase().contains(q),
        )
        .toList();
  }

  // ---------------- FAVORIT ----------------

  static Future<List<Book>> getFavorites() async {
    await _delay();
    return _books.where((b) => _favoriteIds.contains(b.idBuku)).toList();
  }

  static Future<void> tambahFavorite(int idBuku) async {
    await _delay();
    _favoriteIds.add(idBuku);
  }

  static Future<void> hapusFavorite(int idBuku) async {
    await _delay();
    _favoriteIds.remove(idBuku);
  }
}
