import 'package:flutter/material.dart';
import '../constants/constants.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLarge;
  final bool isFullWidth;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLarge = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLarge ? AppSpacing.xl : AppSpacing.lg,
              vertical: isLarge ? AppSpacing.md : AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              image: const DecorationImage(image: AssetImage('assets/images/main-button-bg.png'), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(color: AppColors.goldAccent.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(color: AppColors.goldAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.primaryText, size: isLarge ? 28 : 20),
                  SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  text,
                  style: (isLarge ? AppTextStyles.h4 : AppTextStyles.buttonText).copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
