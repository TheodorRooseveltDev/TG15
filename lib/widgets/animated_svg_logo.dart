import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AnimatedSvgLogo extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? backgroundColor;

  const AnimatedSvgLogo({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.backgroundColor,
  });

  @override
  State<AnimatedSvgLogo> createState() => _AnimatedSvgLogoState();
}

class _AnimatedSvgLogoState extends State<AnimatedSvgLogo> {
  late WebViewController _controller;
  bool _isLoading = true;
  String? _svgContent;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    try {
      final svgString = await rootBundle.loadString(widget.assetPath);
      setState(() {
        _svgContent = svgString;
        _isLoading = false;
      });
      _initWebView();
    } catch (e) {
      debugPrint('Error loading SVG: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initWebView() {
    if (_svgContent == null) return;

    final backgroundColor = widget.backgroundColor ?? Colors.transparent;
    final bgColorHex = '#${backgroundColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';

    final html =
        '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    html, body {
      width: 100%;
      height: 100%;
      background-color: ${backgroundColor == Colors.transparent ? 'transparent' : bgColorHex};
      overflow: hidden;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    svg {
      width: 100%;
      height: 100%;
      object-fit: ${_getObjectFit()};
    }
  </style>
</head>
<body>
  $_svgContent
</body>
</html>
''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(backgroundColor)
      ..loadHtmlString(html);
  }

  String _getObjectFit() {
    switch (widget.fit) {
      case BoxFit.contain:
        return 'contain';
      case BoxFit.cover:
        return 'cover';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitWidth:
        return 'contain';
      case BoxFit.fitHeight:
        return 'contain';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white54)),
        ),
      );
    }

    if (_svgContent == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Icon(Icons.broken_image_outlined, color: Colors.white38),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
