import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:vip_gaming_lounge/crash_data_stats/crash_data_stats.dart';
import 'package:vip_gaming_lounge/crash_data_stats/crash_data_stats_splash.dart';
import 'package:vip_gaming_lounge/crash_data_stats/crash_data_stats_web_view.dart';

class _CrashDataStatsChromeSafariBrowser extends ChromeSafariBrowser {
  final VoidCallback onBrowserClosed;

  _CrashDataStatsChromeSafariBrowser({required this.onBrowserClosed});

  @override
  void onClosed() {
    onBrowserClosed();
  }
}

class CrashDataStatsWebViewWidgetBackup extends StatefulWidget {
  const CrashDataStatsWebViewWidgetBackup({super.key});

  @override
  State<CrashDataStatsWebViewWidgetBackup> createState() => _CrashDataStatsWebViewWidgetBackupState();
}

class _CrashDataStatsWebViewWidgetBackupState extends State<CrashDataStatsWebViewWidgetBackup> {
  late _CrashDataStatsChromeSafariBrowser _browser;

  @override
  void initState() {
    super.initState();

    _browser = _CrashDataStatsChromeSafariBrowser(
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
        url: WebUri(crashDataStatsLink!),
        settings: ChromeSafariBrowserSettings(barCollapsingEnabled: true, entersReaderIfAvailable: false),
      );
    } catch (e) {
      if (mounted) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.black, body: CrashDataStatsSplash());
  }
}
