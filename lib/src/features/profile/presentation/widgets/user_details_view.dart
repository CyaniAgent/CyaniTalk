import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../auth/domain/account.dart';
import '../../../../core/api/misskey_api.dart';
import '../../../../core/api/flarum_api.dart';

final userDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, Account>((ref, account) async {
  if (account.platform == 'misskey') {
    final api = MisskeyApi(host: account.host, token: account.token);
    return await api.i();
  } else if (account.platform == 'flarum') {
    final api = FlarumApi();
    api.setBaseUrl('https://${account.host}');
    // userId is stored in account.id as userId@host
    final userId = account.id.split('@').first;
    return await api.getUserProfile(userId);
  }
  throw Exception('Unknown platform');
});

class UserDetailsView extends ConsumerWidget {
  final Account account;

  const UserDetailsView({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(userDetailsProvider(account));

    return detailsAsync.when(
      data: (data) => _buildDetails(context, data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildDetails(BuildContext context, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'user_details_basic_information'.tr()),
        _buildInfoCard(context, data),
        const SizedBox(height: 16),
        _buildSectionTitle(context, 'user_details_roles_permissions'.tr()),
        _buildRolesCard(context, data),
        const SizedBox(height: 16),
        _buildRawDataCard(context, data),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Map<String, dynamic> data) {
    final items = <Widget>[];
    if (account.platform == 'misskey') {
      items.add(_buildDetailItem('Name', data['name'] ?? 'N/A'));
      items.add(_buildDetailItem('Username', data['username'] ?? 'N/A'));
      items.add(_buildDetailItem('Notes Count', data['notesCount']?.toString() ?? '0'));
      items.add(_buildDetailItem('Following', data['followingCount']?.toString() ?? '0'));
      items.add(_buildDetailItem('Followers', data['followersCount']?.toString() ?? '0'));
    } else {
      // Flarum
      final attributes = data['data']?['attributes'] ?? {};
      items.add(_buildDetailItem('Username', attributes['username'] ?? 'N/A'));
      items.add(_buildDetailItem('Display Name', attributes['displayName'] ?? 'N/A'));
      items.add(_buildDetailItem('Email', attributes['email'] ?? 'Hidden'));
      items.add(_buildDetailItem('Discussions', attributes['discussionCount']?.toString() ?? '0'));
      items.add(_buildDetailItem('Comments', attributes['commentCount']?.toString() ?? '0'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: items),
      ),
    );
  }

  Widget _buildRolesCard(BuildContext context, Map<String, dynamic> data) {
    final roles = <String>[];
    if (account.platform == 'misskey') {
      if (data['isAdmin'] == true) roles.add('Administrator');
      if (data['isModerator'] == true) roles.add('Moderator');
      if (data['isSilenced'] == true) roles.add('Silenced');
      if (data['isSuspended'] == true) roles.add('Suspended');
      if (roles.isEmpty) roles.add('Standard User');
    } else {
      // Flarum
      final included = data['included'] as List? ?? [];
      for (var item in included) {
        if (item['type'] == 'groups') {
          roles.add(item['attributes']?['nameSingular'] ?? 'Unknown Group');
        }
      }
      if (roles.isEmpty) roles.add('Member');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 8,
          children: roles
              .map((r) => Chip(
                    label: Text(r),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  ))
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
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(data),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
