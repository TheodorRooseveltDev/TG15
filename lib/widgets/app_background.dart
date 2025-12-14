import 'dart:ui';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final double blurIntensity;
  final double overlayOpacity;

  const AppBackground({super.key, this.blurIntensity = 20, this.overlayOpacity = 0.6});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blurIntensity, sigmaY: blurIntensity),
            child: Image.asset('assets/images/splashscreen.jpg', fit: BoxFit.cover),
          ),
        ),

        Positioned.fill(child: Container(color: Colors.black.withOpacity(overlayOpacity))),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.0)],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.0)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
