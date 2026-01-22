import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/account.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final FlutterSecureStorage _storage;
  static const _kAccountsKey = 'cyani_accounts';

  AuthRepository(this._storage);

  Future<List<Account>> getAccounts() async {
    final jsonString = await _storage.read(key: _kAccountsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Account.fromJson(e)).toList();
    } catch (e) {
      // In case of corruption, return empty
      return [];
    }
  }

  Future<void> saveAccount(Account account) async {
    final accounts = await getAccounts();
    // Remove existing account with same ID if any (update scenario)
    final newAccounts = [...accounts.where((a) => a.id != account.id), account];

    await _storage.write(
      key: _kAccountsKey,
      value: jsonEncode(newAccounts.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> removeAccount(String id) async {
    final accounts = await getAccounts();
    final newAccounts = accounts.where((a) => a.id != id).toList();

    await _storage.write(
      key: _kAccountsKey,
      value: jsonEncode(newAccounts.map((e) => e.toJson()).toList()),
    );
  }
}

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage();
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(storage);
}
