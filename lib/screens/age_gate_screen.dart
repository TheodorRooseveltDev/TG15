import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/constants.dart';
import '../services/settings_service.dart';
import '../widgets/app_background.dart';
import 'main_navigation.dart';
import 'legal_screen.dart';

class AgeGateScreen extends StatefulWidget {
  const AgeGateScreen({super.key});

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> with TickerProviderStateMixin {
  bool _ageConfirmed = false;
  bool _termsAccepted = false;
  late AnimationController _pulseController;
  late AnimationController _glareController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

    _glareController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // 1.5s animation + 1s pause
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glareController.dispose();
    super.dispose();
  }

  void _confirmAge() async {
    await SettingsService().setAgeGateShown();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: Container(color: Colors.black, child: child),
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
          const AppBackground(blurIntensity: 20, overlayOpacity: 0.0),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        LinearGradient(colors: [Colors.white, Color(0xFFE0E0E0)]).createShader(bounds),
                    child: Text(
                      'Welcome!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(color: AppColors.goldAccent.withOpacity(0.5), blurRadius: 20),
                          Shadow(color: AppColors.purplePrimary.withOpacity(0.8), blurRadius: 30),
                          Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 2)),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, delay: 300.ms),

                  const SizedBox(height: AppSpacing.lg),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'These games are intended for an adult audience (18+).',
                        style: AppTextStyles.bodyLarge.copyWith(color: Colors.white.withOpacity(0.8), height: 1.6),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildReviewText(),
                    ],
                  ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

                  const SizedBox(height: AppSpacing.xl),

                  _buildCheckboxContainer()
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 600.ms)
                      .slideX(begin: -0.1, end: 0, delay: 1000.ms),

                  const SizedBox(height: AppSpacing.xl),

                  _buildConfirmButton()
                      .animate()
                      .fadeIn(delay: 1400.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0, delay: 1400.ms),

                  const SizedBox(height: AppSpacing.md),

                  _buildLegalText().animate().fadeIn(delay: 1600.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Please review and accept our',
          textAlign: TextAlign.left,
          style: AppTextStyles.bodyDefault.copyWith(color: Colors.white.withOpacity(0.8), height: 1.5),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LegalScreen(type: 'terms')));
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
            Text(' and ', style: AppTextStyles.bodyDefault.copyWith(color: Colors.white.withOpacity(0.8), height: 1.5)),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LegalScreen(type: 'privacy')));
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildCheckboxRow(
            isChecked: _ageConfirmed,
            text: 'Yes, I am 18 years old or older.',
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _ageConfirmed = value ?? false);
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildCheckboxRow(
            isChecked: _termsAccepted,
            text: 'I have read and agree to Royal Casino: Gaming Lounge\'s Terms & Conditions and Privacy Policy.',
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _termsAccepted = value ?? false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow({required bool isChecked, required String text, required ValueChanged<bool?> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isChecked ? AppColors.goldAccent : Colors.grey.withOpacity(0.5), width: 2),
            ),
            child: isChecked ? Icon(Icons.check_rounded, color: AppColors.goldAccent, size: 20) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: AppTextStyles.bodyDefault.copyWith(color: Colors.white.withOpacity(0.95), height: 1.5),
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
      onTap: isEnabled
          ? () {
              HapticFeedback.mediumImpact();
              _confirmAge();
            }
          : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _glareController]),
        builder: (context, child) {
          return CustomPaint(
            painter: isEnabled ? _ButtonGlarePainter(glareAnimation: _glareController, borderRadius: 30) : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              decoration: BoxDecoration(
                gradient: isEnabled
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.goldAccent, AppColors.orange, const Color(0xFFD4841C)],
                        stops: const [0.0, 0.5, 1.0],
                      )
                    : null,
                color: isEnabled ? null : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: isEnabled ? AppColors.goldAccent.withOpacity(0.8) : Colors.grey, width: 2.5),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: AppColors.goldAccent.withOpacity(0.3 + _pulseController.value * 0.1),
                          blurRadius: 20 + _pulseController.value * 8,
                          spreadRadius: _pulseController.value * 1.5,
                        ),
                        BoxShadow(color: AppColors.orange.withOpacity(0.2), blurRadius: 25),
                        BoxShadow(color: AppColors.purplePrimary.withOpacity(0.2), blurRadius: 20),
                        BoxShadow(
                          color: AppColors.goldAccent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                        BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 8)),
                      ]
                    : null,
              ),
              child: Text(
                'CONFIRM AND CONTINUE',
                style: TextStyle(
                  color: isEnabled ? Colors.white : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  shadows: isEnabled
                      ? [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 5, offset: const Offset(0, 2))]
                      : null,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegalText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/images/age-rating.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.5), BlendMode.srcIn),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'By confirming your age, you acknowledge that you meet the age requirement and agree to our Terms & Conditions and Privacy Policy. If you are under 18, please exit this app immediately.',
            style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.4),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}

class _ButtonGlarePainter extends CustomPainter {
  final Animation<double> glareAnimation;
  final double borderRadius;

  _ButtonGlarePainter({required this.glareAnimation, required this.borderRadius}) : super(repaint: glareAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = glareAnimation.value;

    if (progress > 0.6) return; // 0.6 * 2.5s = 1.5s animation, 1s pause

    final adjustedProgress = progress / 0.6; // Normalize to 0-1

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final glareStart = Offset(
      -size.width * 0.3 + (size.width * 1.6 * adjustedProgress),
      -size.height * 0.3 + (size.height * 1.6 * adjustedProgress),
    );

    final glareEnd = Offset(glareStart.dx + size.width * 0.3, glareStart.dy + size.height * 0.3);

    final glareGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(0.6), Colors.white.withOpacity(0)],
      stops: const [0.0, 0.5, 1.0],
    );

    final glarePaint = Paint()
      ..shader = glareGradient.createShader(Rect.fromPoints(glareStart, glareEnd))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(rrect, glarePaint);
  }

  @override
  bool shouldRepaint(_ButtonGlarePainter oldDelegate) => true;
}
