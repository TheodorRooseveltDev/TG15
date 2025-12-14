import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../constants/constants.dart';
import 'home_screen.dart';
import 'games_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Widget> get _screens => [
    HomeScreen(onNavigateToGames: () => _onTabTapped(1)),
    const GamesScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),

              BoxShadow(
                color: AppColors.purplePrimary.withOpacity(0.25),
                blurRadius: 40,
                offset: const Offset(0, 5),
                spreadRadius: -5,
              ),

              BoxShadow(color: AppColors.goldAccent.withOpacity(0.15), blurRadius: 50, spreadRadius: -10),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.cardBackground.withOpacity(0.9),
                      AppColors.backgroundSecondary.withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(width: 1.5, color: AppColors.purpleMuted.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
                    _buildNavItem(icon: Icons.casino_rounded, label: 'Games', index: 1),
                    _buildNavItem(icon: Icons.settings_rounded, label: 'Settings', index: 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.all(isSelected ? 8 : 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.purplePrimary.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.purplePrimary.withOpacity(0.4), blurRadius: 15, spreadRadius: 0)]
                      : null,
                ),
                child: AnimatedScale(
                  scale: isSelected ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    size: 28,
                    color: isSelected ? Colors.white : AppColors.purpleLight.withOpacity(0.5),
                    shadows: isSelected ? [Shadow(color: AppColors.purplePrimary, blurRadius: 20)] : null,
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
