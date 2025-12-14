import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
      primaryColor: AppColors.purplePrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.purplePrimary,
        secondary: AppColors.goldAccent,
        surface: AppColors.backgroundSecondary,
        background: AppColors.backgroundPrimary,
        error: AppColors.error,
        onPrimary: AppColors.primaryText,
        onSecondary: AppColors.backgroundPrimary,
        onSurface: AppColors.primaryText,
        onBackground: AppColors.primaryText,
        onError: AppColors.primaryText,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h5,
        iconTheme: IconThemeData(color: AppColors.primaryText),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundSecondary,
        selectedItemColor: AppColors.purplePrimary,
        unselectedItemColor: AppColors.purpleLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
      ),

      cardTheme: CardThemeData(
        color: AppColors.backgroundSecondary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          side: BorderSide(color: AppColors.purpleMuted.withOpacity(0.3), width: 1),
        ),
        margin: const EdgeInsets.all(AppSpacing.cardMargin),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purplePrimary,
          foregroundColor: AppColors.primaryText,
          elevation: 4,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            side: const BorderSide(color: AppColors.goldAccent, width: 2),
          ),
          textStyle: AppTextStyles.buttonText,
          shadowColor: AppColors.purplePrimary.withOpacity(0.3),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.purplePrimary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          side: const BorderSide(color: AppColors.purplePrimary, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
          textStyle: AppTextStyles.buttonText,
          backgroundColor: AppColors.backgroundSecondary.withOpacity(0.8),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.purplePrimary, textStyle: AppTextStyles.bodyDefault),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: const BorderSide(color: AppColors.purplePrimary, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: BorderSide(color: AppColors.purpleMuted.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: const BorderSide(color: AppColors.purplePrimary, width: 2),
        ),
        hintStyle: AppTextStyles.bodyDefault.copyWith(color: AppColors.secondaryText),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      ),

      iconTheme: const IconThemeData(color: AppColors.primaryText, size: 24),

      dividerTheme: DividerThemeData(color: AppColors.purpleMuted.withOpacity(0.2), thickness: 1, space: AppSpacing.lg),

      textTheme: const TextTheme(
        displayLarge: AppTextStyles.h1,
        displayMedium: AppTextStyles.h2,
        displaySmall: AppTextStyles.h3,
        headlineMedium: AppTextStyles.h4,
        headlineSmall: AppTextStyles.h5,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyDefault,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.buttonText,
        labelSmall: AppTextStyles.caption,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.backgroundSecondary,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
