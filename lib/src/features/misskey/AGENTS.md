# PROJECT KNOWLEDGE BASE: misskey feature

## OVERVIEW
Dominant module: Misskey client core. 102 Dart files (63 source, 25 `.g.dart`, 14 `.freezed.dart`), full clean-arch 4-layer split. Owns realtime streaming, timelines, compose, profiles, notifications, Drive, AiScript. Most stateful and most generated-code-heavy module in the repo.

## STRUCTURE
```
misskey/
├── domain/                # 40 files (15 source)
│   ├── note.dart, misskey_user.dart, misskey_notification.dart, poll.dart,
│   │   emoji.dart, drive_file.dart, drive_folder.dart, channel.dart, clip.dart,
│   │   chat_room.dart, messaging_message.dart, announcement.dart, upload_task.dart
│   ├── note_event.dart           # plain class, NO generated files
│   ├── announcement.dart         # freezed but NO .g.dart (hand-written JSON)
│   ├── poll.freezed.dart (1393), emoji.freezed.dart (863)   # biggest generated
│   └── mfm_renderer.dart         # 773, custom MFM -> RichText widget
├── application/           # 27 files (14 source)
│   ├── misskey_notifier.dart                     # 918, global state core
│   ├── misskey_streaming_service.dart            # 545, WS keep-alive + broadcast
│   ├── note_cache_manager.dart                   # 641
│   ├── *_notifier.dart                           # drive, upload, user, notifications, messaging, announcements
│   ├── audio_player_notifier.dart, aiscript_interpreter.dart
│   └── timeline_animated_list_controller.dart, timeline_animation_state.dart,
│       timeline_jump_provider.dart
├── data/                  # 3 files
│   ├── misskey_repository.dart                   # 1483, data layer, largest in module
│   ├── misskey_repository_interface.dart
│   └── misskey_repository.g.dart
└── presentation/          # 32 files: misskey_page.dart (shell) + 14 pages + 17 widgets
    ├── pages/misskey_user_profile_page.dart      # 1427
    ├── pages/misskey_post_page.dart              # 906, compose
    ├── pages/misskey_timeline_page.dart, misskey_notes_page.dart,
    │   misskey_notifications_page.dart, misskey_channels_page.dart ...
    └── widgets/modern_note_card.dart             # 2083, timeline card
        widgets/note_details_sheet.dart (865), drive_file_picker.dart (691),
        poll_settings_sheet.dart (540), poll_card.dart, emoji_picker.dart,
        reaction_display.dart, safe_mfm_widget.dart ...
```

## WHERE TO LOOK
| Task | Location |
|------|----------|
| Global misskey state | `application/misskey_notifier.dart` |
| WS streaming, event broadcast | `application/misskey_streaming_service.dart` |
| Note cache / memory policy | `application/note_cache_manager.dart` |
| All REST data ops | `data/misskey_repository.dart` (implements interface) |
| Note rendering | `domain/mfm_renderer.dart` + `widgets/modern_note_card.dart` |
| Compose / posting | `pages/misskey_post_page.dart` + poll_* widgets |
| User profile | `pages/misskey_user_profile_page.dart` |
| Notifications page | `pages/misskey_notifications_page.dart` + `misskey_notifications_notifier.dart` |
| Drive files / upload | `drive_notifier.dart`, `file_upload_notifier.dart` + `widgets/drive_file_picker.dart` |
| AiScript | `application/aiscript_interpreter.dart` |
| Timeline animation | `timeline_animated_list_controller.dart` + `timeline_jump_provider.dart` |
| Audio playback | `application/audio_player_notifier.dart` (flutter_soloud) |

## CONVENTIONS (misskey-specific)
- Every model is `@freezed` + `@JsonSerializable`; each source file pairs with `.freezed.dart` + `.g.dart` (announcement and note_event excepted).
- Notifiers take `MisskeyRepository` via constructor injection; generated providers wire them. Widgets never touch the repository.
- Streaming service owns 5 broadcast `StreamController`s (note, raw message, messaging, status, toast). UI reads via stream providers, never writes.
- MFM: `mfm` package parses ONLY; `MfmRenderer` renders. `safe_mfm_widget.dart` wraps renderer for per-note error isolation.
- Widgets take raw model objects, not `WidgetRef` (reusable across timelines/pages, testable).
- Poll UX is split across poll_card, poll_choice_input, poll_time_selector, poll_settings_sheet; emoji_picker feeds them.

## NOTES
- `note_event.dart` has no generated files; `announcement.dart` lacks `.g.dart`. build_runner will not touch either; do not add generated siblings.
- `misskey_repository.dart` is one 1483-line file by design; do not split casually, downstream notifiers import it everywhere.
- Audio goes through `audio_player_notifier.dart` (flutter_soloud), never raw plugin calls.
- Timeline insertion is driven by the NoteEvent union; add event kinds to the union + stream provider, not new ad-hoc controllers.
- 39 generated files dominate any diff; edit source only.
- Line counts current as of 2026-08-13; generated sizes shift with every build_runner run.
