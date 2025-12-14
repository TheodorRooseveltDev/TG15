import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String fontFamily = '.SF Pro Display';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.primaryText,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.primaryText,
    letterSpacing: -0.5,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.primaryText,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.primaryText,
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.primaryText,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.6,
    color: AppColors.primaryText,
  );

  static const TextStyle bodyDefault = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.primaryText,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.secondaryText,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.secondaryText,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.primaryText,
  );

  static TextStyle gameTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    foreground: Paint()..shader = AppColors.primaryGradient.createShader(const Rect.fromLTWH(0, 0, 200, 70)),
  );

  static TextStyle gradientText(TextStyle baseStyle, Gradient gradient) {
    return baseStyle.copyWith(foreground: Paint()..shader = gradient.createShader(const Rect.fromLTWH(0, 0, 200, 70)));
  }
}
