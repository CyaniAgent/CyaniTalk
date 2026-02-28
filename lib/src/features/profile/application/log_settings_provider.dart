import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/src/core/core.dart';

part 'log_settings_provider.g.dart';

class LogSettings {
  final String logLevel;
  final int maxLogSize;
  final bool autoClear;
  final int retentionDays;

  LogSettings({
    required this.logLevel,
    required this.maxLogSize,
    required this.autoClear,
    required this.retentionDays,
  });

  LogSettings copyWith({
    String? logLevel,
    int? maxLogSize,
    bool? autoClear,
    int? retentionDays,
  }) {
    return LogSettings(
      logLevel: logLevel ?? this.logLevel,
      maxLogSize: maxLogSize ?? this.maxLogSize,
      autoClear: autoClear ?? this.autoClear,
      retentionDays: retentionDays ?? this.retentionDays,
    );
  }
}

@Riverpod(keepAlive: true)
class LogSettingsNotifier extends _$LogSettingsNotifier {
  static const _kLogLevel = 'log_level';
  static const _kMaxLogSize = 'log_max_size';
  static const _kAutoClear = 'log_auto_clear';
  static const _kRetentionDays = 'log_retention_days';

  @override
  FutureOr<LogSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return LogSettings(
      logLevel: prefs.getString(_kLogLevel) ?? Constants.defaultLogLevel,
      maxLogSize: prefs.getInt(_kMaxLogSize) ?? Constants.defaultMaxLogSize,
      autoClear: prefs.getBool(_kAutoClear) ?? true,
      retentionDays: prefs.getInt(_kRetentionDays) ?? 7,
    );
  }

  Future<void> setLogLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLogLevel, level);
    state = AsyncData(state.value!.copyWith(logLevel: level));
    logger.setLogLevel(level);
  }

  Future<void> setMaxLogSize(int size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kMaxLogSize, size);
    state = AsyncData(state.value!.copyWith(maxLogSize: size));
    await logger.setMaxLogSize(size);
  }

  Future<void> setAutoClear(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoClear, value);
    state = AsyncData(state.value!.copyWith(autoClear: value));
  }

  Future<void> setRetentionDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kRetentionDays, days);
    state = AsyncData(state.value!.copyWith(retentionDays: days));
  }
}
