import 'package:flutter/material.dart';

import '../main.dart';
import '../models/book.dart';
import '../widgets/book_cover.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  final bool isFavorite;
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
    if (isLandscape) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Row(
            children: [
              Container(
                width: (MediaQuery.sizeOf(context).width * 0.35).clamp(
                  200.0,
                  360.0,
                ),
                color: AppColors.navy,
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const ratio = 205 / 140;
                          var height = constraints.maxHeight;
                          var width = height / ratio;
                          final maxWidth = constraints.maxWidth - 16;
                          if (width > maxWidth) {
                            width = maxWidth;
                            height = width * ratio;
                          }

                          return Column(
                            children: [
                              const Spacer(),
                              Row(
                                children: [
                                  const Spacer(),
                                  BookCover(
                                    coverUrl: widget.book.coverUrl,
                                    width: width,
                                    height: height,
                                  ),
                                  const Spacer(),
                                ],
                              ),
                              const Spacer(),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: AppColors.background,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: _buildDetails(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.navy,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                child: Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Spacer(),
                        BookCover(
                          coverUrl: widget.book.coverUrl,
                          width: 140,
                          height: 205,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: _buildDetails(),
                ),
              ),
            ),
          ],
        ),
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
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                Expanded(
                  child: Text(
                    (value ?? '').isEmpty ? '-' : value!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
