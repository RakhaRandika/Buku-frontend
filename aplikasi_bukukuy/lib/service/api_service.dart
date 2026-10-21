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

class ApiService {
  static final Random _random = Random();

  static final List<Book> _books = List.of(dummyBooks);

  static final Set<int> _favoriteIds = {};

  static Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 500));

 


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
    return User(idUser: 1, nama: 'Pembaca Bukukuy', email: 'demo@bukukuy.app');
  }



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
