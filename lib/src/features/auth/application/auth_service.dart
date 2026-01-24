// 认证相关的应用服务
//
// 该文件包含AuthService类，负责处理认证流程，包括Misskey的MiAuth流程
// 和Flarum的账户链接功能。
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

import '../data/auth_repository.dart';
import '../domain/account.dart';

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
    final dio = Dio(); // 生产环境中应使用适当的Dio提供者
    try {
      final response = await dio.post(
        'https://$host/api/miauth/$session/check',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['ok'] == true) {
          final token = data['token'];
          final user = data['user'];

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
          throw Exception('MiAuth检查失败: 未授予令牌');
        }
      } else {
        throw Exception('MiAuth检查失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('检查MiAuth失败: $e');
    }
  }

  /// 链接Flarum账户
  ///
  /// [host] - Flarum实例的主机地址
  /// [token] - Flarum访问令牌
  /// [username] - Flarum用户名
  ///
  /// 目前信任用户输入，实际应用中应通过API调用验证令牌
  Future<void> linkFlarumAccount(
    String host,
    String token,
    String username,
  ) async {
    // 目前根据"结构优先"的要求信任用户输入
    // 实际应用中，我们应该通过API调用（如/api/users）验证令牌

    final account = Account(
      id: '$username@$host',
      platform: 'flarum',
      host: host,
      username: username,
      avatarUrl: null, // 占位符
      token: token,
    );

    await ref.read(authRepositoryProvider).saveAccount(account);
    ref.invalidateSelf();
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
