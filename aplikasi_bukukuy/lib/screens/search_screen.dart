import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/book.dart';
import '../service/api_service.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';

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
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.background,
                child: _buildBody(),
              ),
            ),
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

  Widget _buildBody() {
    if (_loading) {
      return _buildCentered(
        const CircularProgressIndicator(color: AppColors.navy),
      );
    }

    if (!_hasSearched) {
      return _buildCentered(
        Column(
          children: [
            const Row(
              children: [
                Spacer(),
                Icon(Icons.search, size: 64, color: Color(0xFFD1D5DB)),
                Spacer(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ketik judul buku atau nama penulis',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
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

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(padding, padding, padding, 0),
              child: Row(
                children: [
                  const Text(
                    'Hasil Pencarian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_results.length} buku',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(padding),
                itemCount: (_results.length / columns).ceil(),
                separatorBuilder: (context, row) =>
                    const SizedBox(height: spacing),
                itemBuilder: (context, row) {
                  final children = <Widget>[];
                  for (var col = 0; col < columns; col++) {
                    if (col > 0) children.add(const Spacer());
                    final index = row * columns + col;
                    final book = index < _results.length
                        ? _results[index]
                        : null;
                    children.add(
                      SizedBox(
                        width: cardWidth,
                        height: cardWidth * 1.45 + 72,
                        child: book == null
                            ? null
                            : BookCard(
                                book: book,
                                width: cardWidth,
                                isFavorite: _isFavorite(book),
                                onTap: () => _openDetail(book),
                                onFavoriteTap: () => _toggleFavorite(book),
                              ),
                      ),
                    );
                  }
                  return Row(children: children);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
