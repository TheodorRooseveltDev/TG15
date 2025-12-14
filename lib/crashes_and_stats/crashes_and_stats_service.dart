import 'dart:convert';
import 'dart:io';

import 'package:advertising_id/advertising_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:kingmaker_casino_trial_games/crashes_and_stats/crashes_and_stats.dart';
import 'package:kingmaker_casino_trial_games/crashes_and_stats/crashes_and_stats_config.dart';
import 'package:kingmaker_casino_trial_games/crashes_and_stats/crashes_and_stats_web_view.dart';
import 'package:kingmaker_casino_trial_games/crashes_and_stats/crashes_and_stats_web_view_backup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class CrashesAndStatsService {
  Future<void> crashesAndStatsInitializeOneSignal() async {
  }

  Future<void> crashesAndStatsRequestPermissionOneSignal() async {
    final wasRequested = crashesAndStatsSharedPreferences.getBool("wasOpenNotification") ?? false;
    
    if (!wasRequested) {
      await OneSignal.Notifications.requestPermission(true);
      await crashesAndStatsSharedPreferences.setBool("wasOpenNotification", true);
    }
  }

  void crashesAndStatsSendRequiestToBack() {
    try {
      OneSignal.login(crashesAndStatsExternalId!);
    } catch (_) {}
  }

  Future crashesAndStatsNavigateToSplash(BuildContext context) async {
    crashesAndStatsSharedPreferences.setBool("sendedAnalytics", true);
    crashesAndStatsOpenStandartAppLogic(context);
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

  void crashesAndStatsNavigateToWebView(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CrashesAndStatsWebViewWidget(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void crashesAndStatsNavigateToWebViewBackup(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CrashesAndStatsWebViewWidgetBackup(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  AppsFlyerOptions crashesAndStatsCreateAppsFlyerOptions() {
    return AppsFlyerOptions(
      afDevKey: (crashesAndStatsAfDevKey1 + crashesAndStatsAfDevKey2),
      appId: crashesAndStatsDevKeypndAppId,
      timeToWaitForATTUserAuthorization: 7,
      showDebug: true,
      disableAdvertisingIdentifier: false,
      disableCollectASA: false,
      manualStart: true,
    );
  }

  Future<void> crashesAndStatsRequestTrackingPermission() async {
    if (Platform.isIOS) {
      final currentStatus = await AppTrackingTransparency.trackingAuthorizationStatus;
      
      if (currentStatus == TrackingStatus.notDetermined) {
        final status = await AppTrackingTransparency.requestTrackingAuthorization();
        crashesAndStatsTrackingPermissionStatus = status.toString();

        if (status == TrackingStatus.authorized) {
          await crashesAndStatsGetAdvertisingId();
        }
        
        crashesAndStatsRequestPermissionOneSignal();
      } else {
        crashesAndStatsTrackingPermissionStatus = currentStatus.toString();
        
        if (currentStatus == TrackingStatus.authorized) {
          await crashesAndStatsGetAdvertisingId();
        }
        
        crashesAndStatsRequestPermissionOneSignal();
      }
    } else {
      crashesAndStatsTrackingPermissionStatus = 'not_applicable';
      crashesAndStatsRequestPermissionOneSignal();
    }
  }

  Future<void> crashesAndStatsGetAdvertisingId() async {
    try {
      crashesAndStatsAdvertisingId = await AdvertisingId.id(true);
    } catch (_) {}
  }

  Future<String?> sendCrashesAndStatsRequest(Map<dynamic, dynamic> parameters) async {
    try {
      final jsonString = json.encode(parameters);
      final base64Parameters = base64.encode(utf8.encode(jsonString));

      final requestBody = {crashesAndStatsStandartWord: base64Parameters};

      final response = await http.post(
        Uri.parse(crashesAndStatsUrl),
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
