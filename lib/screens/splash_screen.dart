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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash-screen.png'),
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
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // App Icon
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldAccent.withOpacity(0.4),
                        blurRadius: 50,
                        spreadRadius: 15,
                      ),
                      BoxShadow(
                        color: AppColors.purplePrimary.withOpacity(0.4),
                        blurRadius: 80,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.goldAccent,
                        width: 4,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'assets/images/icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      duration: 1200.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 600.ms),
                
                const Spacer(flex: 1),
                
                // Loading Indicator
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.goldAccent,
                    ),
                    backgroundColor: AppColors.goldAccent.withOpacity(0.2),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .fadeIn(
                      delay: 800.ms,
                      duration: 600.ms,
                    ),
                
                const Spacer(flex: 2),
                
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
                          color: Colors.white.withOpacity(0.4),
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
        ),
      ),
    );
  }

  Widget _buildLegalLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.goldAccent,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.goldAccent.withOpacity(0.5),
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
