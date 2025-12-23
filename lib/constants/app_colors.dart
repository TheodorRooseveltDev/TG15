import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds - Pure black
  static const Color backgroundPrimary = Color(0xFF000000);
  static const Color backgroundSecondary = Color(0xFF050505);
  static const Color cardBackground = Color(0xFF0a0a0a);

  static const Color deepSpace = backgroundPrimary;
  static const Color cardDark = backgroundSecondary;

  // Gold - Realistic metallic gold colors
  static const Color goldLight = Color(0xFFF7E98E); // Highlight gold
  static const Color goldPrimary = Color(0xFFD4Af37); // Classic gold
  static const Color goldMid = Color(0xFFBF9B30); // Mid gold
  static const Color goldDark = Color(0xFF996515); // Shadow gold
  static const Color goldDeep = Color(0xFF704214); // Deep shadow
  static const Color goldMuted = Color(0xFFC9A227);

  // Legacy purple names mapped to gold for compatibility
  static const Color purplePrimary = goldPrimary;
  static const Color purpleSecondary = goldDark;
  static const Color purpleDark = Color(0xFF0a0a0a);
  static const Color purpleLight = Color(0xFF6B7280); // Dark gray for secondary text
  static const Color purpleMuted = goldMuted;

  static const Color tealPrimary = goldPrimary;
  static const Color tealDark = goldDark;

  static const Color goldAccent = goldLight;
  static const Color orange = Color(0xFFf59e0b);
  static const Color pink = Color(0xFFec4899);
  static const Color pinkDark = Color(0xFFbe185d);

  static const Color badgeRed = Color(0xFFef4444);
  static const Color badgeBlue = Color(0xFF3b82f6);
  static const Color badgeOrange = Color(0xFFf97316);
  static const Color success = Color(0xFF22c55e);

  static const Color warning = orange;
  static const Color error = badgeRed;
  static const Color deleteRed = Color(0xFFef4444);

  static const Color overlay = Color(0x99000000);

  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF505050); // Dark gray
  static const Color tertiaryText = Color(0xFF3a3a3a); // Darker gray
  static const Color accentText = goldPrimary;

  // Realistic metallic gold gradient - simulates light reflection
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [goldLight, goldPrimary, goldDark, goldPrimary, goldLight],
    stops: [0.0, 0.3, 0.5, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF0a0a0a), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Real metallic gold texture gradient
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldLight, goldPrimary, goldMid, goldDark, goldMid, goldPrimary, goldLight],
    stops: [0.0, 0.15, 0.35, 0.5, 0.65, 0.85, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Simpler gold gradient for smaller elements
  static const LinearGradient goldGradientSimple = LinearGradient(
    colors: [goldLight, goldPrimary, goldDark],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [pink, pinkDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color shimmerBase = backgroundSecondary;
  static const Color shimmerHighlight = cardBackground;
}
