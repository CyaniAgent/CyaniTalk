// 赞助页面
//
// 该文件包含SponsorPage组件，用于显示应用程序的赞助信息。
// 注意：这是一个占位符页面，暂时没有实际值。
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
            // 占位符内容
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
                    'sponsor_placeholder'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'sponsor_coming_soon'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            // 预留区域
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'sponsor_reserved'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
