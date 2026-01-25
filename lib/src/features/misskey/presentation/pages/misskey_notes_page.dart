import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cyanitalk/src/features/misskey/application/misskey_notifier.dart';
import 'package:cyanitalk/src/features/misskey/presentation/widgets/note_card.dart';

/// Misskey 笔记页面组件
/// 
/// 这里展示全域时间线（Global Timeline）作为探索发现页面。
class MisskeyNotesPage extends ConsumerStatefulWidget {
  const MisskeyNotesPage({super.key});

  @override
  ConsumerState<MisskeyNotesPage> createState() => _MisskeyNotesPageState();
}

class _MisskeyNotesPageState extends ConsumerState<MisskeyNotesPage> {
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
      ref.read(misskeyTimelineProvider('Global').notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(misskeyTimelineProvider('Global'));

    return Scaffold(
      body: timelineAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(child: Text('notes_no_notes_found_in_global_timeline'.tr()));
          }
          return RefreshIndicator(
            onRefresh: () => ref
                .read(misskeyTimelineProvider('Global').notifier)
                .refresh(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: notes.length + 1,
              itemBuilder: (context, index) {
                if (index < notes.length) {
                  return NoteCard(note: notes[index]);
                } else {
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
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
