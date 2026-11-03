import 'package:flutter/material.dart';

class AppButtonNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppButtonNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.orientationOf(context) == Orientation.landscape
              ? 52
              : 64,
          child: Row(
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Beranda',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _buildNavItem(
                context,
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                label: 'Favorit',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? const Color(0xFF1E1A4D) : const Color(0xFF9E9E9E);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            const Spacer(),
            Icon(isActive ? activeIcon : icon, size: 24, color: color),
            SizedBox(
              height: MediaQuery.orientationOf(context) == Orientation.landscape
                  ? 2
                  : 4,
            ),
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
}
