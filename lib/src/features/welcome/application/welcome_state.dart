import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'welcome_state.g.dart';

@riverpod
class WelcomeStep extends _$WelcomeStep {
  static const totalSteps = 6;

  @override
  int build() => 0;

  void next() {
    if (state < WelcomeStep.totalSteps) state = state + 1;
  }

  void previous() {
    if (state > 0) state = state - 1;
  }

  void goTo(int step) {
    if (step >= 0 && step <= WelcomeStep.totalSteps) state = step;
  }
}

@Riverpod(keepAlive: true)
class WelcomeCompleted extends _$WelcomeCompleted {
  static const _kWelcomeCompleted = 'welcome_completed';

  @override
  FutureOr<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kWelcomeCompleted) ?? false;
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kWelcomeCompleted, true);
    state = const AsyncData(true);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kWelcomeCompleted);
    state = const AsyncData(false);
  }
}

@Riverpod(keepAlive: true)
class SetupStatus extends _$SetupStatus {
  StreamSubscription<String>? _sub;

  @override
  String? build() {
    ref.onDispose(() {
      _sub?.cancel();
    });
    return null;
  }

  void watch(Stream<String> stream) {
    _sub?.cancel();
    _sub = stream.listen((status) {
      state = status;
    });
  }
}
