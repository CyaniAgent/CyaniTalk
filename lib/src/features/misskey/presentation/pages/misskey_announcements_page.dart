import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/features/misskey/application/misskey_announcements_notifier.dart';
import '/src/features/misskey/domain/announcement.dart';
import '/src/features/misskey/presentation/widgets/retryable_network_image.dart';
import '/src/features/misskey/domain/mfm_renderer.dart';

class MisskeyAnnouncementsPage extends ConsumerStatefulWidget {
  const MisskeyAnnouncementsPage({super.key});

  @override
  ConsumerState<MisskeyAnnouncementsPage> createState() =>
      _MisskeyAnnouncementsPageState();
}

class _MisskeyAnnouncementsPageState
    extends ConsumerState<MisskeyAnnouncementsPage> {
  final MfmRenderer _mfmRenderer = MfmRenderer();

  @override
  void dispose() {
    _mfmRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(misskeyAnnouncementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('misskey_page_announcements'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(misskeyAnnouncementsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: announcementsAsync.when(
        data: (announcements) {
          if (announcements.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(misskeyAnnouncementsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return _buildAnnouncementCard(announcement, index);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildErrorState(err),
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement, int index) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

    return Card(
      elevation: 0,
      color: announcement.isRead
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (announcement.title != null) ...[
              Row(
                children: [
                  if (!announcement.isRead)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      announcement.title!,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (announcement.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: RetryableNetworkImage(
                  url: announcement.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (announcement.text != null) ...[
              SelectableText.rich(
                TextSpan(
                  children: [
                    _mfmRenderer.processText(announcement.text!, context),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(announcement.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                if (announcement.needConfirmationToRead && !announcement.isRead)
                  FilledButton.tonal(
                    onPressed: () => _markAsRead(announcement.id),
                    child: Text('misskey_announcement_mark_read'.tr()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'misskey_announcements_none'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'misskey_announcements_error'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              err.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref.read(misskeyAnnouncementsProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: Text('common_retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsRead(String announcementId) async {
    await ref
        .read(misskeyAnnouncementsProvider.notifier)
        .markAsRead(announcementId);
  }
}
