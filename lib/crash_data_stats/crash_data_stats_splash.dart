import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vip_gaming_lounge/constants/constants.dart';

class CrashDataStatsSplash extends StatelessWidget {
  const CrashDataStatsSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/splashscreen.jpg'), fit: BoxFit.cover),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.backgroundPrimary.withOpacity(0.7), AppColors.backgroundPrimary.withOpacity(0.9)],
                ),
              ),
            ),
          ),

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
                  colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.0)],
                ),
              ),
            ),
          ),

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
                  colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.0)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    backgroundColor: Color(0x33FFD700),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 800.ms),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegalLink(context, 'Terms & Conditions', () => _openTerms()),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            width: 1,
                            height: 14,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildLegalLink(context, 'Privacy Policy', () => _openPrivacy()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '© 2025 VIP Gaming Lounge. All rights reserved.',
                        style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.8), fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ).animate().fadeIn(delay: 1200.ms, duration: 800.ms),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalLink(BuildContext context, String text, VoidCallback onTap) {
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
