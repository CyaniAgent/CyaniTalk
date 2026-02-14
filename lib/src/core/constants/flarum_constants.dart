class FlarumConstants {
  // Endpoints
  static const String endpointsKey = 'flarum_endpoints';
  static const String currentEndpointKey = 'flarum_current_endpoint';

  // Endpoint data prefix
  static const String endpointDataPrefix = 'flarum_endpoint_';

  // Auth keys
  static const String tokenKey = 'token';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';

  // Preferences
  static const String themeModeKey = 'theme_mode';
  static const String useDynamicColorKey = 'use_dynamic_color';
  static const String accentColorKey = 'accent_color';
  static const String fontSizeKey = 'font_size';
  static const String compactLayoutKey = 'compact_layout';
  static const String showAvatarsKey = 'show_avatars';
  static const String fontFamilyKey = 'font_family';

  // Notifications
  static const String enableNotificationsKey = 'enable_notifications';
  static const String enableMessageNotificationsKey =
      'enable_message_notifications';
  static const String enableMentionNotificationsKey =
      'enable_mention_notifications';
  static const String enableReplyNotificationsKey =
      'enable_reply_notifications';
  static const String enableSystemNotificationsKey =
      'enable_system_notifications';

  // Screen layout
  static const double narrowScreenThreshold = 600;
  static const double wideScreenThreshold = 768;
  static const Duration doubleTapExitDuration = Duration(seconds: 2);

  // Validation
  static const int titleMinLength = 3;
  static const int contentMinLength = 5;

  // Defaults
  static const String defaultThemeMode = 'system';
  static const bool defaultEnableNotifications = true;
  static const bool defaultUseDynamicColor = true;
  static const String defaultAccentColor = 'blue';
  static const String defaultFontFamily = 'Google Sans';

  // API
  static const String userAgentTypeKey = 'user_agent_type';
  static const String userAgentTypeDefault = 'default';
  static const String userAgentTypeChrome = 'chrome';
  static const String userAgentTypeFirefox = 'firefox';
  static const String defaultUserAgentType = 'default';
}
