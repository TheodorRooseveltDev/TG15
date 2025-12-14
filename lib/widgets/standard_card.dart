import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class StandardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final bool showBorder;

  const StandardCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusLarge),
        border: showBorder
            ? Border.all(color: borderColor ?? AppColors.purpleMuted.withOpacity(0.3), width: borderWidth ?? 1.0)
            : null,
      ),
      child: child,
    );
  }
}
