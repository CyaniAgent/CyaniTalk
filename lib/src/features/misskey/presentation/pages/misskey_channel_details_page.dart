import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cyanitalk/src/features/misskey/application/misskey_notifier.dart';
import 'package:cyanitalk/src/features/misskey/domain/channel.dart';
import 'package:cyanitalk/src/features/misskey/presentation/widgets/note_card.dart';

class MisskeyChannelDetailsPage extends ConsumerStatefulWidget {
  final Channel channel;

  const MisskeyChannelDetailsPage({super.key, required this.channel});

  @override
  ConsumerState<MisskeyChannelDetailsPage> createState() => _MisskeyChannelDetailsPageState();
}

class _MisskeyChannelDetailsPageState extends ConsumerState<MisskeyChannelDetailsPage> {
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
      ref.read(misskeyChannelTimelineProvider(widget.channel.id).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(misskeyChannelTimelineProvider(widget.channel.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
      ),
      body: timelineAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return Center(child: Text('channel_details_no_notes_in_this_channel'.tr()));
          }
          return RefreshIndicator(
            onRefresh: () => ref
                .read(misskeyChannelTimelineProvider(widget.channel.id).notifier)
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
