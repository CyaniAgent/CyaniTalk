// 认证相关的数据仓库
//
// 该文件包含AuthRepository类，负责处理账户信息的持久化存储和检索，
// 使用flutter_secure_storage进行安全存储。
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/account.dart';

part 'auth_repository.g.dart';

/// 认证仓库类
///
/// 负责处理账户信息的持久化存储和检索，支持添加、获取和删除账户。
class AuthRepository {
  /// FlutterSecureStorage实例，用于安全存储账户信息
  final FlutterSecureStorage _storage;
  
  /// 存储账户信息的密钥
  static const _kAccountsKey = 'cyani_accounts';
  static const _kSelectedMisskeyIdKey = 'cyani_selected_misskey_id';
  static const _kSelectedFlarumIdKey = 'cyani_selected_flarum_id';

  /// 创建一个新的AuthRepository实例
  ///
  /// [_storage] - FlutterSecureStorage实例，用于安全存储
  AuthRepository(this._storage);

  /// 获取所有已保存的账户
  ///
  /// 返回包含所有账户的Future列表
  Future<List<Account>> getAccounts() async {
    final jsonString = await _storage.read(key: _kAccountsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Account.fromJson(e)).toList();
    } catch (e) {
      // 在数据损坏的情况下，返回空列表
      return [];
    }
  }

  Future<String?> getSelectedMisskeyId() async {
    return await _storage.read(key: _kSelectedMisskeyIdKey);
  }

  Future<void> saveSelectedMisskeyId(String id) async {
    await _storage.write(key: _kSelectedMisskeyIdKey, value: id);
  }

  Future<String?> getSelectedFlarumId() async {
    return await _storage.read(key: _kSelectedFlarumIdKey);
  }

  Future<void> saveSelectedFlarumId(String id) async {
    await _storage.write(key: _kSelectedFlarumIdKey, value: id);
  }

  /// 保存或更新账户
  ///
  /// [account] - 要保存的账户实例
  Future<void> saveAccount(Account account) async {
    final accounts = await getAccounts();
    // 如果存在相同ID的账户，则替换它（更新场景）
    final newAccounts = [...accounts.where((a) => a.id != account.id), account];

    await _storage.write(
      key: _kAccountsKey,
      value: jsonEncode(newAccounts.map((e) => e.toJson()).toList()),
    );
  }

  /// 删除指定ID的账户
  ///
  /// [id] - 要删除的账户ID
  Future<void> removeAccount(String id) async {
    final accounts = await getAccounts();
    final newAccounts = accounts.where((a) => a.id != id).toList();

    await _storage.write(
      key: _kAccountsKey,
      value: jsonEncode(newAccounts.map((e) => e.toJson()).toList()),
    );
  }
}

/// 提供FlutterSecureStorage实例的Riverpod提供者
///
/// 该提供者创建并返回一个FlutterSecureStorage实例，用于安全存储数据。
@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage();
}

/// 提供AuthRepository实例的Riverpod提供者
///
/// 该提供者创建并返回一个AuthRepository实例，用于处理账户信息的存储和检索。
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(storage);
}
