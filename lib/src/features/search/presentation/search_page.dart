import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/core/services/search/global_search_service.dart';
import '/src/core/utils/logger.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await ref
          .read(globalSearchProvider.notifier)
          .search(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.error('SearchPage: 搜索错误: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text;
    final misskeyUsers = _results
        .where((r) => r.source == 'misskey' && r.type == 'User')
        .toList();
    final misskeyNotes = _results
        .where((r) => r.source == 'misskey' && r.type == 'Note')
        .toList();
    final flarumDiscussions = _results
        .where((r) => r.source == 'flarum' && r.type == 'Discussion')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'search_enter_query'.tr(),
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _results = [];
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
          ? Center(
              child: Text(
                _searchController.text.isEmpty
                    ? 'search_enter_query'.tr()
                    : 'search_no_results'.tr(),
              ),
            )
          : ListView(
              children: [
                if (misskeyUsers.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'search_misskey_users_related'.tr(
                      namedArgs: {'search_result': query},
                    ),
                  ),
                  ...misskeyUsers.map((r) => _buildResultTile(context, r)),
                ],
                if (misskeyNotes.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'search_misskey_posts_related'.tr(
                      namedArgs: {'search_result': query},
                    ),
                  ),
                  ...misskeyNotes.map((r) => _buildResultTile(context, r)),
                ],
                if (flarumDiscussions.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'search_flarum_discussions_related'.tr(
                      namedArgs: {'search_result': query},
                    ),
                  ),
                  ...flarumDiscussions.map((r) => _buildResultTile(context, r)),
                ],
              ],
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, SearchResult result) {
    if (result.isDisabledMessage) {
      return ListTile(
        leading: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
        title: Text(result.title),
        subtitle: Text('search_feature_disabled_hint'.tr()),
      );
    }

    final sourceText = result.source == 'misskey'
        ? 'search_source_misskey'.tr()
        : 'search_source_flarum'.tr();

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: result.source == 'misskey'
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          result.source == 'misskey'
              ? (result.type == 'User' ? Icons.person : Icons.public)
              : Icons.forum,
          size: 20,
          color: result.source == 'misskey'
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      title: Text(result.title),
      subtitle: Text('$sourceText • ${result.type}\n${result.subtitle}'),
      isThreeLine: true,
      onTap: () {
        logger.info('SearchPage: 选择搜索结果: ${result.title}');
        // TODO: 实现导航到结果详情
      },
    );
  }
}
