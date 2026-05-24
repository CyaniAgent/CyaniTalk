import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_update.freezed.dart';
part 'app_update.g.dart';

@freezed
abstract class AppUpdate with _$AppUpdate {
  const factory AppUpdate({
    required String latestVersion,
  }) = _AppUpdate;

  factory AppUpdate.fromJson(Map<String, dynamic> json) =>
      _$AppUpdateFromJson(json);
}
