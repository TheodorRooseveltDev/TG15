import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/constants.dart';
import '../services/games_service.dart';
import '../services/settings_service.dart';
import 'age_gate_screen.dart';
import 'main_navigation.dart';

/// Splash screen with loading animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load games data
    await GamesService().loadGames();
    
    // Wait for minimum splash duration
    await Future.delayed(AppAnimations.splashDuration);
    
    if (!mounted) return;
    
    // Check if age gate has been shown
    final hasShownAgeGate = await SettingsService().hasShownAgeGate();
    
    // Navigate to appropriate screen
    if (hasShownAgeGate) {
      _navigateToMainApp();
    } else {
      _navigateToAgeGate();
    }
  }

  void _navigateToAgeGate() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AgeGateScreen(),
        transitionDuration: AppAnimations.splashFadeDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToMainApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigation(),
        transitionDuration: AppAnimations.splashFadeDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splashscreen.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundPrimary.withOpacity(0.7),
                    AppColors.backgroundPrimary.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          // Top gradient fade to black
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Bottom gradient fade to black
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                
                // Loading Indicator
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFD700),
                    ),
                    backgroundColor: Color(0x33FFD700),
                  ),
                ),
                
                const Spacer(),
                
                // Legal Links
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegalLink(
                            'Terms & Conditions',
                            () => _openTerms(),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            width: 1,
                            height: 14,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildLegalLink(
                            'Privacy Policy',
                            () => _openPrivacy(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '© 2025 VIP Gaming Lounge. All rights reserved.',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(
                        delay: 1200.ms,
                        duration: 800.ms,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white.withOpacity(0.8),
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white.withOpacity(0.4),
        ),
      ),
    );
  }

  Future<void> _openTerms() async {
    final url = Uri.parse('https://your-website.com/terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPrivacy() async {
    final url = Uri.parse('https://your-website.com/privacy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
