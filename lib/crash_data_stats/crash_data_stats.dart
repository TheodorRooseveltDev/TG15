import 'dart:async';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:vip_gaming_lounge/crash_data_stats/crash_data_stats_splash.dart';
import 'package:vip_gaming_lounge/crash_data_stats/crash_data_stats_service.dart';
import 'package:vip_gaming_lounge/crash_data_stats/crash_data_stats_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip_gaming_lounge/main.dart';

late SharedPreferences crashDataStatsSharedPreferences;

dynamic crashDataStatsConversionData;

String? crashDataStatsTrackingPermissionStatus;

String? crashDataStatsAdvertisingId;

String? crashDataStatsLink;

String? crashDataStatsAppsflyerId;

String? crashDataStatsExternalId;

class CrashDataStatsCheck extends StatefulWidget {
  const CrashDataStatsCheck({super.key});

  @override
  State<CrashDataStatsCheck> createState() => _CrashDataStatsCheckState();
}

class _CrashDataStatsCheckState extends State<CrashDataStatsCheck> {
  @override
  void initState() {
    super.initState();
    crashDataStatsInitAll();
  }

  crashDataStatsInitAll() async {
    crashDataStatsSharedPreferences = appSharedPreferences;

    bool sendedAnalytics = crashDataStatsSharedPreferences.getBool("sendedAnalytics") ?? false;

    crashDataStatsLink = crashDataStatsSharedPreferences.getString("link");

    if (crashDataStatsLink != null && crashDataStatsLink != "") {
      await Future.delayed(Duration.zero);

      if (!mounted) return;

      bool useBackupWebview = false;
      try {
        final uri = Uri.parse(crashDataStatsLink!);
        final wtype = uri.queryParameters['wtype'];
        if (wtype == '2') {
          useBackupWebview = true;
        }
      } catch (_) {
        useBackupWebview = false;
      }

      if (useBackupWebview) {
        CrashDataStatsService().crashDataStatsNavigateToWebViewBackup(context);
      } else {
        CrashDataStatsService().crashDataStatsNavigateToWebView(context);
      }
    } else {
      if (sendedAnalytics) {
        await Future.delayed(Duration.zero);
        if (!mounted) return;
        crashDataStatsOpenStandartAppLogic(context);
      } else {
        await crashDataStatsInitializeMainPart();
      }
    }
  }

  Future<void> crashDataStatsInitializeMainPart() async {
    await crashDataStatsCollectIdsAndCreateLink();
  }

  Future<void> crashDataStatsCollectIdsAndCreateLink() async {
    await Future.wait([CrashDataStatsService().crashDataStatsRequestTrackingPermission(), _initializeAppsFlyer()]);

    await _waitForAppsFlyerData();

    await _makePostRequestAndNavigate();
  }

  Future<void> _initializeAppsFlyer() async {
    final appsFlyerOptions = CrashDataStatsService().crashDataStatsCreateAppsFlyerOptions();
    AppsflyerSdk appsFlyerSdk = AppsflyerSdk(appsFlyerOptions);

    await appsFlyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    crashDataStatsAppsflyerId = await appsFlyerSdk.getAppsFlyerUID();

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
        crashDataStatsConversionData = {};
        completer.complete();
      }
    });

    _appsFlyerSdk!.onInstallConversionData((res) {
      if (!completed) {
        completed = true;
        crashDataStatsConversionData = res;
        completer.complete();
      }
    });

    _appsFlyerSdk!.startSDK(
      onError: (errorCode, errorMessage) {
        if (!completed) {
          completed = true;
          crashDataStatsConversionData = {};
          completer.complete();
        }
      },
    );

    await completer.future;
  }

  Future<void> _makePostRequestAndNavigate() async {
    Map<dynamic, dynamic> parameters = crashDataStatsConversionData ?? {};

    parameters.addAll({
      "tracking_status": crashDataStatsTrackingPermissionStatus,
      "${crashDataStatsStandartWord}_id": crashDataStatsAdvertisingId,
      "external_id": crashDataStatsExternalId,
      "appsflyer_id": crashDataStatsAppsflyerId,
    });

    String? link = await CrashDataStatsService().sendCrashDataStatsRequest(parameters);

    crashDataStatsLink = link;

    if (crashDataStatsLink == "" || crashDataStatsLink == null) {
      CrashDataStatsService().crashDataStatsNavigateToSplash(context);
    } else {
      crashDataStatsSharedPreferences.setString("link", crashDataStatsLink.toString());
      crashDataStatsSharedPreferences.setBool("success", true);

      bool useBackupWebview = false;
      try {
        final uri = Uri.parse(crashDataStatsLink!);
        final wtype = uri.queryParameters['wtype'];
        if (wtype == '2') {
          useBackupWebview = true;
        }
      } catch (_) {
        useBackupWebview = false;
      }

      if (useBackupWebview) {
        CrashDataStatsService().crashDataStatsNavigateToWebViewBackup(context);
      } else {
        CrashDataStatsService().crashDataStatsNavigateToWebView(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const CrashDataStatsSplash();
  }
}
