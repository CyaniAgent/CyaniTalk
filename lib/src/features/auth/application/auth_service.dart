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
    final repository = ref.watch(authRepositoryProvider);
    return repository.getAccounts();
  }

  /// 启动Misskey的MiAuth认证流程
  ///
  /// [host] - Misskey实例的主机地址
  ///
  /// 返回会话ID，用于后续检查认证状态
  Future<String> startMiAuth(String host) async {
    final session = const Uuid().v4();
    final uri = Uri.https(host, '/miauth/$session', {
      'name': 'CyaniTalk',
      'permission':
          'read:account,write:notes,read:channels,write:channels,read:drive,write:drive,read:notifications,read:messaging,write:messaging', // 请求所需权限
      // 'callback': 'cyanitalk://callback', // 未来可能需要的深度链接
    });

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return session;
    } else {
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
    // 稍微等待，确保服务器已经处理了授权
    await Future.delayed(const Duration(milliseconds: 500));

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://$host',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'User-Agent': 'CyaniTalk/1.0.0'},
      ),
    );

    try {
      final response = await dio.post('/api/miauth/$session/check');

      final data = response.data;
      if (data is Map && data['ok'] == true) {
        final token = data['token'];
        final user = data['user'];

        if (token == null || user == null) {
          throw Exception('MiAuth响应缺少必要字段 (token或user)');
        }

        final account = Account(
          id: '${user['id']}@$host', // 复合ID
          platform: 'misskey',
          host: host,
          username: user['username'],
          avatarUrl: user['avatarUrl'],
          token: token,
        );

        await ref.read(authRepositoryProvider).saveAccount(account);

        // 刷新状态
        ref.invalidateSelf();
      } else {
        final errorMsg = data is Map ? data['error'] ?? '未授予令牌' : '响应格式错误';
        throw Exception('MiAuth检查失败: $errorMsg (Data: $data)');
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      throw Exception(
        '检查MiAuth失败 (HTTP $statusCode): ${e.message} \nResponse: $responseData',
      );
    } catch (e) {
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
    final api = FlarumApi();
    final originalBaseUrl = api.baseUrl;

    try {
      // 临时设置 BaseUrl 进行登录验证
      api.setBaseUrl('https://$host');
      final loginData = await api.login(identification, password);

      final token = loginData['token'];
      final userId = loginData['userId'].toString();

      // 获取用户信息以填充头像和准确的用户名（可选，但推荐）
      // 这里暂时使用登录时提供的标识符，如果有 userId 可以后续通过 API 获取详细资料

      final account = Account(
        id: '$userId@$host',
        platform: 'flarum',
        host: host,
        username: identification,
        avatarUrl: null, // 如果需要，可以进一步调用 API 获取
        token: token,
      );

      await ref.read(authRepositoryProvider).saveAccount(account);

      // 保存到 FlarumApi 的持久化存储中
      await api.saveEndpoint('https://$host');
      await api.saveToken('https://$host', token);

      ref.invalidateSelf();
    } catch (e) {
      // 还原 BaseUrl
      if (originalBaseUrl != null) {
        api.setBaseUrl(originalBaseUrl);
      }
      throw Exception('Flarum 登录失败: $e');
    }
  }

  /// 删除指定ID的账户
  ///
  /// [id] - 要删除的账户ID
  ///
  /// 删除账户后刷新状态
  Future<void> removeAccount(String id) async {
    await ref.read(authRepositoryProvider).removeAccount(id);
    ref.invalidateSelf();
  }
}

/// 提供当前选中的账户，默认为第一个可用账户
final selectedAccountProvider = StateProvider<Account?>((ref) {
  final accountsAsync = ref.watch(authServiceProvider);
  return accountsAsync.maybeWhen(
    data: (accounts) => accounts.isNotEmpty ? accounts.first : null,
    orElse: () => null,
  );
});
