import 'package:flutter/material.dart';
import 'global_search_service.dart';

class GlobalSearchDelegate extends SearchDelegate<SearchResult?> {
  final GlobalSearchService _searchService = GlobalSearchService();

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

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

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

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Enter a query to search across Misskey and Flarum'));
    }
    // Implement suggestions if needed, for now just show results directly or nothing
    // Typically suggestions are lighter weight or history.
    // For this prototype, we'll trigger search on buildResults mostly,
    // but we can also debounced search here.
    return Container();
  }
}
