import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundPrimary = Color(0xFF0f0319);
  static const Color backgroundSecondary = Color(0xFF1a0b2e);
  static const Color cardBackground = Color(0xFF2d1b69);

  static const Color deepSpace = backgroundPrimary;
  static const Color cardDark = backgroundSecondary;

  static const Color purplePrimary = Color(0xFF7c3aed); // purple-600 - Buttons, borders, accents
  static const Color purpleSecondary = Color(0xFF6d28d9); // purple-700 - Gradients, hover states
  static const Color purpleDark = Color(0xFF4c1d95); // purple-900 - Header gradient, deep accents
  static const Color purpleLight = Color(0xFFa78bfa); // purple-400 - Secondary text, links
  static const Color purpleMuted = Color(0xFF8b5cf6); // purple-500 - Borders with opacity

  static const Color tealPrimary = purplePrimary;
  static const Color tealDark = purpleSecondary;

  static const Color goldAccent = Color(0xFFfbbf24); // Gold/Yellow - Coin rewards, highlights, CTA buttons
  static const Color orange = Color(0xFFf59e0b); // Gradients with gold, tournament badges
  static const Color pink = Color(0xFFec4899); // Secondary buttons
  static const Color pinkDark = Color(0xFFbe185d); // Secondary button gradients

  static const Color badgeRed = Color(0xFFef4444); // LIVE badges
  static const Color badgeBlue = Color(0xFF3b82f6); // DAILY badges
  static const Color badgeOrange = Color(0xFFf97316); // MONTHLY badges
  static const Color success = Color(0xFF22c55e); // Success states, prize text

  static const Color warning = orange;
  static const Color error = badgeRed;
  static const Color deleteRed = Color(0xFFef4444);

  static const Color overlay = Color(0x99000000); // 60% opacity

  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = purpleLight; // #a78bfa
  static const Color tertiaryText = Color(0xFFc4b5fd); // purple-300
  static const Color accentText = purplePrimary;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [purplePrimary, purpleSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [purpleDark, purpleSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldAccent, orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [pink, pinkDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC0f0319)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color shimmerBase = backgroundSecondary;
  static const Color shimmerHighlight = cardBackground;
}
