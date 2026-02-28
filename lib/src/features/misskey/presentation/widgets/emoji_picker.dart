import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/misskey/domain/emoji.dart';
import '/src/features/misskey/data/misskey_repository.dart';
import 'retryable_network_image.dart';

class EmojiPicker extends ConsumerStatefulWidget {
  final String noteId;
  final String? currentReaction;
  final Function(String) onEmojiSelected;
  final Function()? onReactionRemoved;

  const EmojiPicker({
    super.key,
    required this.noteId,
    this.currentReaction,
    required this.onEmojiSelected,
    this.onReactionRemoved,
  });

  @override
  ConsumerState<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends ConsumerState<EmojiPicker>
    with AutomaticKeepAliveClientMixin {
  List<Emoji> _emojis = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  final List<String> _commonEmojis = [
    '❤️',
    '😂',
    '😮',
    '😢',
    '😡',
    '👍',
    '👎',
    '🎉',
    '🔥',
    '✨',
  ];

  @override
  void initState() {
    super.initState();
    _loadEmojis();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmojis() async {
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      final emojis = await repository.getEmojis();
      if (mounted) {
        setState(() {
          _emojis = emojis;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Emoji> get _filteredEmojis {
    var filtered = _emojis;

    if (_selectedCategory != null) {
      filtered = filtered
          .where((emoji) => emoji.category == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((emoji) {
        return emoji.name.toLowerCase().contains(query) ||
            emoji.aliases.any((alias) => alias.toLowerCase().contains(query));
      }).toList();
    }

    return filtered;
  }

  List<String> get _categories {
    final categories = _emojis
        .map((emoji) => emoji.category)
        .whereType<String>()
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        height: 500,
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryTabs(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildEmojiGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'emoji_picker_title'.tr(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (widget.currentReaction != null &&
              widget.onReactionRemoved != null)
            TextButton.icon(
              onPressed: () {
                widget.onReactionRemoved!();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close, size: 18),
              label: Text('emoji_remove_reaction'.tr()),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'emoji_search_hint'.tr(),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _buildCategoryChip(null, 'emoji_all'.tr()),
          ..._categories.map(
            (category) => _buildCategoryChip(category, category),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildEmojiGrid() {
    return Column(
      children: [
        if (_searchQuery.isEmpty && _selectedCategory == null)
          _buildCommonEmojis(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _filteredEmojis.length,
            itemBuilder: (context, index) {
              final emoji = _filteredEmojis[index];
              return _buildEmojiItem(emoji);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommonEmojis() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'emoji_common'.tr(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _commonEmojis.length,
              itemBuilder: (context, index) {
                final emoji = _commonEmojis[index];
                return _buildCommonEmojiItem(emoji);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonEmojiItem(String emoji) {
    return GestureDetector(
      onTap: () {
        widget.onEmojiSelected(emoji);
        Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
      ),
    );
  }

  Widget _buildEmojiItem(Emoji emoji) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          widget.onEmojiSelected(':${emoji.name}:');
          Navigator.pop(context);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: RetryableNetworkImage(
              url: emoji.url,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
