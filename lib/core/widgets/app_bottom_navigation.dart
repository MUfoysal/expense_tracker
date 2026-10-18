
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onAddPressed,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onAddPressed;

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.swap_horiz_rounded,
    Icons.bar_chart_rounded,
    Icons.person_rounded,
  ];

  static const List<String> _labels = [
    'Home',
    'Transactions',
    'Reports',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          AnimatedBottomNavigationBar.builder(
            itemCount: _icons.length,
            activeIndex: selectedIndex,
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.verySmoothEdge,
            leftCornerRadius: 24,
            rightCornerRadius: 24,
            height: 68,
            backgroundColor: AppColors.surface,
            splashColor: AppColors.glow,
            borderColor: AppColors.divider,
            borderWidth: 1,
            elevation: 0,
            onTap: onDestinationSelected,
            tabBuilder: (index, isActive) {
              final color = isActive
                  ? AppColors.neon
                  : AppColors.secondaryText;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _icons[index],
                    color: color,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _labels[index],
                        maxLines: 1,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Center add button
          Positioned(
            top: 0,
            child: SizedBox(
              width: 54,
              height: 54,
              child: FloatingActionButton(
                onPressed: onAddPressed,
                elevation: 0,
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
