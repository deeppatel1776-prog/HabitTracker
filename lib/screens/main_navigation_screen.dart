import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';

class MainNavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: cardColor,
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded, color: AppColors.primary),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              activeIcon: Icon(Icons.bar_chart_rounded, color: AppColors.primary),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              activeIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primary),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
