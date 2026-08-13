# FEATURE MODULES KNOWLEDGE BASE

**Scope:** `lib/src/features/` — 10 feature modules, clean-arch layers.
**Parent:** root `AGENTS.md` = global conventions (Riverpod, codegen, no logic in widgets). This file = feature inventory + layer convention only.

## OVERVIEW
Feature-first vertical slices; wired into the app ONLY via `lib/src/routing/router.dart`; state flows through Riverpod providers (auto-generated `.g.dart`).

## THE LAYERED LAYOUT
- `domain/` — pure models (freezed, `.freezed.dart`/`.g.dart` committed), entities, domain services (e.g. MFM parsing). No Flutter imports, no IO.
- `application/` — `@riverpod` notifiers/providers, use-cases, streaming services. Owns state; widgets never call these directly.
- `data/` — repositories implementing interfaces; `BaseApi`/`executeApiCall` calls happen ONLY here.
- `presentation/` — `pages/` + `widgets/`. Render provider state; zero business logic.

Full 4-layer ONLY in `auth` + `misskey`; the rest are thinner (application+presentation or presentation-only). Files per layer are `index.dart`-barreled.

## FEATURE MAP
| Feature | Files | What it does |
|---------|-------|--------------|
| `misskey/` | 102 | Dominant core: timelines, realtime WS, MFM, Drive, composer, notifications. **SEE `misskey/AGENTS.md`** (full 4-layer). |
| `profile/` | 30 | Profile tab + full settings subsystem. **SEE `profile/AGENTS.md`** (application+presentation). |
| `auth/` | 14 | MiAuth login, token storage, session setup. Smallest complete 4-layer example. |
| `common/` | 9 | Cross-feature media: `presentation/widgets/media/` (7 files; `audio_player_sheet` 570) + `media_viewer`. Presentation-only. |
| `update/` | 6 | In-app updater: polls `api.github.com/repos/CyaniAgent/CyaniTalk/releases/latest`, opens GitHub Releases (application+domain+presentation). |
| `welcome/` | 3 | Onboarding. `welcome_page.dart` 958 (application+presentation). |
| `cloud/` | 2 | Drive UI. `cloud_page.dart` 2078 (presentation-only). |
| `messaging/` | 2 | Messaging tab. `messaging_page.dart` 551 (presentation-only). |
| `search/` | 1 | Global search across Misskey+Flarum (presentation-only). |
| `forum/` | 1 | Flarum bridge, presentation-only, **RETIRED**: nav ids `flarum`/`forum` removed, integration disabled. |

## WHERE TO LOOK
| Task | Location |
|------|----------|
| Add a new feature | copy the layered skeleton of `auth/` (smallest complete example) |
| Wire a feature page into nav | `lib/src/routing/router.dart` (features never import routing) |
| Realtime/misskey core | `misskey/application/` + `misskey/data/` |
| Drive/cloud file management | `cloud/presentation/cloud_page.dart` |
| Cross-feature media widgets | `common/presentation/widgets/media/` |
| App settings | `profile/presentation/settings/` |

## NOTES
- Features MUST NOT import each other's presentation layers; share via `lib/src/shared/` or `lib/src/core/`.
- Layer deps point one way: presentation → application → data/domain. Never reverse.
- `domain/` stays Flutter-free; pure shared code lives in `lib/src/core/` or `lib/src/shared/`.
- Generated `*.g.dart`/`.freezed.dart` sit next to sources — regenerate, never hand-edit.
- `forum/` remains on disk for reference; do not build on it.
- Regenerate after freezed/riverpod edits: `dart run build_runner build --delete-conflicting-outputs`.
