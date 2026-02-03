// 认证相关的领域模型
//
// 该文件定义了Account类，用于表示用户在不同平台上的认证账户信息。
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

/// 表示用户在不同平台上的认证账户
///
/// 使用freezed生成不可变数据类，用于存储用户的认证信息，
/// 支持Misskey和Flarum两个平台。
@freezed
abstract class Account with _$Account {
  /// 创建一个新的Account实例
  ///
  /// [id] - 账户的唯一标识符，格式为"用户ID@主机名"
  /// [platform] - 平台类型，只能是'misskey'或'flarum'
  /// [host] - 账户所在的主机地址
  /// [username] - 用户名，可为空
  /// [avatarUrl] - 头像URL，可为空
  /// [token] - 认证令牌，Misskey的访问令牌或Flarum的令牌
  const factory Account({
    required String id,
    required String platform, // 'misskey' or 'flarum'
    required String host,
    required String? username,
    required String? name,
    required String? avatarUrl,
    required String token, // Access Token for Misskey or Token for Flarum
  }) = _Account;

  /// 从JSON数据创建Account实例
  ///
  /// [json] - 包含账户信息的JSON映射
  ///
  /// 返回一个新的Account实例
  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
