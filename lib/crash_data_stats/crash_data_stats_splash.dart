import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vip_gaming_lounge/constants/constants.dart';
import 'package:vip_gaming_lounge/widgets/app_background.dart';

class CrashDataStatsSplash extends StatefulWidget {
  const CrashDataStatsSplash({super.key});

  @override
  State<CrashDataStatsSplash> createState() => _CrashDataStatsSplashState();
}

class _CrashDataStatsSplashState extends State<CrashDataStatsSplash> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          const AppBackground(),

          // Center loader
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated loader with gold glow
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withOpacity(0.3 + _pulseController.value * 0.3),
                            blurRadius: 30 + _pulseController.value * 20,
                            spreadRadius: 5 + _pulseController.value * 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.goldPrimary.withOpacity(0.3),
                              ),
                            ),
                          ),
                          // Main spinner
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                              backgroundColor: AppColors.goldPrimary.withOpacity(0.1),
                            ),
                          ),
                          // Inner icon
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [AppColors.goldLight, AppColors.goldPrimary],
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.casino_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 24),

                // Loading text
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldLight],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: const Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
              ],
            ),
          ),

          // Bottom legal links
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Legal links row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegalLink('Terms & Conditions', () => _openTerms()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.goldPrimary.withOpacity(0.5),
                          ),
                        ),
                      ),
                      _buildLegalLink('Privacy Policy', () => _openPrivacy()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Copyright
                  Text(
                    '© 2025 VIP Gaming Lounge. All rights reserved.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [AppColors.goldLight, AppColors.goldPrimary],
        ).createShader(bounds),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white54,
          ),
        ),
      ),
    );
  }

  Future<void> _openTerms() async {
    final url = Uri.parse('https://vipgamingloungeapp.com/terms/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPrivacy() async {
    final url = Uri.parse('https://vipgamingloungeapp.com/privacy/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
