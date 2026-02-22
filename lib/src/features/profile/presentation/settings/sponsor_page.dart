// 赞助页面
//
// 该文件包含SponsorPage组件和iMikufansDonatePage组件，用于显示应用程序的赞助信息。
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:webview_windows/webview_windows.dart' as windows;
import 'package:webview_flutter/webview_flutter.dart' as mobile;

/// 应用程序的赞助页面组件
///
/// 显示应用程序的赞助信息，目前为占位符实现。
class SponsorPage extends StatelessWidget {
  /// 创建一个新的SponsorPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const SponsorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('sponsor_title'.tr())),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // 说明内容
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无赞助渠道',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      '但是你可以赞助iMikufans，因为iMikufans才让我们聚集在一起开发了这个应用',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // iMikufans赞助选项
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('赞助iMikufans'),
                  subtitle: const Text('访问iMikufans赞助页面'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IMikufansDonatePage(),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// iMikufans赞助页面组件
///
/// 嵌入iMikufans的赞助页面网页
class IMikufansDonatePage extends StatefulWidget {
  /// 创建一个新的IMikufansDonatePage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const IMikufansDonatePage({super.key});

  @override
  State<IMikufansDonatePage> createState() => _IMikufansDonatePageState();
}

class _IMikufansDonatePageState extends State<IMikufansDonatePage> {
  late windows.WebviewController _windowsController;
  late mobile.WebViewController _mobileController;
  bool _isWebviewInitialized = false;
  final bool _isWindows = Platform.isWindows;

  @override
  void initState() {
    super.initState();
    if (_isWindows) {
      _initWindowsWebview();
    } else {
      _initMobileWebview();
    }
  }

  Future<void> _initWindowsWebview() async {
    _windowsController = windows.WebviewController();
    try {
      await _windowsController.initialize();
      await _windowsController.setBackgroundColor(Colors.transparent);
      await _windowsController.setPopupWindowPolicy(
        windows.WebviewPopupWindowPolicy.deny,
      );

      if (!mounted) return;
      setState(() {
        _isWebviewInitialized = true;
      });

      await _windowsController.loadUrl('https://www.imikufans.com/donate.php');
    } catch (e) {
      // 初始化失败，显示错误信息
      if (mounted) {
        setState(() {
          _isWebviewInitialized = true;
        });
      }
    }
  }

  Future<void> _initMobileWebview() async {
    _mobileController = mobile.WebViewController()
      ..setJavaScriptMode(mobile.JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse('https://www.imikufans.com/donate.php'));

    if (!mounted) return;
    setState(() {
      _isWebviewInitialized = true;
    });
  }

  @override
  void dispose() {
    if (_isWindows) {
      _windowsController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('赞助iMikufans')),
      body: _isWebviewInitialized
          ? (_isWindows
                ? windows.Webview(_windowsController)
                : mobile.WebViewWidget(controller: _mobileController))
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
