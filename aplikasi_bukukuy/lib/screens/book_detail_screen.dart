import 'package:flutter/material.dart';

import '../main.dart';
import '../models/book.dart';
import '../widgets/book_cover.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  final bool isFavorite;
  // Mengembalikan true kalau berhasil disimpan ke server
  final Future<bool> Function(Book book) onToggleFavorite;

  const BookDetailScreen({
    super.key,
    required this.book,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late bool _isFavorite = widget.isFavorite;
  bool _saving = false;

  Future<void> _toggleFavorite() async {
    setState(() => _saving = true);
    final berhasil = await widget.onToggleFavorite(widget.book);
    if (!mounted) return;
    setState(() {
      if (berhasil) _isFavorite = !_isFavorite;
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    // Landscape: cover di panel kiri, detail di kanan supaya cover tidak
    // menghabiskan tinggi layar
    if (isLandscape) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            Container(
              width: 240,
              color: AppColors.navy,
              child: SafeArea(
                right: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                  child: Column(
                    children: [
                      _buildTopBar(),
                      BookCover(
                        coverUrl: widget.book.coverUrl,
                        width: 140,
                        height: 205,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SafeArea(
                left: false,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: _buildDetails(),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.navy,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                child: Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 8),
                    BookCover(
                      coverUrl: widget.book.coverUrl,
                      width: 140,
                      height: 205,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: _buildDetails(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
        IconButton(
          tooltip: _isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
          onPressed: _saving ? null : _toggleFavorite,
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? AppColors.red : Colors.white,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDetails() {
    final book = widget.book;
    return [
      Text(
        book.judul,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        book.penulis,
        style: const TextStyle(fontSize: 14, color: AppColors.orange),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          _buildInfo('Penerbit', book.penerbit),
          const SizedBox(width: 12),
          _buildInfo('Tahun terbit', book.tahunTerbit),
        ],
      ),
      const SizedBox(height: 20),
      const Text(
        'Deskripsi',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.navy,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        (book.deskripsi ?? '').isEmpty
            ? 'Belum ada deskripsi.'
            : book.deskripsi!,
        style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey[800]),
      ),
    ];
  }

  Widget _buildInfo(String label, String? value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 4),
            Text(
              (value ?? '').isEmpty ? '-' : value!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
