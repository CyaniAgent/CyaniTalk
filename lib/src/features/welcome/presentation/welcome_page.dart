import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '/src/core/theme/sauce_palette.dart';
import '/src/core/theme/font_settings_notifier.dart';
import '/src/core/utils/cache_manager.dart';
import '/src/core/utils/logger.dart';
import '/src/features/auth/application/auth_service.dart';
import '/src/features/auth/domain/account.dart';
import '/src/features/auth/presentation/widgets/add_account_dialog.dart';
import '/src/features/misskey/application/misskey_notifier.dart';
import '/src/features/misskey/application/misskey_streaming_service.dart';
import '/src/core/services/timeline_cache_database.dart';
import '/src/core/services/misskey_image_cache_database.dart';
import '/src/features/profile/presentation/settings/appearance_page.dart';
import '/src/features/welcome/application/welcome_state.dart';
import '/src/shared/widgets/animated_blob_background.dart';
import '/src/shared/widgets/fireworks_background.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  StreamController<String>? _statusController;

  @override
  void dispose() {
    _statusController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = ref.watch(welcomeStepProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildStepIndicator(step, theme),
              const SizedBox(height: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStep(step, theme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        7,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == step ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == step
                ? SaucePalette.mikuGreen
                : theme.colorScheme.onSurface.withAlpha(40),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int step, ThemeData theme) {
    if (step == 4 && !_isMobile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(welcomeStepProvider.notifier).next();
        }
      });
      return const SizedBox.shrink();
    }

    switch (step) {
      case 0: return _buildStep0(theme);
      case 1: return _buildStep1(theme);
      case 2: return _buildStep2(theme);
      case 3: return _buildStep3(theme);
      case 4: return _buildStep4(theme);
      case 5: return _buildStep5(theme);
      case 6: return _buildStep6(theme);
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildStep0(ThemeData theme) {
    return AnimatedBlobBackground(
      child: Column(
        key: const ValueKey(0),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/icons/logo/desktop/logo-desktop-transparent.png',
              width: 120,
              height: 120,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'welcome_title'.tr(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: SaucePalette.mikuGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'welcome_subtitle'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
          _buildCapsuleButton(
            label: 'welcome_step0_button'.tr(),
            onPressed: () => ref.read(welcomeStepProvider.notifier).next(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStep1(ThemeData theme) {
    final locales = context.supportedLocales;
    final currentLocale = context.locale;

    final localeNames = {
      'zh_CN': '简体中文',
      'en_US': 'English',
      'ja_JP': '日本語',
      'zh_Miao': '中文（喵）',
      'ja_Miao': '日本語（にゃ）',
      'en_Miao': 'English (Nyaa)',
      'miao_Miao': '喵语',
    };

    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          'welcome_step1_title'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'welcome_step1_description'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: locales.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final locale = locales[index];
              final localeStr = locale.toString();
              final isSelected = localeStr == currentLocale.toString();

              return _buildLanguageTile(
                theme: theme,
                label: localeNames[localeStr] ?? localeStr,
                isSelected: isSelected,
                onTap: () => context.setLocale(locale),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildCapsuleButton(
          label: 'welcome_step1_next'.tr(),
          onPressed: () => ref.read(welcomeStepProvider.notifier).next(),
          filled: false,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLanguageTile({
    required ThemeData theme,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? SaucePalette.mikuGreen.withAlpha(20)
              : theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? SaucePalette.mikuGreen : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: SaucePalette.mikuGreen, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(ThemeData theme) {
    final displayMode = ref.watch(appearanceSettingsProvider).asData?.value.displayMode;

    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          'welcome_step2_title'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Column(
            children: [
              _buildThemeOption(
                theme: theme,
                icon: Icons.light_mode,
                label: 'appearance_light'.tr(),
                isSelected: displayMode == ThemeMode.light,
                onTap: () => ref
                    .read(appearanceSettingsProvider.notifier)
                    .updateDisplayMode(ThemeMode.light),
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                theme: theme,
                icon: Icons.dark_mode,
                label: 'appearance_dark'.tr(),
                isSelected: displayMode == ThemeMode.dark,
                onTap: () => ref
                    .read(appearanceSettingsProvider.notifier)
                    .updateDisplayMode(ThemeMode.dark),
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                theme: theme,
                icon: Icons.settings_brightness,
                label: 'appearance_system'.tr(),
                isSelected: displayMode == ThemeMode.system,
                onTap: () => ref
                    .read(appearanceSettingsProvider.notifier)
                    .updateDisplayMode(ThemeMode.system),
              ),
              const SizedBox(height: 24),
              Text(
                'welcome_step2_font'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              _buildFontOption(theme, 'MiSans'),
              const SizedBox(height: 8),
              _buildFontOption(theme, 'system'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildBottomNav(
          backLabel: 'welcome_step2_back'.tr(),
          onBack: () => ref.read(welcomeStepProvider.notifier).previous(),
          nextLabel: 'welcome_step2_next'.tr(),
          onNext: () => ref.read(welcomeStepProvider.notifier).next(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildThemeOption({
    required ThemeData theme,
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? SaucePalette.mikuGreen.withAlpha(20)
              : theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? SaucePalette.mikuGreen : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: SaucePalette.mikuGreen, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: SaucePalette.mikuGreen, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFontOption(ThemeData theme, String fontId) {
    final currentFont = ref.watch(fontSettingsProvider).asData?.value.selectedFontId;
    final isSelected = currentFont == fontId;
    final label = fontId == 'MiSans'
        ? 'MiSans'
        : 'appearance_system_font'.tr();

    return InkWell(
      onTap: () => _selectFont(fontId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? SaucePalette.mikuGreen.withAlpha(20)
              : theme.colorScheme.surfaceContainerHighest.withAlpha(50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? SaucePalette.mikuGreen : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: fontId == 'MiSans' ? 'MiSans' : null,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: SaucePalette.mikuGreen, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFont(String fontId) async {
    final fontFamily = await ref.read(fontSettingsProvider.notifier).selectFont(fontId);
    if (fontFamily != null && mounted) {
      await ref
          .read(appearanceSettingsProvider.notifier)
          .updateFontFamily(fontFamily);
    }
  }

  Widget _buildStep3(ThemeData theme) {
    final accountsAsync = ref.watch(authServiceProvider);

    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          'welcome_step3_title'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'welcome_step3_description'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: accountsAsync.when(
            data: (accounts) => accounts.isNotEmpty
                ? _buildExistingAccounts(theme, accounts)
                : _buildNoAccounts(theme),
            loading: () => const Center(child: CyaniLoadingIndicator()),
            error: (_, _) => _buildNoAccounts(theme),
          ),
        ),
        const SizedBox(height: 16),
        _buildBottomNav(
          backLabel: 'welcome_step3_back'.tr(),
          onBack: () => ref.read(welcomeStepProvider.notifier).previous(),
          nextLabel: 'welcome_step3_next'.tr(),
          onNext: () => ref.read(welcomeStepProvider.notifier).next(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildExistingAccounts(ThemeData theme, List<Account> accounts) {
    return ListView(
      children: [
        ...accounts.map((account) => _buildAccountTile(theme, account)),
        const SizedBox(height: 16),
        _buildCapsuleButton(
          label: 'welcome_step3_add_account'.tr(),
          onPressed: () => AddAccountBottomSheet.show(context),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => ref.read(welcomeStepProvider.notifier).next(),
            child: Text(
              'welcome_step3_skip'.tr(),
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoAccounts(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_alt_1,
            size: 64,
            color: SaucePalette.mikuGreen.withAlpha(150),
          ),
          const SizedBox(height: 24),
          _buildCapsuleButton(
            label: 'welcome_step3_add_account'.tr(),
            onPressed: () => AddAccountBottomSheet.show(context),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => ref.read(welcomeStepProvider.notifier).next(),
            child: Text(
              'welcome_step3_skip'.tr(),
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(ThemeData theme, Account account) {
    final displayName = (account.name != null && account.name!.isNotEmpty)
        ? account.name!
        : (account.username ?? 'Unknown');
    final subtitle = account.username != null
        ? '@${account.username}'
        : '';

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await ref.read(welcomeCompletedProvider.notifier).markCompleted();
          if (mounted) context.go('/misskey');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: account.avatarUrl != null
                    ? NetworkImage(account.avatarUrl!)
                    : null,
                child: account.avatarUrl == null
                    ? Text(account.username?[0].toUpperCase() ?? '?')
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/misskey.png',
                          width: 14,
                          height: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          account.host,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  Widget _buildStep4(ThemeData theme) {
    return Column(
      key: const ValueKey(4),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          'welcome_step4_title'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: [
              _buildPermissionCard(
                theme: theme,
                icon: Icons.notifications_active,
                title: 'welcome_step4_notification_title'.tr(),
                description:
                    'welcome_step4_notification_description'.tr(),
                buttonLabel: 'welcome_step4_notification_button'.tr(),
                onPressed: _requestNotificationPermission,
              ),
              const SizedBox(height: 16),
              _buildPermissionCard(
                theme: theme,
                icon: Icons.battery_charging_full,
                title: 'welcome_step4_background_title'.tr(),
                description:
                    'welcome_step4_background_description'.tr(),
                isInfoOnly: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildBottomNav(
          backLabel: 'welcome_step4_back'.tr(),
          onBack: () => ref.read(welcomeStepProvider.notifier).previous(),
          nextLabel: 'welcome_step4_next'.tr(),
          onNext: () => ref.read(welcomeStepProvider.notifier).next(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPermissionCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String description,
    String? buttonLabel,
    VoidCallback? onPressed,
    bool isInfoOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: SaucePalette.mikuGreen, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: onPressed,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final plugin = FlutterLocalNotificationsPlugin();
      final androidImpl = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final plugin = FlutterLocalNotificationsPlugin();
      final iosImpl = plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Widget _buildStep5(ThemeData theme) {
    _startAutoSetup();

    final statusKey = ref.watch(setupStatusProvider);

    return Column(
      key: const ValueKey(5),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const CyaniLoadingIndicator(
          color: SaucePalette.mikuGreen,
          size: 48,
        ),
        const SizedBox(height: 24),
        Text(
          'welcome_step5_title'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'welcome_step5_description'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (statusKey != null && statusKey.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  statusKey.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        if (ref.watch(currentWelcomeModeProvider) == WelcomePageMode.debug) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withAlpha(80)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 20, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'welcome_step5_debug_hint'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.amber[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const Spacer(flex: 2),
      ],
    );
  }

  bool _setupStarted = false;

  void _startAutoSetup() {
    if (_setupStarted) return;
    _setupStarted = true;
    _statusController = StreamController<String>.broadcast();

    ref.read(setupStatusProvider.notifier).watch(_statusController!.stream);

    _runSetup();
  }

  Future<void> _runSetup() async {
    void updateStatus(String key) {
      if (_statusController != null && !_statusController!.isClosed) {
        _statusController!.add(key);
      }
    }

    if (ref.read(currentWelcomeModeProvider) == WelcomePageMode.debug) {
      final steps = [
        'welcome_step5_creating_database',
        'welcome_step5_creating_cache',
        'welcome_step5_testing_connection',
        'welcome_step5_connecting_stream',
        'welcome_step5_fetching_posts',
        'welcome_step5_caching_resources',
        'welcome_step5_writing_database',
        'welcome_step5_completing',
      ];
      for (final s in steps) {
        updateStatus(s);
        await Future.delayed(const Duration(seconds: 1));
      }
      if (mounted) {
        ref.read(welcomeStepProvider.notifier).next();
      }
      return;
    }

    try {
      updateStatus('welcome_step5_creating_database');
      // Lazy-init database by accessing the database getter
      final imageDb = MisskeyImageCacheDatabase();
      await imageDb.database;
      await Future.delayed(const Duration(milliseconds: 300));

      updateStatus('welcome_step5_creating_cache');
      await cacheManager.getCacheDirectory();
      await Future.delayed(const Duration(milliseconds: 300));

      updateStatus('welcome_step5_testing_connection');
      bool hasNetwork = true;
      try {
        final result = await InternetAddress.lookup('misskey.io');
        hasNetwork = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (_) {
        hasNetwork = false;
      }
      await Future.delayed(const Duration(milliseconds: 300));

      if (hasNetwork) {
        updateStatus('welcome_step5_connecting_stream');
        ref.read(misskeyStreamingServiceProvider.notifier).reconnect();
        await Future.delayed(const Duration(milliseconds: 500));

        updateStatus('welcome_step5_fetching_posts');
        try {
          ref.read(misskeyTimelineProvider('Home').notifier).refresh();
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 500));

        updateStatus('welcome_step5_caching_resources');
        for (final category in CacheCategory.values) {
          await cacheManager.getCategoryCacheDirectory(category);
        }
        await Future.delayed(const Duration(milliseconds: 200));

        updateStatus('welcome_step5_writing_database');
        try {
          final imageCacheCounts = await MisskeyImageCacheDatabase()
              .getRecordCountByType();
          logger.info(
            'Welcome setup: Image cache has ${imageCacheCounts.values.fold<int>(0, (a, b) => a + b)} records',
          );
        } catch (_) {}
        try {
          await TimelineCacheDatabase().getLastRefreshTime('Home');
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 200));
      }

      updateStatus('welcome_step5_completing');
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ref.read(welcomeStepProvider.notifier).next();
      }
    } catch (e, stack) {
      logger.error('Welcome setup failed: $e', e, stack);

      updateStatus('welcome_step5_completing');
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ref.read(welcomeStepProvider.notifier).next();
      }
    }
  }

  Widget _buildStep6(ThemeData theme) {
    return FireworksBackground(
      child: Column(
        key: const ValueKey(6),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(
            'assets/images/WelcomePage/character.png',
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            'welcome_step6_title'.tr(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: SaucePalette.mikuGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'welcome_step6_description'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          _buildCapsuleButton(
            label: 'welcome_step6_button'.tr(),
            onPressed: () async {
              await ref.read(welcomeCompletedProvider.notifier).markCompleted();
              if (mounted) context.go('/misskey');
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCapsuleButton({
    required String label,
    required VoidCallback onPressed,
    bool filled = true,
  }) {
    final style = filled
        ? FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            backgroundColor: SaucePalette.mikuGreen,
          )
        : OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            side: BorderSide(color: SaucePalette.mikuGreen, width: 1.5),
          );

    return SizedBox(
      width: double.infinity,
      child: filled
          ? FilledButton(
              style: style,
              onPressed: onPressed,
              child: Text(label),
            )
          : OutlinedButton(
              style: style,
              onPressed: onPressed,
              child: Text(
                label,
                style: TextStyle(color: SaucePalette.mikuGreen),
              ),
            ),
    );
  }

  Widget _buildBottomNav({
    String? backLabel,
    VoidCallback? onBack,
    required String nextLabel,
    required VoidCallback onNext,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCapsuleButton(label: nextLabel, onPressed: onNext),
        if (backLabel != null && onBack != null) ...[
          const SizedBox(height: 12),
          _buildCapsuleButton(
            label: backLabel,
            onPressed: onBack,
            filled: false,
          ),
        ],
      ],
    );
  }
}


