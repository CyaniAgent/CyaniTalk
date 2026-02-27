import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'developer_settings_provider.g.dart';

@Riverpod(keepAlive: true)
class DeveloperSettingsNotifier extends _$DeveloperSettingsNotifier {
  static const _kDeveloperMode = 'developer_mode';

  @override
  FutureOr<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDeveloperMode) ?? false;
  }

  Future<void> setDeveloperMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDeveloperMode, value);
    state = AsyncData(value);
  }
}
