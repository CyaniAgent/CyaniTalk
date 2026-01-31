import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/associated_accounts_section.dart';
import 'settings/settings_page.dart';
import 'settings/about_page.dart';
import '../../auth/application/auth_service.dart';
import '../../misskey/domain/misskey_user.dart';
import '../../misskey/application/misskey_notifier.dart';
import '../../flarum/application/flarum_providers.dart';
import '../../flarum/data/models/user.dart' as flarum_model;

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mikuColor = const Color(0xFF39C5BB);
    final selectedMisskey = ref.watch(selectedMisskeyAccountProvider).asData?.value;
    final selectedFlarum = ref.watch(selectedFlarumAccountProvider).asData?.value;
    final primaryAccount = selectedMisskey ?? selectedFlarum;

    final misskeyUser = primaryAccount?.platform == 'misskey'
        ? ref.watch(misskeyMeProvider).asData?.value
        : null;

    final flarumUser = primaryAccount?.platform == 'flarum'
        ? ref.watch(flarumCurrentUserProvider).asData?.value
        : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: mikuColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: mikuColor,
                      image: misskeyUser?.bannerUrl != null
                          ? DecorationImage(
                              image: NetworkImage(misskeyUser!.bannerUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      gradient: misskeyUser?.bannerUrl == null
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF962832),
                                Color(0xFF39C5BB),
                              ],
                            )
                          : null,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Hero(
                              tag: 'profile_avatar',
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.white,
                                  backgroundImage: (misskeyUser?.avatarUrl ?? primaryAccount?.avatarUrl) != null
                                      ? NetworkImage(misskeyUser?.avatarUrl ?? primaryAccount!.avatarUrl!)
                                      : null,
                                  child: (misskeyUser?.avatarUrl ?? primaryAccount?.avatarUrl) == null
                                      ? Icon(Icons.person, size: 50, color: mikuColor)
                                      : null,
                                ),
                              ),
                            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Text(
                                        misskeyUser?.name ?? primaryAccount?.name ?? primaryAccount?.username ?? 'CyaniUser',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 2))],
                                        ),
                                      ),
                                      if (misskeyUser != null && misskeyUser.badgeRoles.isNotEmpty)
                                        ...misskeyUser.badgeRoles.map((role) {
                                          final name = role['name'] as String?;
                                          if (name == null) return const SizedBox.shrink();
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                            ),
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        }),
                                    ],
                                  ),
                                  Text(
                                    '@${misskeyUser?.username ?? primaryAccount?.username}@${primaryAccount?.host}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                            ),
                          ],
                        ),
                        if (misskeyUser?.description != null && misskeyUser!.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16, left: 4),
                            child: Text(
                              misskeyUser.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.85),
                                shadows: const [Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(0, 1))],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ).animate().fadeIn(delay: 400.ms),

                        const SizedBox(height: 20),
                        _buildUserStats(context, misskeyUser, flarumUser).animate().fadeIn(delay: 500.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AssociatedAccountsSection(
                    showRemoveButton: false,
                    showTitle: true,
                  ),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'nav_me'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text('settings_title'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ),
              ),
              const Divider(indent: 56, endIndent: 16, height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text('settings_about_title'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildUserStats(BuildContext context, MisskeyUser? misskeyUser, flarum_model.User? flarumUser) {
    if (misskeyUser == null && flarumUser == null) return const SizedBox.shrink();

    final List<Widget> stats = [];

    if (misskeyUser != null) {
      // Misskey Stats
      if (misskeyUser.createdAt != null) {
        stats.add(_buildStatItem(context, 'Joined', DateFormat.yMMMd().format(misskeyUser.createdAt!)));
      }
      if (misskeyUser.notesCount != null) {
        stats.add(_buildStatItem(context, 'user_details_notes_count'.tr(), _formatCount(misskeyUser.notesCount!)));
      }
      if (misskeyUser.followingCount != null) {
        stats.add(_buildStatItem(context, 'user_details_following'.tr(), _formatCount(misskeyUser.followingCount!)));
      }
      if (misskeyUser.followersCount != null) {
        stats.add(_buildStatItem(context, 'user_details_followers'.tr(), _formatCount(misskeyUser.followersCount!)));
      }
    } else if (flarumUser != null) {
      // Flarum Stats
      // Join Time
       stats.add(_buildStatItem(context, 'Joined', DateFormat.yMMMd().format(DateTime.parse(flarumUser.joinTime))));
       
       // Posts (Discussions)
       stats.add(_buildStatItem(context, 'user_details_discussions'.tr(), _formatCount(flarumUser.discussionCount)));
       
       // Recovered (Comments)
       stats.add(_buildStatItem(context, 'user_details_comments'.tr(), _formatCount(flarumUser.commentCount)));
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stats.map((s) => Padding(padding: const EdgeInsets.only(right: 16), child: s)).toList(),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(0, 1))],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
             shadows: const [Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(0, 1))],
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count > 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}