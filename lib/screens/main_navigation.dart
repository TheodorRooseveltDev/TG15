import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import 'home_screen.dart';
import 'games_screen.dart';
import 'slot_screen.dart';
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
    const SlotScreen(),
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
      extendBody: false,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.cardBackground,
              AppColors.backgroundSecondary,
            ],
          ),
          border: Border(
            top: BorderSide(width: 1, color: AppColors.goldPrimary.withOpacity(0.2)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
                _buildNavItem(icon: Icons.casino_rounded, label: 'Games', index: 1),
                _buildNavItem(icon: Icons.gamepad_rounded, label: 'Slots', index: 2),
                _buildNavItem(icon: Icons.settings_rounded, label: 'Settings', index: 3),
              ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: isSelected ? LinearGradient(
                  colors: [
                    AppColors.goldDark.withOpacity(0.3),
                    AppColors.goldPrimary.withOpacity(0.15),
                    AppColors.goldDark.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ) : null,
                borderRadius: BorderRadius.circular(14),
                border: isSelected ? Border.all(
                  width: 1,
                  color: AppColors.goldPrimary.withOpacity(0.4),
                ) : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.goldPrimary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: ShaderMask(
                shaderCallback: isSelected ? (bounds) => LinearGradient(
                  colors: [
                    AppColors.goldLight,
                    AppColors.goldPrimary,
                    AppColors.goldLight,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds) : (bounds) => LinearGradient(
                  colors: [AppColors.secondaryText, AppColors.secondaryText],
                ).createShader(bounds),
                child: Icon(
                  icon,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            ShaderMask(
              shaderCallback: isSelected ? (bounds) => LinearGradient(
                colors: [
                  AppColors.goldLight,
                  AppColors.goldPrimary,
                  AppColors.goldLight,
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds) : (bounds) => LinearGradient(
                colors: [AppColors.secondaryText, AppColors.secondaryText],
              ).createShader(bounds),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
