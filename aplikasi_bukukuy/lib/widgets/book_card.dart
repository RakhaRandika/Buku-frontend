import 'package:flutter/material.dart';

import '../main.dart';
import '../models/book.dart';
import 'book_cover.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final double width;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const BookCard({
    super.key,
    required this.book,
    this.width = 110,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Stack(
              children: [
                BookCover(
                  coverUrl: book.coverUrl,
                  width: width,
                  height: width * 1.45,
                ),
                if (onFavoriteTap != null)
                  Positioned(top: 6, right: 6, child: _buildFavoriteButton()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    book.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),

            Row(
              children: [
                Expanded(
                  child: Text(
                    book.penulis,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
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
    );
  }

  Widget _buildFavoriteButton() {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onFavoriteTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 16,
            color: isFavorite ? AppColors.red : const Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }
}
