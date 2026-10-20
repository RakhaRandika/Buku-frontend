import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/book.dart';
import '../service/api_service.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';

// Halaman cari buku full-screen (terpisah dari search bar kecil di Home).
// Belum dipasang di navigasi manapun — tinggal panggil lewat:
//   Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  List<Book> _results = [];
  List<Book> _favorites = [];
  bool _loading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favorites = await ApiService.getFavorites();
    if (!mounted) return;
    setState(() => _favorites = favorites);
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(value));
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    setState(() => _loading = true);
    final results = await ApiService.getBooks(search: q);
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
      _hasSearched = true;
    });
  }

  bool _isFavorite(Book book) => _favorites.any((f) => f.idBuku == book.idBuku);

  Future<void> _toggleFavorite(Book book) async {
    final wasFavorite = _isFavorite(book);
    if (wasFavorite) {
      await ApiService.hapusFavorite(book.idBuku);
    } else {
      await ApiService.tambahFavorite(book.idBuku);
    }
    if (!mounted) return;
    setState(() {
      _favorites = wasFavorite
          ? _favorites.where((f) => f.idBuku != book.idBuku).toList()
          : [book, ..._favorites];
    });
  }

  void _openDetail(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookDetailScreen(
          book: book,
          isFavorite: _isFavorite(book),
          onToggleFavorite: (b) async {
            await _toggleFavorite(b);
            return true;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Container(
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
                      controller: _controller,
                      autofocus: true,
                      onChanged: _onChanged,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Cari judul atau penulis...',
                        hintStyle: TextStyle(
                          color: Colors.indigo[200],
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.navy),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search, size: 64, color: Color(0xFFD1D5DB)),
              const SizedBox(height: 16),
              Text(
                'Ketik judul buku atau nama penulis',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(child: Text('Buku tidak ditemukan'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 16.0;
        const spacing = 12.0;
        final crossAxisCount = (constraints.maxWidth / 130).floor().clamp(3, 8);
        final cardWidth =
            (constraints.maxWidth -
                padding * 2 -
                spacing * (crossAxisCount - 1)) /
            crossAxisCount;

        return GridView.builder(
          padding: const EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: cardWidth * 1.45 + 72,
          ),
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final book = _results[index];
            return BookCard(
              book: book,
              width: cardWidth,
              isFavorite: _isFavorite(book),
              onTap: () => _openDetail(book),
              onFavoriteTap: () => _toggleFavorite(book),
            );
          },
        );
      },
    );
  }
}
