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
      backgroundColor: AppColors.background,
      body: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.navy,
              child: SafeArea(
                top: false,
                bottom: false,
                child: Padding(
                  padding: isLandscape
                      ? const EdgeInsets.fromLTRB(12, 8, 24, 12)
                      : const EdgeInsets.fromLTRB(12, 16, 24, 32),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          const Text(
                            'Buku Favorit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const SizedBox(width: 8),
                          Text(
                            '${favorites.length} buku tersimpan',
                            style: const TextStyle(
                              color: Color(0xFFC7D2FE),
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
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
      ),
    );
  }

  Widget _buildList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 16.0;
        const spacing = 12.0;
        final columns = constraints.maxWidth >= 600 ? 2 : 1;
        final itemWidth =
            (constraints.maxWidth - padding * 2 - spacing * (columns - 1)) /
            columns;

        final itemHeight = MediaQuery.textScalerOf(context).scale(92);
        return ListView.separated(
          padding: const EdgeInsets.all(padding),
          itemCount: (favorites.length / columns).ceil(),
          separatorBuilder: (context, row) => const SizedBox(height: spacing),
          itemBuilder: (context, row) {
            final children = <Widget>[];
            for (var col = 0; col < columns; col++) {
              if (col > 0) children.add(const Spacer());
              final index = row * columns + col;
              final book = index < favorites.length ? favorites[index] : null;
              children.add(
                SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: book == null ? null : _buildItem(book),
                ),
              );
            }
            return Row(children: children);
          },
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
                children: [
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          book.judul,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          book.penulis,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
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
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const Spacer(),
                const Icon(Icons.favorite, size: 80, color: Color(0xFFD4C4E9)),
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
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
