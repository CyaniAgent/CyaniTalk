# PROFILE (lib/src/features/profile/)

## OVERVIEW
User profile tab + the app-settings subsystem: 30 Dart files; settings notifiers persist via SharedPreferences, appearance drives core/theme.

## STRUCTURE
- presentation/profile_page.dart (620) - profile tab: user card, stats, login state, nav to settings/accounts; watches `misskeyMeProvider`/`selectedMisskeyAccountProvider` for user data (no local data layer)
- presentation/settings/ (15 files, one page per settings section):
  - appearance_page.dart (747) - theme/appearance; **holds AppearanceSettingsNotifier inline** (+ its .g.dart lives here)
  - design_playground_page.dart (1445) - M3 Expressive component demo/testbed, preview theme components
  - cache_settings_page.dart (650) - note/image cache management, cache clear
  - settings_page.dart (260) - hub, rows navigate to every sub-page
  - network/log/notification/sound/developer/navigation/accounts/about/licenses/sponsor pages (143-474)
- presentation/widgets/ (4 files) - user_details_view.dart (+.g.dart), settings_slider_bottom_sheet.dart, associated_accounts_section.dart
- application/ (10 files) - 5 providers x (source + generated): sound, network, log, notification, developer settings; each = `{X}Settings` model + `{X}SettingsNotifier` + `_provider.g.dart`

## WHERE TO LOOK
| Task | Location |
|------|----------|
| Profile tab UI | presentation/profile_page.dart |
| Fonts / palette / dynamic color / theme | presentation/settings/appearance_page.dart |
| Preview M3 Expressive components | presentation/settings/design_playground_page.dart |
| Cache / disk management | presentation/settings/cache_settings_page.dart |
| Sound / network / log / notification / dev toggles | application/<x>_settings_provider.dart (state) + settings/<x>_page.dart (UI) |
| Nav bar item customization | settings/navigation_settings_page.dart (state lives in core, see NOTES) |
| Account switch / add-account | settings/accounts_page.dart + widgets/associated_accounts_section.dart |
| User detail card widget | presentation/widgets/user_details_view.dart |
| Generic slider bottom sheet (settings reuse) | presentation/widgets/settings_slider_bottom_sheet.dart |

## NOTES
- AppearanceSettingsNotifier is defined INSIDE presentation/settings/appearance_page.dart, not application/. All other settings notifiers live in application/. Do NOT "fix" this asymmetry.
- Every settings notifier reads/writes SharedPreferences directly (`getInstance()` in build/methods); there is no central AppSettings repository, and prefs keys are module-private strings.
- ProfileLoginReminder no longer exists (deleted, parent AGENTS.md note is stale); login prompts use shared LoginReminder only.
- about_page.dart persists SharedPreferences directly in its State - widget-layer persistence, a local deviation, not a pattern to copy.
- Navigation settings state is owned by core (navigation_settings_notifier.dart); the page here only renders it. nav ids `flarum`/`forum` are deprecated and silently skipped.
- log_settings feeds core/config log_level; appearance feeds core/theme; sound/notification pages apply values to core services, but the providers themselves import only riverpod_annotation + shared_preferences (wiring happens in the pages).
- accounts_page.dart is only 18 lines - a stub/shell, real logic is in associated_accounts_section.dart.
- No domain/ or data/ layer in this feature: settings are flat key/value prefs, not Misskey/Flarum API models.
