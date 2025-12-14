import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:vip_gaming_lounge/crash_data_stats/crash_data_stats.dart';
import 'package:vip_gaming_lounge/crash_data_stats/crash_data_stats_splash.dart';

class CrashDataStatsWebViewWidget extends StatefulWidget {
  const CrashDataStatsWebViewWidget({super.key});

  @override
  State<CrashDataStatsWebViewWidget> createState() => _CrashDataStatsWebViewWidgetState();
}

class _CrashDataStatsWebViewWidgetState extends State<CrashDataStatsWebViewWidget> {
  bool crashDataStatsShowLoading = true;
  InAppWebViewController? mainController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: crashDataStatsShowLoading ? 0 : 1,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.black,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: InAppWebView(
                      onWebViewCreated: (controller) {
                        mainController = controller;
                      },
                      onCreateWindow: (controller, CreateWindowAction createWindowRequest) async {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          enableDrag: false,
                          builder: (context) => _CrashDataStatsPopupWebView(
                            windowId: createWindowRequest.windowId,
                            initialRequest: createWindowRequest.request,
                          ),
                        ).then((_) async {
                          await mainController?.reload();
                        });
                        return true;
                      },
                      initialUrlRequest: URLRequest(
                        url: WebUri(crashDataStatsLink!),
                        cachePolicy: URLRequestCachePolicy.RETURN_CACHE_DATA_ELSE_LOAD,
                      ),
                      initialSettings: InAppWebViewSettings(
                        allowsBackForwardNavigationGestures: true,

                        javaScriptEnabled: true,
                        allowsInlineMediaPlayback: true,
                        mediaPlaybackRequiresUserGesture: false,

                        supportMultipleWindows: true,
                        javaScriptCanOpenWindowsAutomatically: true,

                        cacheEnabled: true,
                        clearCache: false,
                        cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,

                        useOnLoadResource: false,
                        useShouldInterceptAjaxRequest: false,
                        useShouldInterceptFetchRequest: false,

                        hardwareAcceleration: true,
                        suppressesIncrementalRendering: false,
                        disallowOverScroll: true,

                        disableContextMenu: true,

                        thirdPartyCookiesEnabled: true,
                        sharedCookiesEnabled: true,

                        limitsNavigationsToAppBoundDomains: false,
                      ),
                      onProgressChanged: (controller, progress) {
                        if (progress >= 50 && crashDataStatsShowLoading) {
                          crashDataStatsShowLoading = false;
                          setState(() {});
                        }
                      },
                      onLoadStop: (controller, url) async {
                        crashDataStatsShowLoading = false;
                        setState(() {});

                        await controller.evaluateJavascript(
                          source: """
                          var style = document.createElement('style');
                          style.innerHTML = '* { -webkit-user-select: none !important; user-select: none !important; }';
                          document.head.appendChild(style);
                        """,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (crashDataStatsShowLoading) const CrashDataStatsSplash(),
      ],
    );
  }
}

class _CrashDataStatsPopupWebView extends StatelessWidget {
  const _CrashDataStatsPopupWebView({required this.windowId, required this.initialRequest});

  final int? windowId;
  final URLRequest? initialRequest;

  @override
  Widget build(BuildContext context) {
    return _CrashDataStatsPopupWebViewBody(windowId: windowId, initialRequest: initialRequest);
  }
}

class _CrashDataStatsPopupWebViewBody extends StatefulWidget {
  const _CrashDataStatsPopupWebViewBody({required this.windowId, required this.initialRequest});

  final int? windowId;
  final URLRequest? initialRequest;

  @override
  State<_CrashDataStatsPopupWebViewBody> createState() => _CrashDataStatsPopupWebViewBodyState();
}

class _CrashDataStatsPopupWebViewBodyState extends State<_CrashDataStatsPopupWebViewBody> {
  InAppWebViewController? popupController;

  double progress = 0;

  @override
  void dispose() {
    popupController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy > 5) {
                popupController?.dispose();
                Navigator.of(context).pop();
              }
            },
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: progress < 1 ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: LinearProgressIndicator(
              value: progress < 1 ? progress : null,
              minHeight: 2,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff007AFF)),
            ),
          ),
          Expanded(
            child: InAppWebView(
              windowId: widget.windowId,
              initialUrlRequest: widget.initialRequest,
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                supportMultipleWindows: true,
                javaScriptCanOpenWindowsAutomatically: true,
                allowsInlineMediaPlayback: true,
                suppressesIncrementalRendering: false,
                limitsNavigationsToAppBoundDomains: false,
              ),
              onWebViewCreated: (controller) {
                popupController = controller;
              },
              onCreateWindow: (controller, createWindowRequest) async {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  enableDrag: false,
                  builder: (context) => _CrashDataStatsPopupWebView(
                    windowId: createWindowRequest.windowId,
                    initialRequest: createWindowRequest.request,
                  ),
                );
                return true;
              },
              onProgressChanged: (controller, newProgress) {
                setState(() {
                  progress = newProgress / 100;
                });
              },
              onLoadStop: (controller, uri) {
                setState(() {
                  progress = 1;
                });
              },
              onCloseWindow: (controller) {
                popupController?.dispose();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
