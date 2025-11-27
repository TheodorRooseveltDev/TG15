import 'dart:ui';
import 'package:flutter/material.dart';

/// Consistent background widget used across all screens
class AppBackground extends StatelessWidget {
  final double blurIntensity;
  final double overlayOpacity;
  
  const AppBackground({
    super.key,
    this.blurIntensity = 20,
    this.overlayOpacity = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred background
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blurIntensity, sigmaY: blurIntensity),
            child: Image.asset(
              'assets/images/splash-screen.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Dark overlay
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(overlayOpacity),
          ),
        ),
      ],
    );
  }
}
