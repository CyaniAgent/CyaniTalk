// 全局搜索服务相关的类和定义
//
// 该文件包含搜索结果模型和全局搜索服务的实现，
// 负责处理跨平台搜索请求并返回统一的搜索结果。
import 'dart:async';

/// 搜索结果模型
///
/// 表示一个搜索结果项，包含标题、副标题、来源和类型等信息。
class SearchResult {
  /// 搜索结果的标题
  final String title;
  
  /// 搜索结果的副标题或描述
  final String subtitle;
  
  /// 搜索结果的来源平台，如'Misskey'或'Flarum'
  final String source;
  
  /// 搜索结果的类型，如'User'、'Post'、'Tag'等
  final String type;

  /// 创建一个新的搜索结果实例
  ///
  /// [title] - 搜索结果的标题
  /// [subtitle] - 搜索结果的副标题或描述
  /// [source] - 搜索结果的来源平台
  /// [type] - 搜索结果的类型
  SearchResult({
    required this.title,
    required this.subtitle,
    required this.source,
    required this.type,
  });
}

/// 全局搜索服务
///
/// 提供跨平台搜索功能，支持在Misskey和Flarum平台上搜索内容。
/// 使用单例模式确保全局只有一个实例。
class GlobalSearchService {
  // 单例实例，用于确保全局只有一个搜索服务实例
  static final GlobalSearchService _instance = GlobalSearchService._internal();

  /// 获取全局搜索服务的实例
  factory GlobalSearchService() {
    return _instance;
  }

  /// 私有构造函数，用于创建单例实例
  GlobalSearchService._internal();

  /// 执行全局搜索
  ///
  /// [query] - 搜索关键词
  ///
  /// 返回包含搜索结果的Future列表
  Future<List<SearchResult>> search(String query) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    if (query.isEmpty) return [];

    // 模拟搜索结果
    final results = <SearchResult>[];

    // Misskey平台模拟结果
    results.add(SearchResult(
      title: 'Note containing "$query"',
      subtitle: '@user: This is a misskey note about $query...',
      source: 'Misskey',
      type: 'Note',
    ));
    results.add(SearchResult(
      title: 'User $query',
      subtitle: '@$query@misskey.io',
      source: 'Misskey',
      type: 'User',
    ));

    // Flarum平台模拟结果
    results.add(SearchResult(
      title: 'Discussion about "$query"',
      subtitle: 'Latest reply in General tag',
      source: 'Flarum',
      type: 'Discussion',
    ));
    results.add(SearchResult(
      title: '#$query',
      subtitle: 'Flarum Tag',
      source: 'Flarum',
      type: 'Tag',
    ));

    return results;
  }
}
