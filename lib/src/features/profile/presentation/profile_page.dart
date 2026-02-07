import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:palette_generator/palette_generator.dart';
import '../../../core/core.dart';
import 'widgets/associated_accounts_section.dart';
import '../../auth/application/auth_service.dart';
import '../../auth/domain/account.dart';
import '../../auth/presentation/widgets/add_account_dialog.dart';
import '../../misskey/domain/misskey_user.dart';
import '../../misskey/application/misskey_notifier.dart';
import '../../flarum/application/flarum_providers.dart';
import '../../flarum/data/models/user.dart' as flarum_model;

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  static const mikuColor = SaucePalette.mikuGreen;
  Color _appBarColor = SaucePalette.mikuGreen;
  bool _isColorExtracted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _extractAppBarColor();
  }

  Future<void> _extractAppBarColor() async {
    if (_isColorExtracted) return;

    try {
      final selectedMisskey = ref
          .watch(selectedMisskeyAccountProvider)
          .asData
          ?.value;
      if (selectedMisskey == null) {
        _isColorExtracted = true;
        return;
      }

      final primaryAccount = selectedMisskey;
      if (primaryAccount.platform != 'misskey') {
        _isColorExtracted = true;
        return;
      }

      final misskeyUserAsync = ref.watch(misskeyMeProvider);
      if (misskeyUserAsync.isLoading) {
        // 等待数据加载
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          _extractAppBarColor();
        }
        return;
      }

      final misskeyUser = misskeyUserAsync.asData?.value;
      if (misskeyUser?.bannerUrl == null) {
        _isColorExtracted = true;
        return;
      }

      // 图片加载和颜色提取
      final color = await _getImageDominantColor(misskeyUser!.bannerUrl!);
      if (mounted) {
        setState(() {
          _appBarColor = color;
          _isColorExtracted = true;
        });
      }
    } catch (e) {
      // 如果颜色提取失败，使用默认颜色
      _isColorExtracted = true;
    }
  }

  Future<Color> _getImageDominantColor(String imageUrl) async {
    try {
      // 使用palette_generator库从图片中提取颜色
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        maximumColorCount: 10,
      );

      // 获取主色调
      Color dominantColor = mikuColor;
      if (paletteGenerator.dominantColor != null) {
        dominantColor = paletteGenerator.dominantColor!.color;
      } else if (paletteGenerator.lightVibrantColor != null) {
        dominantColor = paletteGenerator.lightVibrantColor!.color;
      } else if (paletteGenerator.vibrantColor != null) {
        dominantColor = paletteGenerator.vibrantColor!.color;
      }

      // 确保颜色足够亮，适合作为AppBar背景
      final hsl = HSLColor.fromColor(dominantColor);
      final adjustedColor = hsl
          .withLightness(hsl.lightness.clamp(0.3, 0.8))
          .toColor();

      return adjustedColor;
    } catch (e) {
      return SaucePalette.mikuGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedMisskey = ref.watch(selectedMisskeyAccountProvider).asData?.value;
    final selectedFlarum = ref.watch(selectedFlarumAccountProvider).asData?.value;
    final primaryAccount = selectedMisskey ?? selectedFlarum;

    final misskeyUser =
        primaryAccount?.platform == 'misskey'
            ? ref.watch(misskeyMeProvider).asData?.value
            : null;

    final flarumUser =
        primaryAccount?.platform == 'flarum'
            ? ref.watch(flarumCurrentUserProvider).asData?.value
            : null;

    final bool isLoggedIn = primaryAccount != null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isLoggedIn ? 340.0 : 280.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: isLoggedIn ? _appBarColor : mikuColor,
            actions: [
              IconButton(
                icon: Icon(Icons.settings, color: theme.colorScheme.onPrimary),
                onPressed: () => context.push('/settings'),
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
                      image:
                          misskeyUser?.bannerUrl != null
                              ? DecorationImage(
                                image: NetworkImage(misskeyUser!.bannerUrl!),
                                fit: BoxFit.cover,
                              )
                              : null,
                      gradient:
                          misskeyUser?.bannerUrl == null
                              ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF962832), Color(0xFF39C5BB)],
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
                            theme.colorScheme.shadow.withValues(alpha: 0.5),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  if (isLoggedIn)
                    _buildLoggedInHeader(
                      context,
                      primaryAccount,
                      misskeyUser,
                      flarumUser,
                    )
                  else
                    _buildLoggedOutHeader(context),
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
                  if (isLoggedIn) ...[
                    const AssociatedAccountsSection(
                      showRemoveButton: false,
                      showTitle: true,
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    _buildAddAccountButton(context),
                    const SizedBox(height: 24),
                  ],
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

  Widget _buildLoggedInHeader(
    BuildContext context,
    Account primaryAccount,
    MisskeyUser? misskeyUser,
    flarum_model.User? flarumUser,
  ) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'profile_avatar_${misskeyUser?.id ?? primaryAccount.id}',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).colorScheme.onPrimary, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    backgroundImage:
                        (misskeyUser?.avatarUrl ?? primaryAccount.avatarUrl) !=
                                null
                            ? NetworkImage(
                              misskeyUser?.avatarUrl ??
                                  primaryAccount.avatarUrl!,
                            )
                            : null,
                    child:
                        (misskeyUser?.avatarUrl ?? primaryAccount.avatarUrl) ==
                                null
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
                          misskeyUser?.name ??
                              primaryAccount.name ??
                              primaryAccount.username ??
                              'CyaniUser',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        if (misskeyUser != null &&
                            misskeyUser.badgeRoles.isNotEmpty)
                          ...misskeyUser.badgeRoles.map((role) {
                            final name = role['name'] as String?;
                            if (name == null) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                    Text(
                      '@${misskeyUser?.username ?? primaryAccount.username}@${primaryAccount.host}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
              ),
            ],
          ),
          if (misskeyUser?.description != null &&
              misskeyUser!.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 4),
              child: Text(
                misskeyUser.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.85),
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 20),
          _buildUserStats(
            context,
            misskeyUser,
            flarumUser,
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildLoggedOutHeader(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'misskey_page_no_account_title'.tr(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            'misskey_page_no_account_subtitle'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddAccountDialog(context),
            icon: const Icon(Icons.login),
            label: Text('misskey_page_login_now'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: mikuColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
        ],
      ),
    );
  }

  Widget _buildAddAccountButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'settings_section_account'.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          elevation: 0,
          child: ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: Text('accounts_add_account'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAddAccountDialog(context),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  void _showAddAccountDialog(BuildContext context) {
    AddAccountBottomSheet.show(context);
  }


  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'nav_me'.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          elevation: 0,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text('settings_title'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings'),
              ),
              const Divider(indent: 56, endIndent: 16, height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text('settings_about_title'.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/about'),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildUserStats(
    BuildContext context,
    MisskeyUser? misskeyUser,
    flarum_model.User? flarumUser,
  ) {
    if (misskeyUser == null && flarumUser == null) {
      return const SizedBox.shrink();
    }

    final List<Widget> stats = [];

    if (misskeyUser != null) {
      // Misskey Stats
      if (misskeyUser.createdAt != null) {
        stats.add(
          _buildStatItem(
            context,
            'Joined',
            DateFormat.yMMMd().format(misskeyUser.createdAt!),
          ),
        );
      }
      if (misskeyUser.notesCount != null) {
        stats.add(
          _buildStatItem(
            context,
            'user_details_notes_count'.tr(),
            _formatCount(misskeyUser.notesCount!),
          ),
        );
      }
      if (misskeyUser.followingCount != null) {
        stats.add(
          _buildStatItem(
            context,
            'user_details_following'.tr(),
            _formatCount(misskeyUser.followingCount!),
          ),
        );
      }
      if (misskeyUser.followersCount != null) {
        stats.add(
          _buildStatItem(
            context,
            'user_details_followers'.tr(),
            _formatCount(misskeyUser.followersCount!),
          ),
        );
      }
    } else if (flarumUser != null) {
      // Flarum Stats
      // Join Time
      stats.add(
        _buildStatItem(
          context,
          'Joined',
          DateFormat.yMMMd().format(DateTime.parse(flarumUser.joinTime)),
        ),
      );

      // Posts (Discussions)
      stats.add(
        _buildStatItem(
          context,
          'user_details_discussions'.tr(),
          _formatCount(flarumUser.discussionCount),
        ),
      );

      // Recovered (Comments)
      stats.add(
        _buildStatItem(
          context,
          'user_details_comments'.tr(),
          _formatCount(flarumUser.commentCount),
        ),
      );
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stats
          .map(
            (s) => Padding(padding: const EdgeInsets.only(right: 16), child: s),
          )
          .toList(),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
                offset: const Offset(0, 1),
              ),
            ],
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
