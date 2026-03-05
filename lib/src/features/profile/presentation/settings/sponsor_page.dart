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
      body: ListView(
        children: [
          // 说明内容
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.favorite,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'sponsor_coming_soon'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'sponsor_reserved'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // 赞助选项
          _buildSectionHeader(context, 'sponsor_options'.tr()),
          _buildSettingsTile(
            context,
            Icons.favorite,
            'sponsor_imikufans'.tr(),
            'sponsor_imikufans_description'.tr(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IMikufansDonatePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建页面的分区标题
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [title] - 分区标题文本
  ///
  /// 返回一个显示分区标题的Widget
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// 构建设置选项瓦片
  ///
  /// [context] - 构建上下文，包含组件树的信息
  /// [icon] - 选项图标
  /// [title] - 选项标题
  /// [subtitle] - 选项描述
  /// [onTap] - 点击事件回调
  ///
  /// 返回一个显示设置选项的ListTile组件
  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String? subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
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
