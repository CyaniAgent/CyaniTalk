// 赞助页面
//
// 该文件包含SponsorPage组件和iMikufansDonatePage组件，用于显示应用程序的赞助信息。
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';

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
  bool _isWebviewInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('赞助iMikufans')),
      body: _isWebviewInitialized
          ? InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri('https://www.imikufans.com/donate.php'),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                transparentBackground: true,
                useShouldOverrideUrlLoading: false,
              ),
              onWebViewCreated: (controller) {},
              onLoadStop: (controller, url) {
                if (!_isWebviewInitialized) {
                  setState(() {
                    _isWebviewInitialized = true;
                  });
                }
              },
            )
          : const Center(child: CyaniLoadingIndicator()),
    );
  }
}
