import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
abstract class Account with _$Account {
  const factory Account({
    required String id,
    required String platform, // 'misskey' or 'flarum'
    required String host,
    required String? username,
    required String? avatarUrl,
    required String token, // Access Token for Misskey or Token for Flarum
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
