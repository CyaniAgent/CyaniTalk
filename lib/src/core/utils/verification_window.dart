import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '/src/core/utils/logger.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';

/// WAF 验证窗口
class VerificationWindow extends StatefulWidget {
  final String url;

  const VerificationWindow({super.key, required this.url});

  /// 显示 WAF 验证窗口
  static Future<String?> show(BuildContext context, String url) async {
    return await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VerificationWindow(url: url),
    );
  }

  @override
  State<VerificationWindow> createState() => _VerificationWindowState();
}

class _VerificationWindowState extends State<VerificationWindow> {
  InAppWebViewController? _webViewController;
  Timer? _cookieTimer;
  bool _isWebviewLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  void _startCookieCheck() {
    _cookieTimer?.cancel();
    _cookieTimer = Timer.periodic(const Duration(milliseconds: 1000), (
      timer,
    ) async {
      try {
        final cookiesString = await _webViewController?.evaluateJavascript(
          source: 'document.cookie',
        );

        if (cookiesString != null && cookiesString.isNotEmpty) {
          final cookies = cookiesString.split(';');
          for (final cookie in cookies) {
            final parts = cookie.trim().split('=');
            if (parts.isNotEmpty && parts[0] == 'acw_sc__v2') {
              if (parts.length > 1) {
                _onVerificationSuccess(parts[1]);
                return;
              }
            }
          }
        }
      } catch (e) {
        logger.warning('VerificationWindow: Failed to parse verification cookie', e);
      }
    });
  }

  void _onVerificationSuccess(String cookieValue) {
    _cookieTimer?.cancel();
    if (mounted) {
      Navigator.of(context).pop(cookieValue);
    }
  }

  @override
  void dispose() {
    _cookieTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.linux;

    return Center(
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        elevation: 8,
        child: Container(
          width: isDesktop ? 800 : double.infinity,
          height: isDesktop ? 600 : double.infinity,
          margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Container(
                height: 48,
                color: Theme.of(context).colorScheme.surfaceContainer,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Security Verification',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(widget.url),
                      ),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        transparentBackground: true,
                        useShouldOverrideUrlLoading: false,
                      ),
                      onWebViewCreated: (controller) {
                        _webViewController = controller;
                      },
                      onLoadStop: (controller, url) {
                        if (!_isWebviewLoaded) {
                          setState(() {
                            _isWebviewLoaded = true;
                          });
                          _startCookieCheck();
                        }
                      },
                    ),
                    if (!_isWebviewLoaded)
                      const Center(child: CyaniLoadingIndicator()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
