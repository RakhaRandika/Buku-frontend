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
  String _search = '';
  Timer? _debounce;

  final _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    final search = _search;
    setState(() => _loading = true);
    final books = await ApiService.getBooks(search: search);
    if (!mounted || search != _search) return;
    setState(() {
      _books = books;
      _loading = false;
    });
  }

  Future<void> _loadFavorites() async {
    final favorites = await ApiService.getFavorites();
    if (!mounted) return;
    setState(() => _favorites = favorites);
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

  Future<bool> _toggleFavorite(Book book) async {
    final wasFavorite = _isFavorite(book);
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

  Widget _buildCentered(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const Spacer(),
                Row(
                  children: [
                    const Spacer(),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth - 64,
                      ),
                      child: child,
                    ),
                    const Spacer(),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookList() {
    if (_loading) {
      return _buildCentered(
        const CircularProgressIndicator(color: AppColors.navy),
      );
    }
    if (_books.isEmpty) {
      return _buildCentered(const Text('Buku tidak ditemukan'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 16.0;
        const spacing = 12.0;
        final columns = (constraints.maxWidth / 130).floor().clamp(3, 8);
        final cardWidth =
            (constraints.maxWidth - padding * 2 - spacing * (columns - 1)) /
            columns;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(padding),
            itemCount: (_books.length / columns).ceil(),
            separatorBuilder: (context, row) => const SizedBox(height: spacing),
            itemBuilder: (context, row) =>
                _buildBookRow(row, columns, cardWidth),
          ),
        );
      },
    );
  }

  Widget _buildBookRow(int row, int columns, double cardWidth) {
    final children = <Widget>[];
    for (var col = 0; col < columns; col++) {
      if (col > 0) children.add(const Spacer());
      final index = row * columns + col;
      final book = index < _books.length ? _books[index] : null;
      children.add(
        SizedBox(
          width: cardWidth,
          height: cardWidth * 1.45 + 72,
          child: book == null ? null : _buildBookCard(book, cardWidth),
        ),
      );
    }
    return Row(children: children);
  }

  Widget _buildBookCard(Book book, double cardWidth) {
    return BookCard(
      book: book,
      width: cardWidth,
      isFavorite: _isFavorite(book),
      onTap: () => _openDetail(book),
      onFavoriteTap: () => _toggleFavorite(book),
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
            _buildHomePage(),
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

  Widget _buildHomePage() {
    return SafeArea(
      left: false,
      right: false,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.background,
              child: SafeArea(
                top: false,
                bottom: false,
                child: _buildBookList(),
              ),
            ),
          ),
        ],
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
          height: _isLandscape ? 52 : 64,
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
          children: [
            const Spacer(),
            Icon(isActive ? activeIcon : icon, size: 24, color: color),
            SizedBox(height: _isLandscape ? 2 : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
            const Spacer(),
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

  bool get _isLandscape =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  Widget _buildHeader() {
    final logoutButton = IconButton(
      tooltip: 'Keluar',
      onPressed: _confirmLogout,
      icon: const Icon(Icons.logout, color: Color(0xFFC7D2FE)),
    );

    if (_isLandscape) {
      return Container(
        width: double.infinity,
        color: AppColors.navy,
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 10),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            children: [
              Expanded(child: _buildGreeting()),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildSearchField()),
              logoutButton,
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.65,
                  ),
                  child: _buildGreeting(),
                ),
                const Spacer(),
                logoutButton,
              ],
            ),
            const SizedBox(height: 16),
            _buildSearchField(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: 'Selamat Pembaca 👋\n',
            style: TextStyle(
              color: Color(0xFFC7D2FE),
              fontSize: 12,
              height: 1.8,
            ),
          ),
          TextSpan(
            text: AuthService.currentUser?.nama ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSearchField() {
    return Container(
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
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari judul buku',
                hintStyle: TextStyle(color: Colors.indigo[200], fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
