import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../application/misskey_notifier.dart';
import '../../domain/clip.dart';
import '../widgets/modern_note_card.dart';

class MisskeyClipNotesPage extends ConsumerStatefulWidget {
  final Clip clip;

  const MisskeyClipNotesPage({super.key, required this.clip});

  @override
  ConsumerState<MisskeyClipNotesPage> createState() => _MisskeyClipNotesPageState();
}

class _MisskeyClipNotesPageState extends ConsumerState<MisskeyClipNotesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(misskeyClipNotesProvider(widget.clip.id).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(misskeyClipNotesProvider(widget.clip.id));
    final hasMore = ref.watch(misskeyClipNotesProvider(widget.clip.id).notifier).hasMore;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clip.name),
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(child: Text('timeline_no_notes_found'.tr()));
          }
          return RefreshIndicator(
            onRefresh: () => ref
                .read(misskeyClipNotesProvider(widget.clip.id).notifier)
                .refresh(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: notes.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < notes.length) {
                  return ModernNoteCard(
                    key: ValueKey(notes[index].id),
                    note: notes[index],
                  );
                } else {
                  return _buildLoadMoreIndicator();
                }
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
