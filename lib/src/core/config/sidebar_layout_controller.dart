import 'package:shared_preferences/shared_preferences.dart';

enum SidebarDisplayMode {
  collapsed,
  expanded,
  auto,
}

class SidebarLayoutController {
  static const String _prefsKeyMode = 'sidebar_display_mode';
  static const String _prefsKeyManuallyCollapsed = 'sidebar_manually_collapsed';

  SidebarLayoutState _state = const SidebarLayoutState(
    displayMode: SidebarDisplayMode.auto,
    isManuallyCollapsed: false,
  );

  SidebarLayoutState get state => _state;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_prefsKeyMode);
    final manuallyCollapsed = prefs.getBool(_prefsKeyManuallyCollapsed) ?? false;

    SidebarDisplayMode mode = SidebarDisplayMode.auto;
    if (modeStr == 'collapsed') {
      mode = SidebarDisplayMode.collapsed;
    } else if (modeStr == 'expanded') {
      mode = SidebarDisplayMode.expanded;
    }

    _state = SidebarLayoutState(
      displayMode: mode,
      isManuallyCollapsed: manuallyCollapsed,
    );
  }

  Future<void> setDisplayMode(SidebarDisplayMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyMode, mode.name);

    _state = _state.copyWith(displayMode: mode);
  }

  Future<void> toggleCollapse() async {
    final prefs = await SharedPreferences.getInstance();
    final newState = !_state.isManuallyCollapsed;
    await prefs.setBool(_prefsKeyManuallyCollapsed, newState);

    _state = _state.copyWith(isManuallyCollapsed: newState);
  }

  Future<void> collapse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyManuallyCollapsed, true);
    _state = _state.copyWith(isManuallyCollapsed: true);
  }

  Future<void> expand() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyManuallyCollapsed, false);
    _state = _state.copyWith(isManuallyCollapsed: false);
  }
}

class SidebarLayoutState {
  final SidebarDisplayMode displayMode;
  final bool isManuallyCollapsed;

  const SidebarLayoutState({
    required this.displayMode,
    required this.isManuallyCollapsed,
  });

  SidebarLayoutState copyWith({
    SidebarDisplayMode? displayMode,
    bool? isManuallyCollapsed,
  }) {
    return SidebarLayoutState(
      displayMode: displayMode ?? this.displayMode,
      isManuallyCollapsed: isManuallyCollapsed ?? this.isManuallyCollapsed,
    );
  }

  bool shouldCollapse(double availableWidth) {
    switch (displayMode) {
      case SidebarDisplayMode.collapsed:
        return true;
      case SidebarDisplayMode.expanded:
        return false;
      case SidebarDisplayMode.auto:
        if (isManuallyCollapsed) return true;
        return availableWidth < 900;
    }
  }

  double calculateWidth(double availableWidth) {
    if (shouldCollapse(availableWidth)) {
      return 72.0;
    }

    const ratio = 1 / 3;
    final calculatedWidth = availableWidth * ratio;

    const minWidth = 240.0;
    const maxWidth = 320.0;

    return calculatedWidth.clamp(minWidth, maxWidth);
  }
}
