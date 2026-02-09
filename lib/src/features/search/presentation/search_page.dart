import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/services/search/global_search_service.dart';
import '../../../core/utils/logger.dart';

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
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
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
                    logger.info('SearchPage: 选择搜索结果: ${result.title}');
                    // TODO: Implement navigation to result details
                  },
                );
              },
            ),
    );
  }
}
