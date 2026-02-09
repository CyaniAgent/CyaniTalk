import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../utils/utils.dart';
import '../../../features/flarum/application/flarum_providers.dart';
import '../../../features/misskey/data/misskey_repository.dart';

part 'global_search_service.g.dart';

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

  /// 关联的原始数据ID或对象
  final dynamic originalData;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.source,
    required this.type,
    this.originalData,
  });
}

/// 全局搜索服务
///
/// 提供跨平台搜索功能，支持在Misskey和Flarum平台上搜索内容。
@riverpod
class GlobalSearch extends _$GlobalSearch {
  @override
  void build() {}

  /// 执行全局搜索
  ///
  /// [query] - 搜索关键词
  ///
  /// 返回包含搜索结果的Future列表
  Future<List<SearchResult>> search(String query) async {
    if (query.isEmpty) return [];

    logger.info('GlobalSearch: Starting search for: $query');
    final results = <SearchResult>[];

    // Search Misskey (if available)
    try {
      final misskeyRepo = await ref.read(misskeyRepositoryProvider.future);
      final users = await misskeyRepo.searchUsers(query, limit: 5);
      results.addAll(
        users.map(
          (u) => SearchResult(
            title: u.name ?? u.username,
            subtitle: '@${u.username}@${misskeyRepo.host}',
            source: 'misskey',
            type: 'User',
            originalData: u,
          ),
        ),
      );

      final notes = await misskeyRepo.searchNotes(query, limit: 5);
      results.addAll(
        notes.map(
          (n) => SearchResult(
            title: n.text ?? 'Note',
            subtitle:
                '@${n.user?.username ?? "unknown"}: ${n.text?.substring(0, 30.clamp(0, n.text?.length ?? 0)) ?? ""}${(n.text?.length ?? 0) > 30 ? "..." : ""}',
            source: 'misskey',
            type: 'Note',
            originalData: n,
          ),
        ),
      );
    } catch (e) {
      logger.warning('GlobalSearch: Misskey search failed: $e');
    }

    // Search Flarum (if available)
    try {
      final flarumRepo = ref.read(flarumRepositoryProvider);
      final discussions = await flarumRepo.searchDiscussions(query);
      results.addAll(
        discussions
            .take(5)
            .map(
              (d) => SearchResult(
                title: d.title,
                subtitle: 'Discussions about ${d.title}',
                source: 'flarum',
                type: 'Discussion',
                originalData: d,
              ),
            ),
      );

      // We could also search tags but Flarum doesn't have a specific tag search API usually,
      // they are usually fetched all at once.
    } catch (e) {
      logger.warning('GlobalSearch: Flarum search failed: $e');
    }

    logger.info('GlobalSearch: Found ${results.length} results');
    return results;
  }
}
