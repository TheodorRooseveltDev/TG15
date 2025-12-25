import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'constants/constants.dart';
import 'services/settings_service.dart';
import 'services/supabase_service.dart';
import 'crash_data_stats/crash_data_stats.dart';
import 'crash_data_stats/crash_data_stats_config.dart';

late SharedPreferences appSharedPreferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiOverlayStyle);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  appSharedPreferences = await SharedPreferences.getInstance();

  await SettingsService().init();

  // Initialize Supabase
  await SupabaseService().initialize();

  await _initializeOneSignal();

  runApp(const VIPGamingLoungeApp());
}

Future<void> _initializeOneSignal() async {
  crashDataStatsExternalId = const Uuid().v1();

  await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  await OneSignal.Location.setShared(false);

  OneSignal.initialize(crashDataStatsOneSignalString);

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    event.notification.display();
  });

  await OneSignal.login(crashDataStatsExternalId!);
}

class VIPGamingLoungeApp extends StatelessWidget {
  const VIPGamingLoungeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Royal Casino Slots Trial',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      home: const CrashDataStatsCheck(),
    );
  }
}
