// 全局搜索代理类
//
// 该文件包含GlobalSearchDelegate类，用于处理应用程序的全局搜索功能，
// 负责构建搜索界面、处理搜索操作和显示搜索结果。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/core/utils/utils.dart';
import 'global_search_service.dart';

/// 全局搜索代理
///
/// 继承自Flutter的SearchDelegate，负责处理应用程序的全局搜索功能，
/// 支持跨Misskey和Flarum平台搜索内容。
class GlobalSearchDelegate extends SearchDelegate<SearchResult?> {
  /// Riverpod WidgetRef
  final WidgetRef ref;

  /// 构造函数
  GlobalSearchDelegate(this.ref) {
    logger.info('GlobalSearchDelegate: 初始化全局搜索代理');
  }

  /// 构建搜索界面的操作按钮
  ///
  /// [context] - 构建上下文
  ///
  /// 返回包含操作按钮的Widget列表，当前实现了清除搜索词的功能
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            logger.debug('GlobalSearchDelegate: 清除搜索关键词');
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  /// 构建搜索界面的返回按钮
  ///
  /// [context] - 构建上下文
  ///
  /// 返回一个IconButton，用于关闭搜索界面
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        logger.debug('GlobalSearchDelegate: 关闭搜索界面');
        close(context, null);
      },
    );
  }

  /// 构建搜索结果界面
  ///
  /// [context] - 构建上下文
  ///
  /// 返回一个Widget，用于显示搜索结果列表
  @override
  Widget buildResults(BuildContext context) {
    logger.info('GlobalSearchDelegate: 构建搜索结果，关键词: $query');
    return FutureBuilder<List<SearchResult>>(
      future: ref.read(globalSearchProvider.notifier).search(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          logger.debug('GlobalSearchDelegate: 搜索中...');
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          logger.error('GlobalSearchDelegate: 搜索错误: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          logger.info('GlobalSearchDelegate: 无搜索结果');
          return Center(child: Text('search_no_results'.tr()));
        }

        final results = snapshot.data!;
        logger.info('GlobalSearchDelegate: 显示 ${results.length} 个搜索结果');
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            final sourceText = result.source == 'misskey'
                ? 'search_source_misskey'.tr()
                : 'search_source_flarum'.tr();
            return ListTile(
              leading: Icon(
                result.source == 'misskey' ? Icons.public : Icons.forum,
                color: result.source == 'misskey'
                    ? Colors.green
                    : Colors.orange,
              ),
              title: Text(result.title),
              subtitle: Text(
                '$sourceText • ${result.type}\n${result.subtitle}',
              ),
              isThreeLine: true,
              onTap: () {
                logger.info('GlobalSearchDelegate: 选择搜索结果: ${result.title}');
                close(context, result);
                // Handle navigation based on result
              },
            );
          },
        );
      },
    );
  }

  /// 构建搜索建议界面
  ///
  /// [context] - 构建上下文
  ///
  /// 返回一个Widget，用于显示搜索建议
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      logger.debug('GlobalSearchDelegate: 显示搜索提示');
      return Center(child: Text('search_enter_query'.tr()));
    }
    // 目前仅在搜索词为空时显示提示信息，未实现完整的搜索建议功能
    logger.debug('GlobalSearchDelegate: 构建搜索建议，关键词: $query');
    return Container();
  }
}
