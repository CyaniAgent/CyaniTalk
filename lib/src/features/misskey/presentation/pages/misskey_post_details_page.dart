import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/shared/widgets/empty_state.dart';

class MisskeyPostDetailsPage extends StatelessWidget {
  final int noteId;
  final String user;

  const MisskeyPostDetailsPage({
    super.key,
    required this.noteId,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('post_details_note_details'.tr())),
      body: EmptyState(
        icon: Icons.article_outlined,
        title: 'post_details_loading_note_details'.tr(),
      ),
    );
  }
}
