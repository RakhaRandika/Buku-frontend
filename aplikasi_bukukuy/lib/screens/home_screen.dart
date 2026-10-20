import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/book.dart';
import '../service/api_service.dart';
import '../service/auth_service.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';
import 'favorite_screen.dart';
import 'login_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Book> _books = [];
  List<Book> _favorites = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  Timer? _debounce;

  void _goTo(int index) => setState(() => _currentIndex = index);

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _loadFavorites();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    final search = _search;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final books = await ApiService.getBooks(search: search);
      // Abaikan hasil pencarian lama kalau kata kuncinya sudah berubah
      if (!mounted || search != _search) return;
      setState(() {
        _books = books;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || search != _search) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await ApiService.getFavorites();
      if (!mounted) return;
      setState(() => _favorites = favorites);
    } catch (_) {
      // Error koneksi sudah ditampilkan oleh _loadBooks
    }
  }

  Future<void> _refresh() => Future.wait([_loadBooks(), _loadFavorites()]);

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search = value.trim();
      _loadBooks();
    });
  }

  bool _isFavorite(Book book) => _favorites.any((f) => f.idBuku == book.idBuku);

  // true = berhasil disimpan ke server
  Future<bool> _toggleFavorite(Book book) async {
    final wasFavorite = _isFavorite(book);
    try {
      if (wasFavorite) {
        await ApiService.hapusFavorite(book.idBuku);
      } else {
        await ApiService.tambahFavorite(book.idBuku);
      }
      if (!mounted) return true;
      setState(() {
        _favorites = wasFavorite
            ? _favorites.where((f) => f.idBuku != book.idBuku).toList()
            : [book, ..._favorites];
      });
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return false;
    }
  }

  void _openDetail(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookDetailScreen(
          book: book,
          isFavorite: _isFavorite(book),
          onToggleFavorite: _toggleFavorite,
        ),
      ),
    );
  }

  Widget _buildBookList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.navy));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Color(0xFF9E9E9E)),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _refresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (_books.isEmpty) {
      return const Center(child: Text('Buku tidak ditemukan'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 16.0;
        const spacing = 12.0;
        final cardWidth = (constraints.maxWidth - padding * 2 - spacing * 2) / 3;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: GridView.builder(
            padding: const EdgeInsets.all(padding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              mainAxisExtent: cardWidth * 1.45 + 72,
            ),
            itemCount: _books.length,
            itemBuilder: (context, index) {
              final book = _books[index];
              return BookCard(
                book: book,
                width: cardWidth,
                isFavorite: _isFavorite(book),
                onTap: () => _openDetail(book),
                onFavoriteTap: () => _toggleFavorite(book),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goTo(0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildBookList()),
                ],
              ),
            ),
            FavoriteScreen(
              onBack: () => _goTo(0),
              favorites: _favorites,
              onRemove: _toggleFavorite,
              onOpen: _openDetail,
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavbar(),
      ),
    );
  }

  Widget _buildBottomNavbar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Beranda',
                isActive: _currentIndex == 0,
                onTap: () => _goTo(0),
              ),
              _buildNavItem(
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                label: 'Favorit',
                isActive: _currentIndex == 1,
                onTap: () => _goTo(1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? AppColors.navy : const Color(0xFF9E9E9E);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu perlu login lagi untuk masuk.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (yakin != true) return;

    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Pembaca 👋',
                      style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AuthService.currentUser?.nama ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Keluar',
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout, color: Color(0xFFC7D2FE)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.navyLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 18, color: Color(0xFFA5B4FC)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Cari judul buku',
                      hintStyle: TextStyle(
                        color: Colors.indigo[200],
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

