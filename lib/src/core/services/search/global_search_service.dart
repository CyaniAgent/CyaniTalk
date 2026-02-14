import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:easy_localization/easy_localization.dart';
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

  /// 搜索结果的类型，如'User'、'Post'、'Tag'、'Error'等
  final String type;

  /// 关联的原始数据ID或对象
  final dynamic originalData;

  /// 是否是禁用消息
  final bool isDisabledMessage;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.source,
    required this.type,
    this.originalData,
    this.isDisabledMessage = false,
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
      final meta = await misskeyRepo.getMeta();

      // Check if search features are enabled
      // In Misskey, policies are usually in /api/i (getMe) or sometimes in meta
      // We'll check both meta and assume enabled if not explicitly disabled
      final policies = meta['policies'] as Map<String, dynamic>?;
      final canSearchUsers = policies?['canSearchUsers'] ?? true;
      final canSearchNotes = policies?['canSearchNotes'] ?? true;

      if (!canSearchUsers) {
        results.add(
          SearchResult(
            title: 'search_misskey_users_disabled'.tr(),
            subtitle: '',
            source: 'misskey',
            type: 'User',
            isDisabledMessage: true,
          ),
        );
      } else {
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
      }

      if (!canSearchNotes) {
        results.add(
          SearchResult(
            title: 'search_misskey_posts_disabled'.tr(),
            subtitle: '',
            source: 'misskey',
            type: 'Note',
            isDisabledMessage: true,
          ),
        );
      } else {
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
      }
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
    } catch (e) {
      logger.warning('GlobalSearch: Flarum search failed: $e');
    }

    logger.info('GlobalSearch: Found ${results.length} results');
    return results;
  }
}
