import 'package:flutter/material.dart';
import 'package:vip_gaming_lounge/services/settings_service.dart';
import 'package:vip_gaming_lounge/screens/age_gate_screen.dart';
import 'package:vip_gaming_lounge/screens/main_navigation.dart';

String crashDataStatsOneSignalString = "b3fa80da-bf1c-4ca3-b2e7-002c820916ce";

String crashDataStatsDevKeypndAppId = "6756540143";

String crashDataStatsAfDevKey1 = "hNYE575rnPsX";
String crashDataStatsAfDevKey2 = "hWgTXMRzpB";
String crashDataStatsUrl = 'https://vipgamingloungeapp.com/crashdata/';

String crashDataStatsStandartWord = "crashdata";
void crashDataStatsOpenStandartAppLogic(BuildContext context) async {
  final settingsService = SettingsService();
  final ageGateShown = await settingsService.hasShownAgeGate();

  if (!ageGateShown) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AgeGateScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: Container(color: Colors.black, child: child),
          );
        },
      ),
    );
  } else {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: Container(color: Colors.black, child: child),
          );
        },
      ),
    );
  }
}
