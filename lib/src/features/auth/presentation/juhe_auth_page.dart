import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api/juhe_auth_api.dart';
import '../../../core/utils/logger.dart';

class JuheAuthPage extends StatefulWidget {
  final String type; // 'qq' or 'wx'
  final JuheAuthApi api;

  const JuheAuthPage({super.key, required this.type, required this.api});

  @override
  State<JuheAuthPage> createState() => _JuheAuthPageState();
}

class _JuheAuthPageState extends State<JuheAuthPage> {
  late final WebViewController _controller;
  bool _loading = true;
  String? _loginUrl;
  late final String _state;

  @override
  void initState() {
    super.initState();
    _state = const Uuid().v4();
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      final result = await widget.api.getLoginUrl(widget.type, _state);
      if (result['code'] == 0 && result['url'] != null) {
        setState(() {
          _loginUrl = result['url'];
        });
        _setupController();
      } else {
        if (mounted) {
          Navigator.pop(context, {
            'error': result['msg'] ?? 'Failed to get login URL',
          });
        }
      }
    } catch (e) {
      logger.error('JuheAuthPage: Error getting login URL', e);
      if (mounted) {
        Navigator.pop(context, {'error': e.toString()});
      }
    }
  }

  void _setupController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _loading = true);
          },
          onPageFinished: (String url) {
            setState(() => _loading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(widget.api.callback)) {
              _handleCallback(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_loginUrl!));
  }

  Future<void> _handleCallback(String url) async {
    logger.info('JuheAuthPage: Callback reached: $url');
    final uri = Uri.parse(url);
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];

    if (state != _state) {
      Navigator.pop(context, {'error': 'State mismatch (CSRF protection)'});
      return;
    }

    if (code != null) {
      setState(() => _loading = true);
      try {
        final result = await widget.api.callbackAuth(code);
        if (mounted) {
          Navigator.pop(context, result);
        }
      } catch (e) {
        logger.error('JuheAuthPage: Error in callbackAuth', e);
        if (mounted) {
          Navigator.pop(context, {'error': e.toString()});
        }
      }
    } else {
      Navigator.pop(context, {'error': 'No code found in callback'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == 'qq' ? 'auth_login_qq'.tr() : 'auth_login_wechat'.tr(),
        ),
      ),
      body: Stack(
        children: [
          if (_loginUrl != null)
            WebViewWidget(controller: _controller)
          else
            const Center(child: CircularProgressIndicator()),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
