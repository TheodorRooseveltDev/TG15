import 'package:flutter/animation.dart';

class AppAnimations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration dramatic = Duration(milliseconds: 800);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve decelerate = Curves.decelerate;

  static const double scalePressed = 0.98;
  static const double scaleHover = 1.05;

  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration splashFadeDuration = Duration(milliseconds: 500);

  static const Duration carouselAutoPlayDuration = Duration(seconds: 5);
  static const Duration carouselTransitionDuration = Duration(milliseconds: 400);

  static const Duration pageTransitionDuration = Duration(milliseconds: 300);

  static const Duration shimmerDuration = Duration(milliseconds: 1500);
}
