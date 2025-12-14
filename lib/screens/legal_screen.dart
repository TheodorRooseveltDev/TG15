import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../constants/constants.dart';
import '../widgets/app_background.dart';

class LegalScreen extends StatefulWidget {
  final String type; // 'terms' or 'privacy'

  const LegalScreen({super.key, required this.type});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  double _progress = 0;
  bool _isLoading = true;

  String get title {
    switch (widget.type) {
      case 'terms':
        return 'Terms of Service';
      case 'privacy':
        return 'Privacy Policy';
      default:
        return 'Legal Information';
    }
  }

  String get url {
    switch (widget.type) {
      case 'terms':
        return 'https://vipgamingloungeapp.com/terms/';
      case 'privacy':
        return 'https://vipgamingloungeapp.com/privacy/';
      default:
        return 'https://vipgamingloungeapp.com';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.backgroundSecondary,
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
      ),
      body: Stack(
        children: [
          const AppBackground(),

          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              supportZoom: true,
              builtInZoomControls: true,
              displayZoomControls: false,
              useWideViewPort: true,
              loadWithOverviewMode: true,
              safeBrowsingEnabled: true,
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            ),
            onWebViewCreated: (controller) {},
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
                _progress = 0;
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
                _progress = 1.0;
              });
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
            onLoadError: (controller, url, code, message) {
              setState(() {
                _isLoading = false;
              });
            },
          ),

          if (_isLoading || _progress < 1.0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppColors.backgroundSecondary,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.purplePrimary),
              ),
            ),

          if (_isLoading)
            Container(
              color: AppColors.backgroundPrimary,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.purplePrimary),
                    const SizedBox(height: AppSpacing.md),
                    Text('Loading $title...', style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
