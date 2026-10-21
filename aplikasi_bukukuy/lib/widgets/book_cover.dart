import 'package:flutter/material.dart';

import '../main.dart';

class BookCover extends StatelessWidget {
  final String? coverUrl;
  final double width;
  final double height;
  final double borderRadius;

  const BookCover({
    super.key,
    this.coverUrl,
    this.width = 110,
    this.height = 160,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final url = coverUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null || url.isEmpty
            ? _buildPlaceholder()
            : Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _buildPlaceholder(),
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.navyLight,
      child: Column(
        children: [
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              Icon(
                Icons.menu_book_rounded,
                size: width * 0.35,
                color: const Color(0xFFA5B4FC),
              ),
              const Spacer(),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
