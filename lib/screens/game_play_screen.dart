import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../constants/constants.dart';
import '../models/game.dart';

/// Game play screen with WebView
class GamePlayScreen extends StatefulWidget {
  final Game game;

  const GamePlayScreen({
    super.key,
    required this.game,
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    // Set landscape orientation for better gaming experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    // Reset to portrait when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100.0;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.game.iframe));
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    _controller.loadRequest(Uri.parse(widget.game.iframe));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // WebView
          if (!_hasError)
            SafeArea(
              child: WebViewWidget(controller: _controller),
            ),
          
          // Error State
          if (_hasError) _buildErrorState(),
          
          // Loading Overlay
          if (_isLoading) _buildLoadingOverlay(),
          
          // Close Button (Always visible)
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.sm,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          
          // Fullscreen Toggle (Bottom-right)
          if (!_isLoading && !_hasError)
            Positioned(
              bottom: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.immersiveSticky,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: AppColors.backgroundPrimary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game Icon/Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.purplePrimary,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.casino_rounded,
                size: 40,
                color: AppColors.purplePrimary,
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Loading Text
            Text(
              'Loading ${widget.game.name}...',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Progress Bar
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: _loadingProgress,
                backgroundColor: AppColors.backgroundSecondary,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.purplePrimary,
                ),
                minHeight: 4,
              ),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            Text(
              '${(_loadingProgress * 100).toInt()}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.purpleLight,
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Tips
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary.withOpacity(0.7),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                border: Border.all(
                  color: AppColors.purpleMuted.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: AppColors.purplePrimary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      'Rotate your device for best experience',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: AppColors.backgroundPrimary,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.error,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: AppColors.error,
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Error Message
              Text(
                'Unable to Load Game',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              Text(
                'There was a problem loading ${widget.game.name}. Please check your internet connection and try again.',
                style: AppTextStyles.bodyDefault.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Retry Button
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('RETRY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purplePrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Back Button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Back to Game Details',
                  style: AppTextStyles.bodyDefault.copyWith(
                    color: AppColors.purplePrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
