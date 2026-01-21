import 'dart:async';

class SearchResult {
  final String title;
  final String subtitle;
  final String source; // 'Misskey' or 'Flarum'
  final String type; // 'User', 'Post', 'Tag', etc.

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.source,
    required this.type,
  });
}

class GlobalSearchService {
  // Singleton pattern for simplicity in this context, or manageable via Riverpod later
  static final GlobalSearchService _instance = GlobalSearchService._internal();

  factory GlobalSearchService() {
    return _instance;
  }

  GlobalSearchService._internal();

  Future<List<SearchResult>> search(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (query.isEmpty) return [];

    // Mock results
    final results = <SearchResult>[];

    // Misskey Mock Results
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

    // Flarum Mock Results
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
