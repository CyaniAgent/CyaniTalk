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
    if (await canLaunchUrl(uri)) {
      logger.info('启动浏览器进行MiAuth授权');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      logger.info('MiAuth授权页面已打开，返回会话ID');
      return session;
    } else {
      logger.error('无法启动MiAuth URL: ${uri.toString()}');
      throw Exception('无法启动MiAuth URL');
    }
  }

  /// 检查Misskey MiAuth认证状态

  ///

  /// [host] - Misskey实例的主机地址

  /// [session] - 认证会话ID

  ///

  /// 成功时保存账户信息并刷新状态，失败时抛出异常

  Future<void> checkMiAuth(String host, String session) async {
    final sanitizedHost = _sanitizeHost(host);
    logger.info('检查Misskey MiAuth认证状态，主机: $sanitizedHost');
    // 稍微等待，确保服务器已经处理了授权
    logger.debug('等待500毫秒确保服务器处理授权');
    await Future.delayed(const Duration(milliseconds: 500));

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://$sanitizedHost',

        connectTimeout: const Duration(seconds: 10),

        receiveTimeout: const Duration(seconds: 10),

        headers: {'User-Agent': 'CyaniTalk/1.0.0'},
      ),
    );

    try {
      logger.debug('发送MiAuth状态检查请求: /api/miauth/$session/check');
      // 显式传递空对象，确保某些严格的服务器不会报错
      final response = await dio.post('/api/miauth/$session/check', data: {});
      logger.debug('收到MiAuth状态检查响应');

      final data = response.data;
      logger.debug('MiAuth响应数据: $data');

      if (data is Map && data['ok'] == true) {
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

          logger.info('当前Misskey账户数量: $misskeyAccounts');
          if (misskeyAccounts >= 10) {
            logger.warning('Misskey账户数量达到上限 (10个)');
            throw Exception(
              'You have reached the limit of 10 Misskey accounts.',
            );
          }
          logger.info('创建新的Misskey账户');
        } else {
          logger.info('更新现有Misskey账户');
        }

        final account = Account(
          id: accountId, // 复合ID
          platform: 'misskey',
          host: sanitizedHost,
          username: user['username'],
          avatarUrl: user['avatarUrl'],
          token: token,
        );

        logger.debug('保存账户信息');
        await repository.saveAccount(account);

        // Automatically select the new account
        logger.debug('自动选择新账户');
        await ref.read(selectedMisskeyAccountProvider.notifier).select(account);

        // Upate state without re-initializing the whole Notifier
        logger.debug('更新认证服务状态');
        final updatedAccounts = await repository.getAccounts();
        state = AsyncData(updatedAccounts);

        logger.info('Misskey MiAuth认证流程完成');
      } else {
        final errorMsg = data is Map ? data['error'] ?? '未授予令牌' : '响应格式错误';
        logger.error('MiAuth检查失败: $errorMsg');
        throw Exception('MiAuth检查失败: $errorMsg (Data: $data)');
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      logger.error('检查MiAuth失败 (HTTP $statusCode): ${e.message}', e);
      throw Exception(
        '检查MiAuth失败 (HTTP $statusCode): ${e.message} \nResponse: $responseData',
      );
    } catch (e) {
      if (e.toString().contains('limit of 10')) {
        rethrow;
      }
      logger.error('检查MiAuth时发生意外错误: $e', e);
      throw Exception('检查MiAuth时发生意外错误: $e');
    }
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

      // 获取用户信息以填充头像和准确的用户名（可选，但推荐）
      // 这里暂时使用登录时提供的标识符，如果有 userId 可以后续通过 API 获取详细资料

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
        username: identification,
        avatarUrl: null, // 如果需要，可以进一步调用 API 获取
        token: token,
      );

      logger.debug('保存Flarum账户信息');
      await repository.saveAccount(account);

      // Automatically select the new account
      logger.debug('自动选择新Flarum账户');
      await ref.read(selectedFlarumAccountProvider.notifier).select(account);

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

    // Re-evaluate selected accounts (the providers watch authServiceProvider so they should update automatically)
    logger.debug('重新评估选中的账户');
    ref.invalidate(selectedMisskeyAccountProvider);
    ref.invalidate(selectedFlarumAccountProvider);
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
