# CORE (lib/src/core/)

## OVERVIEW
Cross-cutting infrastructure consumed by every feature module: API clients, config, shell-nav state, global services, theme, utils. 72 Dart files, 7 subdirs. `core.dart` barrel exports config/utils/theme; `main.dart`/`app.dart` import the barrel PLUS direct paths (`http_overrides.dart`, `background_service.dart`, `notification_*.dart`, `audio_engine.dart`, `theme/font_*.dart`).

## STRUCTURE
- `api/` (4) — `base_api.dart` (abstract BaseApi, 403 lines); `misskey_api.dart` (1294 lines, Misskey REST, sole BaseApi subclass); `network_client.dart` (232 lines: NetworkClient singleton + Retry/Performance/RateLimit interceptors inline); `api_request_manager.dart` (191: singleton, per-account response cache + in-flight dedup, 5-min cleanup timer)
- `config/` (6) — `config.dart` barrel; `constants.dart` (no .env: hardcoded Dart consts — UA string, log defaults), `navigation_config.dart`, `navigation_settings_config.dart`, `page_config.dart`, `sidebar_layout_controller.dart`
- `navigation/` (11) — shell + tab state: `navigation_controller.dart`, `navigation_settings_notifier.dart`, `sub_navigation_notifier.dart`, `navigation_service.dart`, `navigation.dart`; models (`navigation_item.dart`, `navigation_element.dart`, `navigation_settings.dart`)
- `services/` (25) — `audio_engine.dart` (flutter_soloud) + `sound_service.dart`; `notification_service.dart` + `notification_manager.dart`; `background_service.dart` (flutter_background_service); `dynamic_color_service.dart`, `app_reset_service.dart`, `device_info_service.dart`, `file_metadata_service.dart`, `database_path_helper.dart`, `navigation_service.dart`, `navigation_state_tracker.dart`; SQLite caches (`misskey_image_cache_database.dart`, `misskey_image_cache_service.dart`, `timeline_cache_database.dart`); subdirs `search/` (global_search_service + delegate), `streaming/` (`streaming_service_interface.dart`)
- `theme/` (12) — M3 tokens: `design_tokens.dart`, `color_constants.dart`, `sauce_palette.dart`, `typography.dart`, `desktop_semantic_colors.dart`; fonts MiSans + JetBrainsMono (`font_manager.dart`, `font_settings_notifier.dart`, `font_refresh_notifier.dart`, `font_selector.dart`)
- `utils/` (11) — `logger.dart` (637) + `logger_extension.dart` (apiStart/apiSuccess/apiError), `cache_manager.dart` (1059), `http_overrides.dart`, `error_handler.dart`, `performance_monitor.dart`, `download_utils.dart`, `data_conversion.dart`, `file_icon_manager.dart`, `verification_window.dart`
- `widgets/` (2) — `sound_picker.dart`, `settings_widgets.dart`

## WHERE TO LOOK
| Task | Location |
|------|----------|
| Build a Dio instance | `api/network_client.dart` → `NetworkClient().createDio(...)` (sanitizeHost, 30s timeouts, interceptor stack, IOHttpClientAdapter) |
| Misskey REST calls | `api/misskey_api.dart` |
| Cache/dedup an API response | `api/api_request_manager.dart` → `execute()` |
| App-wide constants (UA, log defaults) | `config/constants.dart` |
| Shell tabs / nav settings | `navigation/` |
| Audio / notifications / background | `services/audio_engine.dart`, `sound_service.dart`, `notification_*.dart`, `background_service.dart` |
| Persisted media/timeline cache | `services/*_cache_database.dart` + `utils/cache_manager.dart` |
| Theme tokens / fonts / Material You | `theme/` |
| Logging (runtime level, file cleanup) | `utils/logger.dart` → `initialize({logLevel})` / `setLogLevel()` |
| TLS / cert overrides | `utils/http_overrides.dart`, NetworkClient `enableCertificateValidation` |

## CONVENTIONS (core-specific)
- Barrel discipline: `core.dart` exports config/utils/theme only; api/navigation/services/widgets are imported by path. A public file not added to a barrel is unreachable outside core/.
- Config lives in `config/constants.dart` as Dart consts. Never introduce dotenv/.env.
- Core singletons use private ctor + `static final _instance` + factory (AppLogger, NetworkClient, ApiRequestManager).
- No business logic here: core owns infra only; feature state lives in `lib/src/features/`.

## NOTES
- `dio_http2_adapter` is in pubspec but imported NOWHERE in lib/ (only `oss_licenses.dart`) — dead dep. NetworkClient uses `IOHttpClientAdapter`; cert bypass (`badCertificateCallback => true`) applies ONLY when `enableCertificateValidation: false` (dev convenience, not a security boundary; default is validation ON).
- `misskey_api.dart` (1294), `cache_manager.dart` (1059), `logger.dart` (637) are the three biggest core files — extract before growing them further.
- ApiRequestManager keys cache by `host:token`; `setAccountContext` clears cache + in-flight dedup on account switch — stale-response bugs live here.
- Nav ids `flarum`/`forum` deprecated: silently skipped via `_deprecatedItemIds` in `navigation_settings_notifier.dart`.
- `NetworkClient.sanitizeHost` strips invalid ports (`:0`) to dodge 500/524 — preserve it when touching createDio.
- RetryInterceptor retries 5xx EXCEPT 500/504/524 (retry worsens overload); also retries handshake/semaphore-timeout (`121`) with exponential backoff (500ms·2^n).
- Background entry points (`onStart`/`onIosBackground`) need `@pragma('vm:entry-point')` — flutter_background_service requirement, keep it.
- Logger level is runtime-configurable (in-memory); SharedPreferences keys `log_max_size`/`log_auto_clear`/`log_retention_days` drive file cleanup only.
