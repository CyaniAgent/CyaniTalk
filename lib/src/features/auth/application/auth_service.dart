// 认证相关的应用服务
//
// 该文件包含AuthService类，负责处理认证流程，包括Misskey的MiAuth流程
// 和Flarum的账户链接功能。
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

import '../data/auth_repository.dart';
import '../domain/account.dart';
import '../../../core/api/flarum_api.dart';
import '../../../core/core.dart';

part 'auth_service.g.dart';

/// 认证服务类
///
/// 负责处理用户认证流程，包括Misskey的MiAuth流程和Flarum的账户链接功能，
/// 管理认证状态和账户信息。
@Riverpod(keepAlive: true)
class AuthService extends _$AuthService {
  /// 初始化认证服务状态
  ///
  /// 从认证仓库中获取所有已保存的账户，并将其作为初始状态。
  ///
  /// 返回包含所有账户的Future列表
  @override
  FutureOr<List<Account>> build() async {
    logger.info('初始化认证服务');
    final repository = ref.watch(authRepositoryProvider);
    final accounts = await repository.getAccounts();
    logger.info('认证服务初始化完成，加载了 ${accounts.length} 个账户');
    return accounts;
  }

  /// 启动Misskey的MiAuth认证流程

  ///

  /// [host] - Misskey实例的主机地址

  ///

  /// 返回会话ID，用于后续检查认证状态

  /// 启动Misskey的MiAuth认证流程
  Future<String> startMiAuth(String host) async {
    final sanitizedHost = _sanitizeHost(host);
    logger.info('开始Misskey MiAuth认证流程，主机: $sanitizedHost (原始: $host)');
    final accounts = await ref.read(authRepositoryProvider).getAccounts();

    final misskeyAccounts = accounts
        .where((a) => a.platform == 'misskey')
        .length;

    logger.info('当前Misskey账户数量: $misskeyAccounts');
    if (misskeyAccounts >= 10) {
      logger.warning('Misskey账户数量达到上限 (10个)');
      throw Exception('You have reached the limit of 10 Misskey accounts.');
    }

    final session = const Uuid().v4();
    logger.debug('生成MiAuth会话ID: $session');

    final uri = Uri.https(sanitizedHost, '/miauth/$session', {
      'name': 'CyaniTalk',

      'permission':
          'read:account,write:notes,read:channels,write:channels,read:drive,write:drive,read:notifications,read:messaging,write:messaging', // 请求所需权限
      // 'callback': 'cyanitalk://callback', // 未来可能需要的深度链接
    });

    logger.debug('生成MiAuth URL: ${uri.toString()}');

    // On some Android versions, canLaunchUrl might return false even if it works.
    // We attempt to launch and catch errors for better reliability.
    try {
      logger.info('尝试启动浏览器进行MiAuth授权');
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        logger.info('MiAuth授权页面已成功打开');
        return session;
      } else {
        logger.error('launchUrl 返回 false: ${uri.toString()}');
        throw Exception('无法打开浏览器进行授权');
      }
    } catch (e) {
      logger.error('启动MiAuth URL时发生错误: $e', e);
      throw Exception('授权流程启动失败: 请检查您的设备是否安装了浏览器');
    }
  }

  /// 检查Misskey MiAuth认证状态

  ///

  /// [host] - Misskey实例的主机地址

  /// [session] - 认证会话ID

  ///

  /// 成功时保存账户信息并刷新状态，失败时抛出异常

  /// 检查Misskey MiAuth认证状态
  ///
  /// [host] - Misskey实例的主机地址
  /// [session] - 认证会话ID
  ///
  /// 成功时保存账户信息并刷新状态，失败时抛出异常
  Future<void> checkMiAuth(String host, String session) async {
    final sanitizedHost = _sanitizeHost(host);
    logger.info('检查Misskey MiAuth认证状态，主机: $sanitizedHost');

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://$sanitizedHost',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36',
        },
      ),
    );

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        if (retryCount > 0) {
          logger.debug('重试检查MiAuth状态 (${retryCount + 1}/$maxRetries)...');
          await Future.delayed(const Duration(seconds: 1));
        } else {
          // Initial wait
          await Future.delayed(const Duration(milliseconds: 500));
        }

        logger.debug('发送MiAuth状态检查请求: /api/miauth/$session/check');
        final response = await dio.post('/api/miauth/$session/check', data: {});
        logger.debug('收到MiAuth状态检查响应');

        final data = response.data;
        // Check for both 'ok' field and strict 'true' value
        if (data is Map && data['ok'] == true) {
          await _handleSuccessfulAuth(data, sanitizedHost);
          return;
        } else {
          // If 'ok' is false, it might mean 'pending' or 'denied'.
          // However, Misskey API usually returns ok: true if authorized, and separate error otherwise?
          // Actually, if it's still pending, it might just return ok: false or error.
          // We will retry if it's likely a timing issue, or throw if it's definitive.
          logger.debug('MiAuth检查未通过: $data');
        }
      } on DioException catch (e) {
        logger.warning(
          '检查MiAuth HTTP错误 (Attempt ${retryCount + 1}): ${e.message}',
        );
        if (e.response != null) {
          logger.warning('Response Body: ${e.response?.data}');
        }
        // Don't rethrow immediately on network glitches, try again
      } catch (e) {
        logger.error('检查MiAuth非预期错误: $e');
      }

      retryCount++;
    }

    throw Exception('无法完成认证，请确认您已在浏览器中批准授权。');
  }

  Future<void> _handleSuccessfulAuth(
    Map<dynamic, dynamic> data,
    String sanitizedHost,
  ) async {
    final token = data['token'];
    final user = data['user'];

    if (token == null || user == null) {
      logger.error('MiAuth响应缺少必要字段 (token或user)');
      throw Exception('MiAuth响应缺少必要字段 (token或user)');
    }

    final accountId = '${user['id']}@$sanitizedHost';
    logger.info('MiAuth认证成功，用户: ${user['username']}, 账户ID: $accountId');

    final repository = ref.read(authRepositoryProvider);
    final accounts = await repository.getAccounts();

    final existingAccount = accounts
        .where((a) => a.id == accountId)
        .firstOrNull;

    if (existingAccount == null) {
      final misskeyAccounts = accounts
          .where((a) => a.platform == 'misskey')
          .length;

      if (misskeyAccounts >= 10) {
        logger.warning('Misskey账户数量达到上限 (10个)');
        throw Exception('You have reached the limit of 10 Misskey accounts.');
      }
    }

    final account = Account(
      id: accountId, // 复合ID
      platform: 'misskey',
      host: sanitizedHost,
      username: user['username'],
      name: user['name'],
      avatarUrl: user['avatarUrl'],
      token: token,
    );

    await repository.saveAccount(account);

    // Automatically select the new account by saving the ID to repository
    // We avoid calling the provider directly to prevent CircularDependencyError
    // as SelectedMisskeyAccount depends on AuthService.
    await repository.saveSelectedMisskeyId(account.id);

    // Upate state without re-initializing the whole Notifier
    final updatedAccounts = await repository.getAccounts();
    state = AsyncData(updatedAccounts);

    logger.info('Misskey MiAuth认证流程完成');
  }

  /// 登录 Flarum 账户

  ///

  /// [host] - Flarum 实例的主机地址

  /// [identification] - 用户名或电子邮箱

  /// [password] - 密码

  ///

  /// 验证成功后保存账户信息并刷新状态

  Future<void> loginToFlarum(
    String host,
    String identification,
    String password,
  ) async {
    logger.info('开始Flarum登录流程，主机: $host, 用户: $identification');
    final api = FlarumApi();

    final originalBaseUrl = api.baseUrl;
    logger.debug('原始BaseUrl: $originalBaseUrl');

    try {
      // 临时设置 BaseUrl 进行登录验证
      logger.debug('设置BaseUrl为: https://$host');
      api.setBaseUrl('https://$host');

      logger.debug('发送Flarum登录请求');
      final loginData = await api.login(identification, password);
      logger.debug('收到Flarum登录响应: $loginData');

      final token = loginData['token'];
      final userId = loginData['userId'].toString();

      if (token == null) {
        logger.error('Flarum登录响应缺少必要字段 (token)');
        throw Exception('Flarum登录响应缺少必要字段 (token)');
      }

      // 获取用户信息以填充头像和准确的用户名
      logger.info('正在获取Flarum用户详细资料');
      final profileData = await api.getUserProfile(userId);
      final attributes = profileData['data']?['attributes'] ?? {};
      final displayName = attributes['displayName'];
      final username = attributes['username'];
      final avatarUrl = attributes['avatarUrl'];

      final accountId = '$userId@$host';
      logger.info('Flarum登录成功，用户ID: $userId, 账户ID: $accountId');

      final repository = ref.read(authRepositoryProvider);
      final accounts = await repository.getAccounts();
      final existingAccount = accounts
          .where((a) => a.id == accountId)
          .firstOrNull;

      if (existingAccount == null) {
        final flarumAccounts = accounts
            .where((a) => a.platform == 'flarum')
            .length;

        logger.info('当前Flarum账户数量: $flarumAccounts');
        if (flarumAccounts >= 10) {
          logger.warning('Flarum账户数量达到上限 (10个)');
          throw Exception('You have reached the limit of 10 Flarum accounts.');
        }
        logger.info('创建新的Flarum账户');
      } else {
        logger.info('更新现有Flarum账户');
      }

      final account = Account(
        id: accountId,
        platform: 'flarum',
        host: host,
        username: username ?? identification,
        name: displayName ?? username ?? identification,
        avatarUrl: avatarUrl,
        token: token,
      );

      logger.debug('保存Flarum账户信息');
      await repository.saveAccount(account);

      // Automatically select the new account
      logger.debug('自动选择新Flarum账户');
      await repository.saveSelectedFlarumId(account.id);

      // 保存到 FlarumApi 的持久化存储中
      logger.debug('保存Flarum端点和令牌');
      await api.saveEndpoint('https://$host');
      await api.saveToken('https://$host', token);

      logger.debug('更新认证服务状态');
      final updatedAccounts = await repository.getAccounts();
      state = AsyncData(updatedAccounts);

      logger.info('Flarum登录流程完成');
    } catch (e) {
      // 还原 BaseUrl

      if (originalBaseUrl != null) {
        logger.debug('还原BaseUrl为: $originalBaseUrl');
        api.setBaseUrl(originalBaseUrl);
      }
      logger.error('Flarum登录失败: $e', e);
      throw Exception('Flarum 登录失败: $e');
    }
  }

  /// 删除指定ID的账户

  ///

  /// [id] - 要删除的账户ID

  ///

  /// 删除账户后刷新状态

  Future<void> removeAccount(String id) async {
    logger.info('删除账户，账户ID: $id');
    await ref.read(authRepositoryProvider).removeAccount(id);
    logger.debug('账户删除成功');

    logger.debug('更新认证服务状态');
    final updatedAccounts = await ref
        .read(authRepositoryProvider)
        .getAccounts();
    state = AsyncData(updatedAccounts);

    // Selected accounts will automatically re-evaluate since they watch authServiceProvider
    logger.debug('选中的账户将自动重新评估');
    logger.info('账户删除流程完成');
  }

  /// 清理主机地址，提取出域名部分
  String _sanitizeHost(String host) {
    String sanitized = host.trim();
    if (sanitized.startsWith('https://')) {
      sanitized = sanitized.substring(8);
    } else if (sanitized.startsWith('http://')) {
      sanitized = sanitized.substring(7);
    }

    // 移除路径部分
    if (sanitized.contains('/')) {
      sanitized = sanitized.split('/').first;
    }

    // 移除可能的查询参数或锚点
    if (sanitized.contains('?')) {
      sanitized = sanitized.split('?').first;
    }
    if (sanitized.contains('#')) {
      sanitized = sanitized.split('#').first;
    }

    logger.debug('Sanitized host: $host -> $sanitized');
    return sanitized;
  }
}

@Riverpod(keepAlive: true)
class SelectedMisskeyAccount extends _$SelectedMisskeyAccount {
  @override
  FutureOr<Account?> build() async {
    final accounts = await ref.watch(authServiceProvider.future);

    final repository = ref.read(authRepositoryProvider);

    final selectedId = await repository.getSelectedMisskeyId();

    if (selectedId != null) {
      try {
        return accounts.firstWhere((a) => a.id == selectedId);
      } catch (_) {}
    }

    return accounts.where((a) => a.platform == 'misskey').firstOrNull;
  }

  Future<void> select(Account account) async {
    if (account.platform != 'misskey') return;

    state = AsyncData(account);

    await ref.read(authRepositoryProvider).saveSelectedMisskeyId(account.id);
  }
}

@Riverpod(keepAlive: true)
class SelectedFlarumAccount extends _$SelectedFlarumAccount {
  @override
  FutureOr<Account?> build() async {
    final accounts = await ref.watch(authServiceProvider.future);

    final repository = ref.read(authRepositoryProvider);

    final selectedId = await repository.getSelectedFlarumId();

    if (selectedId != null) {
      try {
        return accounts.firstWhere((a) => a.id == selectedId);
      } catch (_) {}
    }

    return accounts.where((a) => a.platform == 'flarum').firstOrNull;
  }

  Future<void> select(Account account) async {
    if (account.platform != 'flarum') return;

    state = AsyncData(account);

    await ref.read(authRepositoryProvider).saveSelectedFlarumId(account.id);
  }
}

/// Deprecated: Use selectedMisskeyAccountProvider or selectedFlarumAccountProvider

final selectedAccountProvider = StateProvider<Account?>((ref) {
  final accountsAsync = ref.watch(authServiceProvider);

  return accountsAsync.maybeWhen(
    data: (accounts) => accounts.isNotEmpty ? accounts.first : null,

    orElse: () => null,
  );
});
