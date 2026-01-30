import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/domain/account.dart';
import '../../../../core/api/misskey_api.dart';
import '../../../../core/api/flarum_api.dart';

final userDetailsProvider = FutureProvider.family<Map<String, dynamic>, Account>((
  ref,
  account,
) async {
  logger.info(
    'UserDetailsView: Fetching details for ${account.platform} account: ${account.id}',
  );
  try {
    if (account.platform == 'misskey') {
      final api = MisskeyApi(host: account.host, token: account.token);
      final details = await api.i();
      logger.info(
        'UserDetailsView: Successfully fetched Misskey user details for ${account.id}',
      );
      return details;
    } else if (account.platform == 'flarum') {
      final api = FlarumApi();
      api.setBaseUrl('https://${account.host}');
      // userId is stored in account.id as userId@host
      final userId = account.id.split('@').first;
      final details = await api.getUserProfile(userId);
      logger.info(
        'UserDetailsView: Successfully fetched Flarum user details for ${account.id}',
      );
      return details;
    }
    throw Exception('Unknown platform');
  } catch (e) {
    logger.error(
      'UserDetailsView: Error fetching user details for ${account.id}',
      e,
    );
    rethrow;
  }
});

class UserDetailsView extends ConsumerWidget {
  final Account account;

  const UserDetailsView({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logger.info(
      'UserDetailsView: Building details view for ${account.platform} account: ${account.id}',
    );
    final detailsAsync = ref.watch(userDetailsProvider(account));

    return detailsAsync.when(
      data: (data) {
        logger.info(
          'UserDetailsView: Successfully built details view with data',
        );
        return _buildDetails(context, data);
      },
      loading: () {
        logger.info('UserDetailsView: Loading user details');
        return const Center(child: CircularProgressIndicator());
      },
      error: (err, stack) {
        logger.error('UserDetailsView: Error building details view', err);
        return Center(child: Text('Error: $err'));
      },
    );
  }

  Widget _buildDetails(BuildContext context, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(context, data),
        const SizedBox(height: 20),
        _buildSectionTitle(context, 'user_details_roles_permissions'.tr()),
        _buildRolesCard(context, data),
        const SizedBox(height: 20),
        _buildRawDataCard(context, data),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);

    if (account.platform == 'misskey') {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'user_details_notes_count'.tr(),
                  data['notesCount']?.toString() ?? '0',
                  Icons.notes,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'user_details_following'.tr(),
                  data['followingCount']?.toString() ?? '0',
                  Icons.person_add_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'user_details_followers'.tr(),
                  data['followersCount']?.toString() ?? '0',
                  Icons.people_outline,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    'user_details_name'.tr(),
                    data['name'] ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    'user_details_username'.tr(),
                    '@${data['username'] ?? 'N/A'}',
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        ],
      );
    } else {
      // Flarum
      final attributes = data['data']?['attributes'] ?? {};
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'user_details_discussions'.tr(),
                  attributes['discussionCount']?.toString() ?? '0',
                  Icons.chat_bubble_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'user_details_comments'.tr(),
                  attributes['commentCount']?.toString() ?? '0',
                  Icons.comment_outlined,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    'user_details_display_name'.tr(),
                    attributes['displayName'] ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    'user_details_username'.tr(),
                    attributes['username'] ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    'user_details_email'.tr(),
                    attributes['email'] ?? 'Hidden',
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        ],
      );
    }
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final mikuColor = const Color(0xFF39C5BB);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: mikuColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mikuColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: mikuColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: mikuColor,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildRolesCard(BuildContext context, Map<String, dynamic> data) {
    final roles = <String>[];
    if (account.platform == 'misskey') {
      if (data['isAdmin'] == true) roles.add('user_details_admin'.tr());
      if (data['isModerator'] == true) roles.add('user_details_moderator'.tr());
      if (data['isSilenced'] == true) roles.add('user_details_silenced'.tr());
      if (data['isSuspended'] == true) roles.add('user_details_suspended'.tr());
      if (roles.isEmpty) roles.add('user_details_standard_user'.tr());
    } else {
      // Flarum
      final included = data['included'] as List? ?? [];
      for (var item in included) {
        if (item['type'] == 'groups') {
          roles.add(item['attributes']?['nameSingular'] ?? 'Unknown Group');
        }
      }
      if (roles.isEmpty) roles.add('user_details_member'.tr());
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 8,
          children: roles
              .map(
                (r) => Chip(
                  label: Text(r),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildRawDataCard(BuildContext context, Map<String, dynamic> data) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          'user_details_raw_data'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        leading: const Icon(Icons.code),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(data),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
