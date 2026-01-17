import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

import '../data/auth_repository.dart';
import '../domain/account.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
class AuthService extends _$AuthService {
  @override
  FutureOr<List<Account>> build() async {
    final repository = ref.watch(authRepositoryProvider);
    return repository.getAccounts();
  }

  // Misskey MiAuth Flow
  Future<String> startMiAuth(String host) async {
    final session = const Uuid().v4();
    final uri = Uri.https(host, '/miauth/$session', {
      'name': 'CyaniTalk',
      'permission':
          'read:account,write:notes,read:channels,write:channels,read:drive,write:drive,read:notifications,read:messaging,write:messaging', // Request permissions needed
      // 'callback': 'cyanitalk://callback', // Deep link if needed in future
    });

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return session;
    } else {
      throw Exception('Could not launch MiAuth URL');
    }
  }

  Future<void> checkMiAuth(String host, String session) async {
    final dio = Dio(); // Should use a proper Dio provider in production
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
            id: '${user['id']}@$host', // Composite ID
            platform: 'misskey',
            host: host,
            username: user['username'],
            avatarUrl: user['avatarUrl'],
            token: token,
          );

          await ref.read(authRepositoryProvider).saveAccount(account);

          // Refresh state
          ref.invalidateSelf();
        } else {
          throw Exception('MiAuth check failed: Token not granted');
        }
      } else {
        throw Exception('MiAuth check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to check MiAuth: $e');
    }
  }

  // Flarum Simple Auth
  Future<void> linkFlarumAccount(
    String host,
    String token,
    String username,
  ) async {
    // For now, we trust the user input as per "structure first" requirement
    // In real app, we should verify token via API call e.g. /api/users

    final account = Account(
      id: '$username@$host',
      platform: 'flarum',
      host: host,
      username: username,
      avatarUrl: null, // Placeholder
      token: token,
    );

    await ref.read(authRepositoryProvider).saveAccount(account);
    ref.invalidateSelf();
  }

  Future<void> removeAccount(String id) async {
    await ref.read(authRepositoryProvider).removeAccount(id);
    ref.invalidateSelf();
  }
}
