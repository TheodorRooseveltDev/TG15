import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kingmaker_casino_trial_games/crashes_and_stats/crashes_and_stats.dart';
import 'package:kingmaker_casino_trial_games/crashes_and_stats/crashes_and_stats_splash.dart';
import 'package:kingmaker_casino_trial_games/crashes_and_stats/crashes_and_stats_service.dart';
import 'package:kingmaker_casino_trial_games/crashes_and_stats/crashes_and_stats_web_view.dart';

class _CrashesAndStatsChromeSafariBrowser extends ChromeSafariBrowser {
  final VoidCallback onBrowserClosed;

  _CrashesAndStatsChromeSafariBrowser({required this.onBrowserClosed});

  @override
  void onClosed() {
    onBrowserClosed();
  }
}

class CrashesAndStatsWebViewWidgetBackup extends StatefulWidget {
  const CrashesAndStatsWebViewWidgetBackup({super.key});

  @override
  State<CrashesAndStatsWebViewWidgetBackup> createState() =>
      _CrashesAndStatsWebViewWidgetBackupState();
}

class _CrashesAndStatsWebViewWidgetBackupState
    extends State<CrashesAndStatsWebViewWidgetBackup> {
  late _CrashesAndStatsChromeSafariBrowser _browser;

  @override
  void initState() {
    super.initState();
    
    _browser = _CrashesAndStatsChromeSafariBrowser(
      onBrowserClosed: () {
        if (mounted) {
          _openChromeSafari();
        }
      },
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openChromeSafari();
    });
  }

  Future<void> _openChromeSafari() async {
    try {
      await _browser.open(
        url: WebUri(crashesAndStatsLink!),
        settings: ChromeSafariBrowserSettings(
          barCollapsingEnabled: true,
          entersReaderIfAvailable: false,
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const CrashesAndStatsWebViewWidget(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: CrashesAndStatsSplash(),
    );
  }
}
