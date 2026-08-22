# PROJECT KNOWLEDGE BASE


## OVERVIEW
Nyachi: cross-platform (Android/iOS/Windows/macOS/Linux) Flutter social client bridging **Misskey** (microblogging + realtime streaming) and **Flarum** (forums), by CyaniAgent. Riverpod 3 + go_router + dio + freezed codegen; Material 3 Expressive; AGPL-3.0. Version 1.3.4+224.

## STRUCTURE
```
lib/
├── main.dart              # Entry: bootstrap, deferred service init
├── src/
│   ├── app.dart           # Root widget: MaterialApp.router, theme, lifecycle
│   ├── core/              # Cross-cutting infra (api, config, services, theme, utils...)
│   ├── features/          # 10 feature modules (clean-arch layers)
│   ├── routing/           # go_router (router.dart + generated .g.dart)
│   └── shared/            # Cross-feature widgets + extensions
└── oss_licenses.dart      # Generated license blob
assets/                    # fonts (MiSans, JetBrainsMono), icons, sounds, translations
docs/                      # ARCHITECTURE.md, OPTIMIZATION_GUIDE.md, ui/ audits
.github/workflows/         # dev/nightly/prerelease/release builds + opencode.yml
```
Platform dirs (`android/ ios/ windows/ macos/ linux/`) = stock Flutter embedders, no app logic.

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Boot sequence | `lib/main.dart` → `lib/src/app.dart` | main.dart runs 1st: window, logger, i18n, ProviderContainer |
| Add/change a route | `lib/src/routing/router.dart` | goRouterProvider; `.g.dart` regenerated |
| Misskey API calls | `lib/src/core/api/misskey_api.dart` | 1220 lines, largest api client |
| New feature module | `lib/src/features/<name>/` | copy layered layout (domain/application/data/presentation) |
| Realtime/streaming | `lib/src/features/misskey/application/misskey_streaming_service.dart` | WS via web_socket_channel |
| Theme/colors/fonts | `lib/src/core/theme/` | M3 Expressive, dynamic_color |
| Notifications/audio/background | `lib/src/core/services/` | notification_service, audio_engine, background_service |
| API contract | `Int_Doc/Misskey_api.yaml` | gitignored; Misskey spec |
| Architecture rationale | `docs/ARCHITECTURE.md` | partially stale (bitsdojo_window, l10n/ no longer exist) |
| Coding conventions | `docs/OPTIMIZATION_GUIDE.md` | de-facto standard |

## CODE MAP
LSP/codegraph unavailable in this env — centrality unmeasured; from source reading.

| Symbol | Type | Location | Refs | Role |
|--------|------|----------|------|------|
| `main()` | function | `lib/main.dart` | n/a | bootstrap entry |
| `NyachiApp` | widget | `lib/src/app.dart` | n/a | root widget |
| `goRouterProvider` | provider | `lib/src/routing/router.dart` | n/a | route hub, 4-shell branches |
| `MisskeyRepository` | class | `lib/src/features/misskey/data/misskey_repository.dart` | n/a | 1384 lines, misskey data layer |
| `MisskeyNotifier` | notifier | `lib/src/features/misskey/application/misskey_notifier.dart` | n/a | 779 lines, state core |
| `misskey_streaming_service` | provider | `lib/src/features/misskey/application/misskey_streaming_service.dart` | n/a | WS keep-alive, event broadcast |
| `MisskeyApi` | class | `lib/src/core/api/misskey_api.dart` | n/a | REST client, HTTP/2 |
| `MfmRenderer` | widget | `lib/src/features/misskey/domain/mfm_renderer.dart` | n/a | MFM syntax → RichText |
| `ModernNoteCard` | widget | `lib/src/features/misskey/presentation/widgets/modern_note_card.dart` | n/a | 1923 lines, timeline card |
| `CloudPage` | page | `lib/src/features/cloud/presentation/cloud_page.dart` | n/a | 2078 lines, Drive UI |
| `BaseApi` | class | `lib/src/core/api/` | n/a | API base w/ executeApiCall |

## CONVENTIONS
- **Lints**: flutter_lints + `prefer_const_constructors`, `prefer_const_declarations`, `sort_child_properties_last`, `unnecessary_lambdas`, `always_declare_return_types`; `use_null_aware_elements: ignore`.
- **Codegen**: freezed/json_serializable/riverpod_generator via build_runner; generated `.g.dart`/`.freezed.dart` ARE committed. Run `dart run build_runner build --delete-conflicting-outputs` after touching annotated classes.
- **Versioning is CI-owned**: workflows rewrite `+<build>` in pubspec.yaml (release `+<commitcount>`, dev `+.dev.<sha>`, nightly `nightly-YYYYMMDD-<n>`). Do NOT hand-bump build number; keep `version:` as `1.x.y`.
- **API layer**: all API classes extend `BaseApi`, use `executeApiCall()`/`executeApiCallVoid()` — never hand-written try/catch. Log via `logger.apiStart/apiSuccess/apiError`.
- **State/UI**: Riverpod everywhere (`@riverpod` + generated notifiers); `ConsumerStatefulWidget`; `ListView.builder`; const constructors; `autoDispose`; `RepaintBoundary`; breakpoint 600dp (mobile=BottomNavigationBar, desktop=NavigationRail+Master-Detail).
- **i18n**: easy_localization JSON in `assets/translations/` (zh-CN, en-US, ja-JP + "Miao" variants); fallback ja-JP.
- **Android signing**: `android/key.properties` (gitignored); CI injects via `ANDROID_KEYSTORE_BASE64` + password secrets; falls back to debug signing when absent.
- **License**: AGPL-3.0; regenerate `lib/oss_licenses.dart` via `dart run dart_pubspec_licenses:generate` after dep changes.

## ANTI-PATTERNS (THIS PROJECT)
- **Never edit generated files** — `.g.dart`, `.freezed.dart`, `oss_licenses.dart`: `// GENERATED CODE - DO NOT MODIFY BY HAND`. Edit source, regenerate.
- **Never hand-write try/catch per API call** — use `BaseApi.executeApiCall`.
- **No business logic in widgets** — Notifiers/providers own state; widgets render.
- **Tokens never in plain SharedPreferences** — only `flutter_secure_storage`/encrypted storage.
- **No `Colors.xxx` direct references** — use `colorScheme.*` (12+ files cited in project_analysis_report.md).
- **Desktop side panels: no `showGeneralDialog` hack** — use `showDialog` + custom layout or real route.
- **Deprecated surface**: nav ids `flarum`/`forum` retired (silently skipped in navigation_settings_notifier.dart); `flutter_adaptive_scaffold` is dead dep (migrate to `adaptive_shell`); `MaterialTheme` + `SaucePalette.lightScheme/darkScheme` scheduled for deletion; `ProfileLoginReminder` already deleted (login prompts use shared `LoginReminder`).
- **Streaming invariants**: message-handling errors must NOT drop the WS connection; send failures must NOT crash — reconnect instead (misskey_streaming_service.dart:229,537).
- **Never claim task complete before `flutter analyze` clean** ("No issues found!") — enforced by .trae code-verification skill.

## UNIQUE STYLES
- Custom "Miao" locales (zh-Miao, en-Miao, ja-Miao, miao-Miao) — Easter-egg language.
- Custom MFM renderer (misskey/domain/mfm_renderer.dart) instead of packaged renderer; `mfm` package only for parsing.
- Material 3 Expressive ecosystem: `m3e_collection`, `m3e_design`, `slider_m3e`, `loading_indicator_m3e`.
- In-app updater polls `api.github.com/repos/CyaniAgent/Nyachi/releases/latest`; distribution = GitHub Releases page.
- Windows MSI (`Nyachi-SetupFiles/`) built locally, NOT in CI.

## COMMANDS
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after annotated-class edits
flutter analyze                                             # must be clean
dart format                                                 # default 80 cols
flutter test                                                # no tests exist yet
dart run dart_pubspec_licenses:generate                     # after dep changes
flutter run -d windows|macos|linux
flutter build apk --split-per-abi | appbundle | windows | linux | macos
flutter build ios --release --no-codesign
```

## NOTES
- `AGENTS.md` itself is gitignored (`.gitignore` line ~135) — local agent knowledge, not committed.
- **No `test/` directory** — tests were deleted in commit `61cbcf2` (3 repo tests + template widget_test). Recreate convention: `test/` mirrors `lib/src/`, `*_test.dart`, mocktail. CI runs no tests/analyze.
- Primary branch is **Dev** (CI builds on push); main/Beta exist.
- `docs/ARCHITECTURE.md` is stale: references `constants/`, `messages/`, `admin/`, `l10n/`, bitsdojo_window, audioplayers — actual: `config/`, `messaging/`, window_manager, flutter_soloud.
- `custom_lint`/`riverpod_lint` declared but NOT activated (no plugins: section, no custom_lint.yaml).
- Generated-only clutter on disk (gitignored): `.dart_tool/`, `build/`, `android/.gradle`, platform `flutter/ephemeral/`, `Nyachi-cache/`, `Nyachi-SetupFiles/`.
