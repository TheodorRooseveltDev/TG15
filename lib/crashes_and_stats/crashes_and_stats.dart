import 'dart:async';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kingmaker_casino_trial_games/crashes_and_stats/crashes_and_stats_splash.dart';
import 'package:kingmaker_casino_trial_games/crashes_and_stats/crashes_and_stats_service.dart';
import 'package:kingmaker_casino_trial_games/crashes_and_stats/crashes_and_stats_config.dart';
import 'package:kingmaker_casino_trial_games/crashes_and_stats/crashes_and_stats_web_view_backup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences crashesAndStatsSharedPreferences;

dynamic crashesAndStatsConversionData;

String? crashesAndStatsTrackingPermissionStatus;

String? crashesAndStatsAdvertisingId;

String? crashesAndStatsLink;

String? crashesAndStatsAppsflyerId;

String? crashesAndStatsExternalId;

class CrashesAndStatsCheck extends StatefulWidget {
  const CrashesAndStatsCheck({super.key});

  @override
  State<CrashesAndStatsCheck> createState() => _CrashesAndStatsCheckState();
}

class _CrashesAndStatsCheckState extends State<CrashesAndStatsCheck> {
  @override
  void initState() {
    super.initState();
    crashesAndStatsInitAll();
  }

  crashesAndStatsInitAll() async {
    crashesAndStatsSharedPreferences = await SharedPreferences.getInstance();
    
    bool sendedAnalytics =
        crashesAndStatsSharedPreferences.getBool("sendedAnalytics") ?? false;
    
    crashesAndStatsLink = crashesAndStatsSharedPreferences.getString("link");

    if (crashesAndStatsLink != null && crashesAndStatsLink != "" && !sendedAnalytics) {
      bool useBackupWebview = false;
      try {
        final uri = Uri.parse(crashesAndStatsLink!);
        final wtype = uri.queryParameters['wtype'];
        if (wtype == '2') {
          useBackupWebview = true;
        }
      } catch (_) {
        useBackupWebview = false;
      }
      
      if (useBackupWebview) {
        CrashesAndStatsService().crashesAndStatsNavigateToWebViewBackup(context);
      } else {
        CrashesAndStatsService().crashesAndStatsNavigateToWebView(context);
      }
    } else {
      if (sendedAnalytics) {
        CrashesAndStatsService().crashesAndStatsNavigateToSplash(context);
      } else {
        crashesAndStatsInitializeMainPart();
      }
    }
  }

  void crashesAndStatsInitializeMainPart() async {
    await crashesAndStatsCollectIdsAndCreateLink();
  }

  Future<void> crashesAndStatsCollectIdsAndCreateLink() async {
    await Future.wait([
      CrashesAndStatsService().crashesAndStatsRequestTrackingPermission(),
      CrashesAndStatsService().crashesAndStatsInitializeOneSignal(),
      _initializeAppsFlyer(),
    ]);

    await _waitForAppsFlyerData();

    await _makePostRequestAndNavigate();
  }

  Future<void> _initializeAppsFlyer() async {
    final appsFlyerOptions = CrashesAndStatsService().crashesAndStatsCreateAppsFlyerOptions();
    AppsflyerSdk appsFlyerSdk = AppsflyerSdk(appsFlyerOptions);

    await appsFlyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    
    crashesAndStatsAppsflyerId = await appsFlyerSdk.getAppsFlyerUID();
    
    _appsFlyerSdk = appsFlyerSdk;
  }

  AppsflyerSdk? _appsFlyerSdk;

  Future<void> _waitForAppsFlyerData() async {
    if (_appsFlyerSdk == null) return;

    final completer = Completer<void>();
    bool completed = false;

    Future.delayed(const Duration(seconds: 4), () {
      if (!completed) {
        completed = true;
        crashesAndStatsConversionData = {};
        completer.complete();
      }
    });

    _appsFlyerSdk!.onInstallConversionData((res) {
      if (!completed) {
        completed = true;
        crashesAndStatsConversionData = res;
        completer.complete();
      }
    });

    _appsFlyerSdk!.startSDK(
      onError: (errorCode, errorMessage) {
        if (!completed) {
          completed = true;
          crashesAndStatsConversionData = {};
          completer.complete();
        }
      },
    );

    await completer.future;
  }

  Future<void> _makePostRequestAndNavigate() async {
    Map<dynamic, dynamic> parameters = crashesAndStatsConversionData ?? {};

    parameters.addAll({
      "tracking_status": crashesAndStatsTrackingPermissionStatus,
      "${crashesAndStatsStandartWord}_id": crashesAndStatsAdvertisingId,
      "external_id": crashesAndStatsExternalId,
      "appsflyer_id": crashesAndStatsAppsflyerId,
    });

    String? link = await CrashesAndStatsService().sendCrashesAndStatsRequest(parameters);

    crashesAndStatsLink = link;

    if (crashesAndStatsLink == "" || crashesAndStatsLink == null) {
      CrashesAndStatsService().crashesAndStatsNavigateToSplash(context);
    } else {
      crashesAndStatsSharedPreferences.setString("link", crashesAndStatsLink.toString());
      crashesAndStatsSharedPreferences.setBool("success", true);
      
      bool useBackupWebview = false;
      try {
        final uri = Uri.parse(crashesAndStatsLink!);
        final wtype = uri.queryParameters['wtype'];
        if (wtype == '2') {
          useBackupWebview = true;
        }
      } catch (_) {
        useBackupWebview = false;
      }
      
      if (useBackupWebview) {
        CrashesAndStatsService().crashesAndStatsNavigateToWebViewBackup(context);
      } else {
        CrashesAndStatsService().crashesAndStatsNavigateToWebView(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const CrashesAndStatsSplash();
  }
}
