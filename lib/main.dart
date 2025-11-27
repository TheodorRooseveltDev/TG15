import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/constants.dart';
import 'services/settings_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiOverlayStyle);
  
  // Initialize settings service
  await SettingsService().init();
  
  runApp(const VIPGamingLoungeApp());
}

class VIPGamingLoungeApp extends StatelessWidget {
  const VIPGamingLoungeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIP Gaming Lounge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
