import 'package:flutter/material.dart';
import 'package:succulent_app/core/theme/app_colors.dart';

class HomeNavBar extends StatelessWidget {
  final bool isScrolled;
  final VoidCallback onAddTap;

  const HomeNavBar({
    super.key,
    required this.isScrolled,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final double otherIconSize = isScrolled ? 34 : 28;
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      alignment: Alignment.center,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.grid_view_rounded,
                  color: AppColors.creme, size: otherIconSize),
              tooltip: 'Garden',
            ),
            GestureDetector(
              onTap: onAddTap,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.creme,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child:
                    const Icon(Icons.add, color: AppColors.darkGreen, size: 28),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.bar_chart_rounded,
                  color: AppColors.creme, size: otherIconSize),
              tooltip: 'Stats',
            ),
          ],
        ),
      ),
    );
  }
}
