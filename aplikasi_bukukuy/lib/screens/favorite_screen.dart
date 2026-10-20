import 'package:flutter/material.dart';

import '../main.dart';
import '../models/book.dart';
import '../widgets/book_cover.dart';

class FavoriteScreen extends StatelessWidget {
  final VoidCallback onBack;
  final List<Book> favorites;
  final ValueChanged<Book> onRemove;
  final ValueChanged<Book> onOpen;

  const FavoriteScreen({
    super.key,
    required this.onBack,
    required this.favorites,
    required this.onRemove,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1A4D),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: isLandscape
                  ? const EdgeInsets.fromLTRB(12, 8, 24, 12)
                  : const EdgeInsets.fromLTRB(12, 16, 24, 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 8),

                  // Teks Judul
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        const Text(
                          'Buku Favorit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${favorites.length} buku tersimpan',
                          style: const TextStyle(
                            color: Color(0xFFC7D2FE), // Warna biru pudar
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFFAF8F3), 
              child: SafeArea(
                top: false,
                bottom: false,
                child: favorites.isEmpty ? _buildEmpty() : _buildList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 2 : 1;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 92,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) => _buildItem(favorites[index]),
        );
      },
    );
  }

  Widget _buildItem(Book book) {
    return InkWell(
      onTap: () => onOpen(book),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            BookCover(
              coverUrl: book.coverUrl,
              width: 48,
              height: 70,
              borderRadius: 8,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.penulis,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.red),
              onPressed: () => onRemove(book),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    // Bisa di-scroll supaya tidak overflow saat tinggi layar kecil (landscape)
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.favorite,
                size: 80,
                color: Color(0xFFD4C4E9), // Warna ungu muda pudar
              ),
              const SizedBox(height: 24),

              const Text(
                'Belum ada favorit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'Tekan ikon hati pada buku yang kamu suka untuk menyimpannya di sini',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
