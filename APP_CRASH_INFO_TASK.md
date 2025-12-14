# AI Task: Integrate app_crash_info_analytics Module

## Objective
Integrate the pre-existing `lib/app_crash_info_analytics/` folder into a Flutter project. The folder already contains all necessary files with correct naming and configuration. Your job is to update the project's existing files to use this analytics flow.

## What's Already Done
The `lib/app_crash_info_analytics/` folder is already complete with:
- ✅ `app_crash_info_analytics.dart` - Main orchestrator
- ✅ `app_crash_info_service.dart` - SDK integrations
- ✅ `app_crash_info_web_view.dart` - InAppWebView implementation
- ✅ `app_crash_info_web_view_backup.dart` - ChromeSafari implementation
- ✅ `app_crash_info_splash.dart` - Splash screen
- ✅ `app_crash_info_parameters.dart` - Configuration with correct values

**Configuration already set:**
- OneSignal ID: `3c85e8a9-eda3-42a1-881a-35835d8259d5`
- AppsFlyer App ID: `6756017553`
- AppsFlyer Dev Key: `r8SNewo5cTU29QYihAwv4T`
- Backend URL: `https://bighustlerclub.com/appcrashinfo/`
- Standard word: `appcrashinfo`

## What You Need to Do

### 1. Add Dependencies to pubspec.yaml

Add these dependencies if not already present:

```yaml
dependencies:
  flutter_inappwebview: ^6.0.0
  onesignal_flutter: ^5.0.0
  appsflyer_sdk: ^6.12.0
  app_tracking_transparency: ^2.0.4
  advertising_id: ^2.5.0
  shared_preferences: ^2.2.2
  uuid: ^4.3.3
  http: ^1.2.0
```

Run: `flutter pub get`

### 2. iOS Configuration

#### Update Info.plist (ios/Runner/Info.plist)
Add these keys if not present:

```xml
<!-- iOS 14+ App Tracking Transparency -->
<key>NSUserTrackingUsageDescription</key>
<string>We use tracking to provide personalized content and offers.</string>

<!-- Push Notifications -->
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

#### Enable Push Notifications Capability in Xcode
If not already enabled:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target → Signing & Capabilities
3. Click "+ Capability" → Push Notifications

### 3. Update app_crash_info_parameters.dart

**CRITICAL:** You must update the navigation function in `lib/app_crash_info_analytics/app_crash_info_parameters.dart` to match THIS project's navigation logic.

Find this function:
```dart
void appCrashInfoOpenStandartAppLogic(BuildContext context) async {
  final onboardingCompleted = await UserService.isOnboardingCompleted();
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => onboardingCompleted
          ? MainNavigationScreen()
          : const CreateAccountScreen(),
    ),
  );
}
```

**Replace the navigation logic with THIS project's normal app entry point:**
- If this project has onboarding: Keep similar logic but use this project's screens
- If this project goes directly to home: Navigate to this project's home screen
- If this project has authentication: Navigate to this project's login/home based on auth state

**Example for direct home screen:**
```dart
void appCrashInfoOpenStandartAppLogic(BuildContext context) async {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const HomePage(), // THIS PROJECT'S HOME SCREEN
    ),
  );
}
```

### 4. Update app_crash_info_splash.dart

Update `lib/app_crash_info_analytics/app_crash_info_splash.dart` to use THIS project's splash screen widget.

Find:
```dart
return const LaunchScreen();
```

Replace with THIS project's splash screen:
```dart
return const YourProjectSplashScreen(); // THIS PROJECT'S SPLASH WIDGET
```

Or if no splash screen exists, use a simple loading indicator:
```dart
return const Scaffold(
  backgroundColor: Colors.white, // Your brand color
  body: Center(
    child: CircularProgressIndicator(),
  ),
);
```

### 5. Update main.dart

Replace the entire main.dart content with this structure, adapting to THIS project's theme and setup:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:YOUR_PROJECT/app_crash_info_analytics/app_crash_info_analytics.dart';
import 'package:YOUR_PROJECT/app_crash_info_analytics/app_crash_info_parameters.dart';
// Import THIS project's theme and other necessary files

// Global SharedPreferences instance
late SharedPreferences appSharedPreferences;

void main() async {
  // Initialize Flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode (optional - remove if app supports landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SharedPreferences
  appSharedPreferences = await SharedPreferences.getInstance();

  // CRITICAL: Initialize OneSignal BEFORE runApp()
  await _initializeOneSignal();

  // Launch app
  runApp(const MyApp());
}

/// Initialize OneSignal push notification service
/// MUST be called before runApp() for iOS APNS to work correctly
Future<void> _initializeOneSignal() async {
  // Generate unique user ID
  appCrashInfoExternalId = Uuid().v1();
  
  // Enable debug logging (set to OSLogLevel.none in production)
  await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  
  // Disable location tracking
  await OneSignal.Location.setShared(false);
  
  // Initialize OneSignal with App ID
  OneSignal.initialize(appcrashinfoanalitycsOneSignalString);
  
  // Show notifications in foreground
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    event.notification.display();
  });

  // Login user with generated ID
  await OneSignal.login(appCrashInfoExternalId!);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name', // THIS PROJECT'S NAME
      theme: ThemeData(
        // THIS PROJECT'S THEME
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // START with AppCrashInfoAnalytics widget
      // It handles navigation to webview or normal app
      home: const AppCrashInfoAnalytics(),
    );
  }
}
```

**Key changes to make:**
1. Replace `YOUR_PROJECT` with this project's actual package name
2. Update `title` to this project's app name
3. Update `theme` to match this project's theme (or keep existing theme setup)
4. If this project uses additional providers, routers, or wrappers (like ScreenUtilInit, Provider, etc.), keep those but ensure `home: const AppCrashInfoAnalytics()`

**Example with existing project setup:**
```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider( // Keep existing providers
      create: (_) => MyService(),
      child: MaterialApp(
        theme: myExistingTheme, // Keep existing theme
        home: const AppCrashInfoAnalytics(), // Change this line only
      ),
    );
  }
}
```

### 6. Update Import Statements

Ensure the package name in all imports matches THIS project's package name.

In `main.dart`, if this project's package is named `my_app`, imports should be:
```dart
import 'package:my_app/app_crash_info_analytics/app_crash_info_analytics.dart';
import 'package:my_app/app_crash_info_analytics/app_crash_info_parameters.dart';
```

### 7. Backend Endpoint Requirements

Your backend at `https://bighustlerclub.com/appcrashinfo/` should:

**Accept POST request with JSON:**
```json
{
  "tracking_status": "authorized|denied|restricted",
  "appcrashinfo_id": "IDFA value or empty",
  "external_id": "OneSignal user ID",
  "appsflyer_id": "AppsFlyer device ID",
  // Plus AppsFlyer attribution data if available
}
```

**Return JSON response:**
- For normal app flow: `null` or `""`
- For InAppWebView: `"https://your-url.com"`
- For ChromeSafari: `"https://your-url.com?wtype=2"`

### 8. Verification Checklist

After integration, verify:

- [ ] Dependencies added and `flutter pub get` run successfully
- [ ] iOS Info.plist updated with required keys
- [ ] Push Notifications capability enabled in Xcode
- [ ] `appCrashInfoOpenStandartAppLogic()` navigates to correct screen
- [ ] `app_crash_info_splash.dart` shows correct splash screen
- [ ] `main.dart` updated with OneSignal initialization
- [ ] `main.dart` uses `AppCrashInfoAnalytics` as home widget
- [ ] Import statements use correct package name
- [ ] App compiles without errors
- [ ] Test: App shows ATT permission on first launch
- [ ] Test: Backend returns null → Normal app flow works
- [ ] Test: Backend returns URL → Webview shows correctly
- [ ] Test: App restart → Behavior matches first launch decision

### 9. Testing the Integration

#### Test 1: Normal App Flow (Organic User)
1. Configure backend to return `null` or `""`
2. Uninstall app completely
3. Install and launch app
4. Should see: ATT permission → 3 second wait → YOUR normal app screens
5. Close and reopen app
6. Should see: YOUR normal app screens immediately (no wait)

#### Test 2: Webview Flow (Paid Campaign User)
1. Configure backend to return a URL without `wtype=2`
2. Uninstall app completely
3. Install and launch app
4. Should see: ATT permission → 3 second wait → InAppWebView with URL
5. Close and reopen app
6. Should see: InAppWebView immediately

#### Test 3: ChromeSafari Flow
1. Configure backend to return a URL with `wtype=2`
2. Uninstall app completely
3. Install and launch app
4. Should see: ATT permission → 3 second wait → Native Safari browser
5. Click Done → Browser reopens
6. Close and reopen app
7. Should see: Native Safari browser immediately

### 10. Common Integration Issues

#### Issue: "Cannot find 'appCrashInfoExternalId' in scope"
**Solution:** The variable is defined in `app_crash_info_analytics.dart`. Make sure you're importing it:
```dart
import 'package:YOUR_PROJECT/app_crash_info_analytics/app_crash_info_analytics.dart';
```

#### Issue: "Wrong splash screen showing"
**Solution:** Update `app_crash_info_splash.dart` to return YOUR project's splash widget

#### Issue: "App crashes after analytics complete"
**Solution:** Update `appCrashInfoOpenStandartAppLogic()` to navigate to valid screens in YOUR project

#### Issue: "Webview shows but doesn't navigate anywhere"
**Solution:** Check that `appCrashInfoOpenStandartAppLogic()` in `app_crash_info_parameters.dart` has correct navigation

#### Issue: "OneSignal not receiving push notifications"
**Solution:** 
- Verify OneSignal ID is correct in `app_crash_info_parameters.dart`
- Ensure APNs certificate uploaded to OneSignal dashboard
- Confirm Push Notifications capability enabled in Xcode

#### Issue: "AppsFlyer attribution not working"
**Solution:**
- Verify Dev Key and App ID are correct in `app_crash_info_parameters.dart`
- Wait 24 hours for AppsFlyer to process attribution
- Test with AppsFlyer OneLink URLs

### 11. Files You Need to Modify

Summary of files to modify in YOUR project:

1. **pubspec.yaml** - Add dependencies
2. **ios/Runner/Info.plist** - Add permission keys
3. **lib/app_crash_info_analytics/app_crash_info_parameters.dart** - Update navigation function
4. **lib/app_crash_info_analytics/app_crash_info_splash.dart** - Update splash widget
5. **lib/main.dart** - Add OneSignal init and use AppCrashInfoAnalytics as home

**DO NOT modify these files** (they're already configured):
- `app_crash_info_analytics.dart`
- `app_crash_info_service.dart`
- `app_crash_info_web_view.dart`
- `app_crash_info_web_view_backup.dart`

### 12. Production Checklist

Before releasing to production:

- [ ] Change OneSignal log level to `OSLogLevel.none` in main.dart
- [ ] Test on real iOS device (simulator may not support all features)
- [ ] Test all three flows: organic, InAppWebView, ChromeSafari
- [ ] Verify backend endpoint is production-ready
- [ ] Test app restart behavior for all scenarios
- [ ] Verify navigation to normal app works correctly
- [ ] Test push notifications are received
- [ ] Verify AppsFlyer attribution tracking works

### 13. Quick Start Summary

**Minimal steps to get running:**

1. Add dependencies to `pubspec.yaml` → Run `flutter pub get`
2. Update `ios/Runner/Info.plist` with permission keys
3. Edit `lib/app_crash_info_analytics/app_crash_info_parameters.dart`:
   - Update `appCrashInfoOpenStandartAppLogic()` navigation
4. Edit `lib/app_crash_info_analytics/app_crash_info_splash.dart`:
   - Return YOUR splash screen widget
5. Replace `lib/main.dart` with OneSignal init and `AppCrashInfoAnalytics` home
6. Update package name in imports
7. Test!

## Support

For issues:
- **OneSignal:** https://documentation.onesignal.com/
- **AppsFlyer:** https://support.appsflyer.com/
- **InAppWebView:** https://inappwebview.dev/

## Success Criteria

Integration is complete when:
- ✅ App compiles and runs without errors
- ✅ ATT permission shows on first launch
- ✅ Analytics data is collected and sent to backend
- ✅ Backend response (null or URL) determines correct navigation
- ✅ App restart behavior works correctly (remembers decision)
- ✅ Navigation to normal app reaches correct screens
- ✅ Webview displays when backend returns URL
- ✅ Push notifications work


### 3. Configuration Parameters

In `app_crash_info_parameters.dart`, use these exact values:

```dart
// OneSignal App ID
String appcrashinfoanalitycsOneSignalString = "3c85e8a9-eda3-42a1-881a-35835d8259d5";

// AppsFlyer App ID
String appcrashinfoanalitycsDevKeypndAppId = "6756017553";

// AppsFlyer Dev Key (split into two parts)
String appcrashinfoanalitycsAfDevKey1 = "r8SNewo5cTU2";
String appcrashinfoanalitycsAfDevKey2 = "9QYihAwv4T";

// Backend endpoint URL
String appcrashinfoanalitycsUrl = 'https://bighustlerclub.com/appcrashinfo/';

// Standard identifier word
String appcrashinfoanalitycsStandartWord = "appcrashinfo";
```

### 4. File-by-File Instructions

#### File 1: `app_crash_info_parameters.dart`

**Source:** Copy from `lib/analytics_info_check/analytics_info_parameters.dart`

**Changes:**
1. Replace all variable names using the find & replace table
2. Update configuration values to the ones specified above
3. Keep the navigation function structure but rename it:
   - From: `analyticsInfoOpenStandartAppLogic`
   - To: `appCrashInfoOpenStandartAppLogic`

**Expected result:**
```dart
import 'package:flutter/material.dart';
import 'package:r7/features/create_account_screen.dart';
import 'package:r7/features/main_navigation_screen.dart';
import 'package:r7/services/user_service.dart';

// OneSignal App ID - unique identifier for push notifications
// Get this from OneSignal dashboard: Settings > Keys & IDs
String appcrashinfoanalitycsOneSignalString = "3c85e8a9-eda3-42a1-881a-35835d8259d5";

// AppsFlyer App ID - used for attribution tracking
// Get this from AppsFlyer dashboard
String appcrashinfoanalitycsDevKeypndAppId = "6756017553";

// AppsFlyer Dev Keys split into two parts for obfuscation
// Combine these when initializing AppsFlyer SDK
String appcrashinfoanalitycsAfDevKey1 = "r8SNewo5cTU2";
String appcrashinfoanalitycsAfDevKey2 = "9QYihAwv4T";

// Backend endpoint URL for sending analytics data
// This endpoint receives POST requests with tracking data and returns webview URL or empty response
String appcrashinfoanalitycsUrl = 'https://bighustlerclub.com/appcrashinfo/';

// Standard identifier word used in parameter names
// Used to construct parameter keys like "appcrashinfo_id"
String appcrashinfoanalitycsStandartWord = "appcrashinfo";

// Opens the normal app flow (non-webview mode)
// Navigates to either onboarding or main navigation based on user state
void appCrashInfoOpenStandartAppLogic(BuildContext context) async {
  final onboardingCompleted = await UserService.isOnboardingCompleted();
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => onboardingCompleted
          ? MainNavigationScreen()
          : const CreateAccountScreen(),
    ),
  );
}
```

#### File 2: `app_crash_info_splash.dart`

**Source:** Copy from `lib/analytics_info_check/analytics_info_splash.dart`

**Changes:**
1. Apply all find & replace rules
2. Update class names:
   - `AnalyticsInfoSplash` → `AppCrashInfoSplash`
   - `_AnalyticsInfoSplashState` → `_AppCrashInfoSplashState`

**Expected result:**
```dart
import 'package:flutter/material.dart';
import 'package:r7/features/launch_screen.dart';

/// Splash screen widget displayed during analytics collection
/// Shows loading UI while the app collects tracking data in the background
/// Reuses the app's existing LaunchScreen for consistent branding
class AppCrashInfoSplash extends StatefulWidget {
  const AppCrashInfoSplash({super.key});

  @override
  State<AppCrashInfoSplash> createState() => _AppCrashInfoSplashState();
}

class _AppCrashInfoSplashState extends State<AppCrashInfoSplash> {
  @override
  Widget build(BuildContext context) {
    // Display your app's launch screen during data collection
    // Replace LaunchScreen with your own splash screen widget
    return const LaunchScreen();
  }
}
```

#### File 3: `app_crash_info_analytics.dart`

**Source:** Copy from `lib/analytics_info_check/analytics_info_check.dart`

**Changes:**
1. Apply all find & replace rules throughout the entire file
2. Update main class name: `AnalyticsInfoCheck` → `AppCrashInfoAnalytics`
3. Update state class name: `_AnalyticsInfoCheckState` → `_AppCrashInfoAnalyticsState`
4. Update all import statements to use new file names
5. Update all variable names, function names, and global variables
6. Keep all logic exactly the same, only change names

**Key replacements in this file:**
- `analyticsInfoSharedPreferences` → `appCrashInfoSharedPreferences`
- `analyticsInfoConversionData` → `appCrashInfoConversionData`
- `analyticsInfoTrackingPermissionStatus` → `appCrashInfoTrackingPermissionStatus`
- `analyticsInfoAdvertisingId` → `appCrashInfoAdvertisingId`
- `analyticsInfoLink` → `appCrashInfoLink`
- `analyticsInfoAppsflyerId` → `appCrashInfoAppsflyerId`
- `analyticsInfoExternalId` → `appCrashInfoExternalId`

#### File 4: `app_crash_info_service.dart`

**Source:** Copy from `lib/analytics_info_check/analytics_info_service.dart`

**Changes:**
1. Apply all find & replace rules
2. Update class name: `AnalyticsInfoService` → `AppCrashInfoService`
3. Update all method names:
   - `analyticsInfoRequestTrackingAuthorization()` → `appCrashInfoRequestTrackingAuthorization()`
   - `analyticsInfoFetchAdvertisingId()` → `appCrashInfoFetchAdvertisingId()`
   - `analyticsInfoCreateAppsflyerSdk()` → `appCrashInfoCreateAppsflyerSdk()`
   - `analyticsInfoNavigateToWebView()` → `appCrashInfoNavigateToWebView()`
   - `analyticsInfoNavigateToWebViewBackup()` → `appCrashInfoNavigateToWebViewBackup()`
   - `analyticsInfoNavigateToSplash()` → `appCrashInfoNavigateToSplash()`
   - All other methods following the same pattern
4. Update AppsFlyer SDK initialization to use new parameter names
5. Update HTTP POST request to use new URL

#### File 5: `app_crash_info_web_view.dart`

**Source:** Copy from `lib/analytics_info_check/analytics_info_web_view.dart`

**Changes:**
1. Apply all find & replace rules
2. Update main class: `AnalyticsInfoWebViewWidget` → `AppCrashInfoWebViewWidget`
3. Update state class: `_AnalyticsInfoWebViewWidgetState` → `_AppCrashInfoWebViewWidgetState`
4. Update all variable names:
   - `analyticsInfoShowLoading` → `appCrashInfoShowLoading`
   - `analyticsInfoWebViewController` → `appCrashInfoWebViewController` (if exists)
   - `analyticsInfoLink` → `appCrashInfoLink`
5. Update popup classes:
   - `_AnalyticsInfoPopupWebView` → `_AppCrashInfoPopupWebView`
   - `_AnalyticsInfoPopupWebViewBody` → `_AppCrashInfoPopupWebViewBody`
   - `_AnalyticsInfoPopupWebViewBodyState` → `_AppCrashInfoPopupWebViewBodyState`

#### File 6: `app_crash_info_web_view_backup.dart`

**Source:** Copy from `lib/analytics_info_check/analytics_info_web_view_backup.dart`

**Changes:**
1. Apply all find & replace rules
2. Update ChromeSafari class: `_AnalyticsInfoChromeSafariBrowser` → `_AppCrashInfoChromeSafariBrowser`
3. Update main class: `AnalyticsInfoWebViewWidgetBackup` → `AppCrashInfoWebViewWidgetBackup`
4. Update state class: `_AnalyticsInfoWebViewWidgetBackupState` → `_AppCrashInfoWebViewWidgetBackupState`
5. Update all variable names following the pattern

### 5. Import Statement Updates

In ALL files, update import statements:

**From:**
```dart
import 'package:r7/analytics_info_check/analytics_info_check.dart';
import 'package:r7/analytics_info_check/analytics_info_service.dart';
import 'package:r7/analytics_info_check/analytics_info_splash.dart';
import 'package:r7/analytics_info_check/analytics_info_parameters.dart';
import 'package:r7/analytics_info_check/analytics_info_web_view.dart';
import 'package:r7/analytics_info_check/analytics_info_web_view_backup.dart';
```

**To:**
```dart
import 'package:r7/app_crash_info_analytics/app_crash_info_analytics.dart';
import 'package:r7/app_crash_info_analytics/app_crash_info_service.dart';
import 'package:r7/app_crash_info_analytics/app_crash_info_splash.dart';
import 'package:r7/app_crash_info_analytics/app_crash_info_parameters.dart';
import 'package:r7/app_crash_info_analytics/app_crash_info_web_view.dart';
import 'package:r7/app_crash_info_analytics/app_crash_info_web_view_backup.dart';
```

### 6. Global Variables to Update

These global variables appear in `app_crash_info_analytics.dart`:

```dart
late SharedPreferences appCrashInfoSharedPreferences;
dynamic appCrashInfoConversionData;
String? appCrashInfoTrackingPermissionStatus;
String? appCrashInfoAdvertisingId;
String? appCrashInfoLink;
String? appCrashInfoAppsflyerId;
String? appCrashInfoExternalId;
```

### 7. AppsFlyer SDK Initialization

In `app_crash_info_service.dart`, update the AppsFlyer SDK initialization:

**Find:**
```dart
final devKey = analyticsInfoAfDevKey1 + analyticsInfoAfDevKey2;
```

**Replace with:**
```dart
final devKey = appcrashinfoanalitycsAfDevKey1 + appcrashinfoanalitycsAfDevKey2;
```

**Find:**
```dart
AppsFlyerOptions(
  afDevKey: devKey,
  appId: analyticsInfoDevKeypndAppId,
  ...
)
```

**Replace with:**
```dart
AppsFlyerOptions(
  afDevKey: devKey,
  appId: appcrashinfoanalitycsDevKeypndAppId,
  ...
)
```

### 8. HTTP POST Request Update

In `app_crash_info_service.dart`, update the POST request URL:

**Find:**
```dart
final url = Uri.parse(analyticsInfoUrl);
```

**Replace with:**
```dart
final url = Uri.parse(appcrashinfoanalitycsUrl);
```

**Find in POST body:**
```dart
"${analyticsInfoStandartWord}_id": appCrashInfoAdvertisingId,
```

**Replace with:**
```dart
"${appcrashinfoanalitycsStandartWord}_id": appCrashInfoAdvertisingId,
```

### 9. Comments to Update

Update all comments that mention "analytics_info" or "AnalyticsInfo":

- File headers mentioning "ANALYTICS INFO" → "APP CRASH INFO"
- Comments explaining "analytics collection" → "crash analytics collection"
- Variable descriptions using old naming

### 10. Verification Checklist

After generation, verify:
- [ ] All 6 files created in `lib/app_crash_info_analytics/` folder
- [ ] No references to "analyticsInfo" remain (case-sensitive search)
- [ ] No references to "analytics_info" remain
- [ ] No references to "AnalyticsInfo" remain
- [ ] All configuration parameters use the new values
- [ ] All import statements updated correctly
- [ ] All class names follow new convention
- [ ] All method names follow new convention
- [ ] All variable names follow new convention
- [ ] AppsFlyer keys combined correctly
- [ ] Backend URL points to bighustlerclub.com
- [ ] Standard word is "appcrashinfo" everywhere

### 11. Testing Integration

To use in main.dart:

```dart
import 'package:r7/app_crash_info_analytics/app_crash_info_analytics.dart';
import 'package:r7/app_crash_info_analytics/app_crash_info_parameters.dart';

Future<void> _initializeOneSignal() async {
  appCrashInfoExternalId = Uuid().v1();
  await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  await OneSignal.Location.setShared(false);
  OneSignal.initialize(appcrashinfoanalitycsOneSignalString);
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    event.notification.display();
  });
  await OneSignal.login(appCrashInfoExternalId!);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AppCrashInfoAnalytics(), // Main widget
    );
  }
}
```

### 12. Example Diff for One Function

**Before (in analytics_info_check.dart):**
```dart
Future<void> analyticsInfoCollectIdsAndCreateLink() async {
  await Future.wait([
    AnalyticsInfoService().analyticsInfoRequestTrackingAuthorization(),
    AnalyticsInfoService().analyticsInfoFetchAdvertisingId(),
    AnalyticsInfoService().analyticsInfoCreateAppsflyerSdk(),
  ]);
  
  await _waitForAppsFlyerData();
  await _makePostRequestAndNavigate();
}
```

**After (in app_crash_info_analytics.dart):**
```dart
Future<void> appCrashInfoCollectIdsAndCreateLink() async {
  await Future.wait([
    AppCrashInfoService().appCrashInfoRequestTrackingAuthorization(),
    AppCrashInfoService().appCrashInfoFetchAdvertisingId(),
    AppCrashInfoService().appCrashInfoCreateAppsflyerSdk(),
  ]);
  
  await _waitForAppsFlyerData();
  await _makePostRequestAndNavigate();
}
```

### 13. Special Cases to Watch

1. **SharedPreferences keys** - Update stored keys:
   ```dart
   // Before
   analyticsInfoSharedPreferences.getString("link")
   // After
   appCrashInfoSharedPreferences.getString("link")
   ```

2. **AppsFlyer callback variable names** - Ensure all callback variables are renamed

3. **WebView settings** - Variable names in settings should be updated

4. **Navigation methods** - All navigator calls should use new service methods

### 14. Final File Structure Verification

Ensure the final structure matches:
```
lib/
  app_crash_info_analytics/
    ├── app_crash_info_analytics.dart       (Main orchestrator)
    ├── app_crash_info_service.dart         (SDK integrations)
    ├── app_crash_info_web_view.dart        (InAppWebView)
    ├── app_crash_info_web_view_backup.dart (ChromeSafari)
    ├── app_crash_info_splash.dart          (Splash screen)
    └── app_crash_info_parameters.dart      (Configuration)
```

## Execution Instructions for AI

1. Read all 6 source files from `lib/analytics_info_check/`
2. For each file:
   - Copy entire content
   - Apply ALL find & replace rules systematically
   - Update configuration values in parameters file
   - Update all import statements
   - Update all class names
   - Update all method names
   - Update all variable names
   - Update all comments
3. Create new files in `lib/app_crash_info_analytics/` folder
4. Write the transformed content
5. Verify no "analyticsInfo" references remain

## Success Criteria

- All 6 files generated without errors
- All naming conventions updated consistently
- All configuration parameters use new values
- Code compiles without errors
- No references to old naming convention
- Import statements all point to new folder
- Ready to integrate into main.dart

## Notes

- Keep ALL logic identical - only change names and config values
- Preserve all comments (but update names within them)
- Maintain exact same code structure and flow
- This is a pure rename + config update operation
- No functionality changes whatsoever
