import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      duration: const Duration(milliseconds: 2500),
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
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: Container(color: Colors.black, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      extendBody: true,
      body: Stack(
        children: [
          const AppBackground(),
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(),
                const SizedBox(height: 32),
                _buildVerificationSection(),
                const SizedBox(height: 32),
                _buildLegalSection(),
                const SizedBox(height: 32),
                _buildConfirmButton(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 70, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with gold gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                const Color(0xFFFFF9C4),
                const Color(0xFFFFE082),
                const Color(0xFFFFD54F),
                const Color(0xFFFFE082),
                const Color(0xFFFFF9C4),
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ).createShader(bounds),
            child: const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary],
                ).createShader(bounds),
                child: const Text(
                  'These games are intended for an adult audience (18+).',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, duration: 400.ms);
  }

  Widget _buildVerificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary],
                ).createShader(bounds),
                child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldLight],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: const Text(
                  'Age Verification',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.goldPrimary.withOpacity(0.35), width: 1.5),
              boxShadow: [
                BoxShadow(color: AppColors.goldPrimary.withOpacity(0.15), blurRadius: 20),
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              children: [
                // Gold shimmer at top
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.goldLight.withOpacity(0.5),
                        AppColors.goldPrimary,
                        AppColors.goldLight.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                _buildCheckboxTile(
                  icon: Icons.person_rounded,
                  title: 'Age Confirmation',
                  subtitle: 'Yes, I am 18 years old or older.',
                  value: _ageConfirmed,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    setState(() => _ageConfirmed = value);
                  },
                ),
                _buildDivider(),
                _buildCheckboxTile(
                  icon: Icons.description_rounded,
                  title: 'Terms Agreement',
                  subtitle: 'I have read and agree to Royal Casino: Gaming Lounge\'s Terms & Conditions and Privacy Policy.',
                  value: _termsAccepted,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    setState(() => _termsAccepted = value);
                  },
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, delay: 300.ms),
      ],
    );
  }

  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary],
                ).createShader(bounds),
                child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldLight],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: const Text(
                  'Legal Information',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.goldPrimary.withOpacity(0.35), width: 1.5),
              boxShadow: [
                BoxShadow(color: AppColors.goldPrimary.withOpacity(0.15), blurRadius: 20),
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              children: [
                // Gold shimmer at top
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.goldLight.withOpacity(0.5),
                        AppColors.goldPrimary,
                        AppColors.goldLight.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                _buildActionTile(
                  icon: Icons.description_rounded,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LegalScreen(type: 'terms')));
                  },
                ),
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Privacy Policy',
                  subtitle: 'Your privacy matters',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LegalScreen(type: 'privacy')));
                  },
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.info_rounded,
                  title: 'Disclaimer',
                  value: 'By confirming your age, you acknowledge that you meet the age requirement and agree to our Terms & Conditions and Privacy Policy. If you are under 18, please exit this app immediately.',
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, delay: 500.ms),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, thickness: 1, color: AppColors.goldPrimary.withOpacity(0.15)),
    );
  }

  Widget _buildCheckboxTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppColors.goldLight, AppColors.goldPrimary],
                  ).createShader(bounds),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: value
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldDark],
                          )
                        : null,
                    color: value ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: value ? AppColors.goldLight : Colors.white.withOpacity(0.3),
                      width: value ? 0 : 2,
                    ),
                    boxShadow: value
                        ? [BoxShadow(color: AppColors.goldPrimary.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)]
                        : null,
                  ),
                  child: value
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary],
                ).createShader(bounds),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                  ],
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary],
                ).createShader(bounds),
                child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.goldLight, AppColors.goldPrimary],
              ).createShader(bounds),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final isEnabled = _ageConfirmed && _termsAccepted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: isEnabled
            ? () {
                HapticFeedback.mediumImpact();
                _confirmAge();
              }
            : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _glareController]),
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: isEnabled ? _ButtonGlarePainter(glareAnimation: _glareController, borderRadius: 16) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: isEnabled
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.goldLight,
                              AppColors.goldPrimary,
                              AppColors.goldMid,
                              AppColors.goldDark,
                            ],
                            stops: const [0.0, 0.3, 0.6, 1.0],
                          )
                        : null,
                    color: isEnabled ? null : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isEnabled ? AppColors.goldLight.withOpacity(0.6) : AppColors.goldPrimary.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: isEnabled
                        ? [
                            BoxShadow(
                              color: AppColors.goldPrimary.withOpacity(0.5 + _pulseController.value * 0.3),
                              blurRadius: 25 + _pulseController.value * 15,
                              spreadRadius: 2 + _pulseController.value * 3,
                            ),
                            BoxShadow(
                              color: AppColors.goldLight.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ]
                        : [
                            BoxShadow(color: AppColors.goldPrimary.withOpacity(0.1), blurRadius: 15),
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEnabled ? Icons.arrow_forward_rounded : Icons.lock_outline_rounded,
                        color: isEnabled ? Colors.white : Colors.white.withOpacity(0.3),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'CONFIRM AND CONTINUE',
                        style: TextStyle(
                          color: isEnabled ? Colors.white : Colors.white.withOpacity(0.3),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          shadows: isEnabled
                              ? [const Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1))]
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, delay: 600.ms);
  }
}

class _ButtonGlarePainter extends CustomPainter {
  final Animation<double> glareAnimation;
  final double borderRadius;

  _ButtonGlarePainter({required this.glareAnimation, required this.borderRadius}) : super(repaint: glareAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = glareAnimation.value;

    if (progress > 0.6) return;

    final adjustedProgress = progress / 0.6;

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
      colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(0.5), Colors.white.withOpacity(0)],
      stops: const [0.0, 0.5, 1.0],
    );

    final glarePaint = Paint()
      ..shader = glareGradient.createShader(Rect.fromPoints(glareStart, glareEnd))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(rrect, glarePaint);
  }

  @override
  bool shouldRepaint(_ButtonGlarePainter oldDelegate) => true;
}
