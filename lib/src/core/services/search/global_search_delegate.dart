// 全局搜索代理类
//
// 该文件包含GlobalSearchDelegate类，用于处理应用程序的全局搜索功能，
// 负责构建搜索界面、处理搜索操作和显示搜索结果。
import 'package:flutter/material.dart';
import 'global_search_service.dart';

/// 全局搜索代理
///
/// 继承自Flutter的SearchDelegate，负责处理应用程序的全局搜索功能，
/// 支持跨Misskey和Flarum平台搜索内容。
class GlobalSearchDelegate extends SearchDelegate<SearchResult?> {
  /// 全局搜索服务实例
  final GlobalSearchService _searchService = GlobalSearchService();

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
    return FutureBuilder<List<SearchResult>>(
      future: _searchService.search(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No results found.'));
        }

        final results = snapshot.data!;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return ListTile(
              leading: Icon(
                result.source == 'Misskey' ? Icons.public : Icons.forum,
                color: result.source == 'Misskey' ? Colors.green : Colors.orange,
              ),
              title: Text(result.title),
              subtitle: Text('${result.source} • ${result.type}\n${result.subtitle}'),
              isThreeLine: true,
              onTap: () {
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
      return const Center(child: Text('Enter a query to search across Misskey and Flarum'));
    }
    // 目前仅在搜索词为空时显示提示信息，未实现完整的搜索建议功能
    return Container();
  }
}
