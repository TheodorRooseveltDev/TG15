import 'dart:convert';
import 'dart:io';

import 'package:advertising_id/advertising_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:vip_gaming_lounge/crash_data_stats/crash_data_stats.dart';
import 'package:vip_gaming_lounge/crash_data_stats/crash_data_stats_config.dart';
import 'package:vip_gaming_lounge/crash_data_stats/crash_data_stats_web_view.dart';
import 'package:vip_gaming_lounge/crash_data_stats/crash_data_stats_web_view_backup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class CrashDataStatsService {
  Future<void> crashDataStatsInitializeOneSignal() async {}

  Future<void> crashDataStatsRequestPermissionOneSignal() async {
    final wasRequested = crashDataStatsSharedPreferences.getBool("wasOpenNotification") ?? false;

    if (!wasRequested) {
      await OneSignal.Notifications.requestPermission(true);
      await crashDataStatsSharedPreferences.setBool("wasOpenNotification", true);
    }
  }

  void crashDataStatsSendRequiestToBack() {
    try {
      OneSignal.login(crashDataStatsExternalId!);
    } catch (_) {}
  }

  Future crashDataStatsNavigateToSplash(BuildContext context) async {
    crashDataStatsSharedPreferences.setBool("sendedAnalytics", true);
    crashDataStatsOpenStandartAppLogic(context);
  }

  Future<bool> isSystemPermissionGranted() async {
    if (!Platform.isIOS) return false;
    try {
      final status = await OneSignal.Notifications.permissionNative();
      return status == OSNotificationPermission.authorized ||
          status == OSNotificationPermission.provisional ||
          status == OSNotificationPermission.ephemeral;
    } catch (_) {
      return false;
    }
  }

  void crashDataStatsNavigateToWebView(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CrashDataStatsWebViewWidget(),
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

  void crashDataStatsNavigateToWebViewBackup(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CrashDataStatsWebViewWidgetBackup(),
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

  AppsFlyerOptions crashDataStatsCreateAppsFlyerOptions() {
    return AppsFlyerOptions(
      afDevKey: (crashDataStatsAfDevKey1 + crashDataStatsAfDevKey2),
      appId: crashDataStatsDevKeypndAppId,
      timeToWaitForATTUserAuthorization: 7,
      showDebug: true,
      disableAdvertisingIdentifier: false,
      disableCollectASA: false,
      manualStart: true,
    );
  }

  Future<void> crashDataStatsRequestTrackingPermission() async {
    if (Platform.isIOS) {
      final currentStatus = await AppTrackingTransparency.trackingAuthorizationStatus;

      if (currentStatus == TrackingStatus.notDetermined) {
        final status = await AppTrackingTransparency.requestTrackingAuthorization();
        crashDataStatsTrackingPermissionStatus = status.toString();

        if (status == TrackingStatus.authorized) {
          await crashDataStatsGetAdvertisingId();
        }

        crashDataStatsRequestPermissionOneSignal();
      } else {
        crashDataStatsTrackingPermissionStatus = currentStatus.toString();

        if (currentStatus == TrackingStatus.authorized) {
          await crashDataStatsGetAdvertisingId();
        }

        crashDataStatsRequestPermissionOneSignal();
      }
    } else {
      crashDataStatsTrackingPermissionStatus = 'not_applicable';
      crashDataStatsRequestPermissionOneSignal();
    }
  }

  Future<void> crashDataStatsGetAdvertisingId() async {
    try {
      crashDataStatsAdvertisingId = await AdvertisingId.id(true);
    } catch (_) {}
  }

  Future<String?> sendCrashDataStatsRequest(Map<dynamic, dynamic> parameters) async {
    try {
      final jsonString = json.encode(parameters);
      final base64Parameters = base64.encode(utf8.encode(jsonString));

      final requestBody = {crashDataStatsStandartWord: base64Parameters};

      final response = await http.post(
        Uri.parse(crashDataStatsUrl),
        body: requestBody,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
