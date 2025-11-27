import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/constants.dart';
import '../services/settings_service.dart';
import '../widgets/app_background.dart';
import 'main_navigation.dart';
import 'legal_screen.dart';

/// Age gate screen for 18+ confirmation
class AgeGateScreen extends StatefulWidget {
  const AgeGateScreen({super.key});

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> {
  bool _ageConfirmed = false;
  bool _termsAccepted = false;

  void _confirmAge() async {
    // Save that age gate has been shown
    await SettingsService().setAgeGateShown();
    
    if (!mounted) return;
    
    // Navigate to main app
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigation(),
        transitionDuration: AppAnimations.normal,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppAnimations.smoothCurve,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Consistent background
          const AppBackground(
            blurIntensity: 20,
            overlayOpacity: 0.7,
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xxl,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    
                    // App Icon
                    _buildLogo()
                        .animate()
                        .scale(
                          duration: 800.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 600.ms),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Welcome Text
                    Text(
                      'Welcome!',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0, delay: 300.ms),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Adult Audience Text
                    Text(
                      'These games are intended for an adult\naudience (18+).',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 600.ms),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Review Terms Text with Links
                    _buildReviewText()
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 600.ms),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Combined Checkbox Container
                    _buildCheckboxContainer()
                        .animate()
                        .fadeIn(delay: 1000.ms, duration: 600.ms)
                        .slideX(begin: -0.1, end: 0, delay: 1000.ms),
                    
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Confirm Button
                    _buildConfirmButton()
                        .animate()
                        .fadeIn(delay: 1400.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0, delay: 1400.ms),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Bottom Legal Text
                    _buildLegalText()
                        .animate()
                        .fadeIn(delay: 1600.ms, duration: 600.ms),
                    
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.goldAccent.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: AppColors.purplePrimary.withOpacity(0.4),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(90),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.goldAccent,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(90),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(86),
            child: Image.asset(
              'assets/images/icon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewText() {
    return Column(
      children: [
        Text(
          'Please review and accept our',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyDefault.copyWith(
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LegalScreen(type: 'terms'),
                  ),
                );
              },
              child: Text(
                'Terms & Conditions',
                style: AppTextStyles.bodyDefault.copyWith(
                  color: AppColors.goldAccent,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  height: 1.5,
                ),
              ),
            ),
            Text(
              ' and ',
              style: AppTextStyles.bodyDefault.copyWith(
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LegalScreen(type: 'privacy'),
                  ),
                );
              },
              child: Text(
                'Privacy Policy.',
                style: AppTextStyles.bodyDefault.copyWith(
                  color: AppColors.goldAccent,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckboxContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: AppColors.purpleMuted.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Age Confirmation Checkbox
              _buildCheckboxRow(
                isChecked: _ageConfirmed,
                text: 'Yes, I am 18 years old or older.',
                onChanged: (value) {
                  setState(() => _ageConfirmed = value ?? false);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              // Terms Acceptance Checkbox
              _buildCheckboxRow(
                isChecked: _termsAccepted,
                text: 'I have read and agree to Grand Mondial Online\'s Terms & Conditions and Privacy Policy.',
                onChanged: (value) {
                  setState(() => _termsAccepted = value ?? false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxRow({
    required bool isChecked,
    required String text,
    required ValueChanged<bool?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isChecked ? AppColors.purplePrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isChecked ? AppColors.purplePrimary : AppColors.purpleLight.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: isChecked
                ? Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: AppTextStyles.bodyDefault.copyWith(
                  color: Colors.white.withOpacity(0.95),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final isEnabled = _ageConfirmed && _termsAccepted;
    
    return GestureDetector(
      onTap: isEnabled ? _confirmAge : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          image: isEnabled
              ? DecorationImage(
                  image: AssetImage('assets/images/main-button-bg.png'),
                  fit: BoxFit.cover,
                )
              : null,
          color: isEnabled ? null : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            color: isEnabled ? AppColors.goldAccent : Colors.grey,
            width: 3,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.goldAccent.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.purplePrimary.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ]
              : null,
        ),
        child: Text(
          'CONFIRM AND CONTINUE',
          style: AppTextStyles.h4.copyWith(
            color: isEnabled ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLegalText() {
    return Text(
      'By confirming your age, you acknowledge that you meet the age requirement and agree to our Terms & Conditions and Privacy Policy. If you are under 18, please exit this app immediately.',
      style: AppTextStyles.caption.copyWith(
        color: Colors.white.withOpacity(0.5),
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    );
  }
}
