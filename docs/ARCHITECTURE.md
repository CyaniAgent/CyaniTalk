# Architecture Design Document

## 1. Overview
CyaniTalk is a complex, data-intensive Flutter application that interacts with two distinct backend ecosystems: **Misskey** (Node.js/Postgres) and **Flarum** (PHP/MySQL).

The architecture follows a **Feature-First, Layered Architecture** powered by **Riverpod** for dependency injection and state management. This approach ensures scalability, testability, and a clean separation of concerns between the "Real-time" nature of Misskey and the "Structured" nature of Flarum.

---

## 2. Directory Structure

We utilize a **Feature-Based** directory structure. Code is organized by what it *does* (e.g., Auth, Forum, Timeline) rather than what it *is* (e.g., Screens, Widgets).

```text
CyaniTalk/
├── assets/                  # Static resources
│   ├── fonts/               # Custom fonts (Google Sans, JetBrains Mono, etc.)
│   ├── images/              # Icons, logos, placeholders
│   └── sounds/              # Notification sounds (wav/mp3)
├── lib/
│   ├── main.dart            # Entry point
│   ├── src/
│   │   ├── app.dart         # Root widget (Theme, Routing setup)
│   │   ├── core/            # System-wide utilities
│   │   │   ├── api/         # Dio clients, Interceptors, Exception handling
│   │   │   ├── constants/   # App-wide constants (URLs, Enums)
│   │   │   ├── theme/       # AppTheme, ColorPalettes
│   │   │   └── utils/       # Helpers (Date formatters, String extensions)
│   │   ├── features/        # Business Logic Modules
│   │   │   ├── auth/        # Login (MiAuth & Flarum Token)
│   │   │   ├── misskey/     # Streaming, Notes, MFM Rendering, Drive
│   │   │   ├── flarum/      # Discussions, Tags, JSON:API parsing
│   │   │   ├── messages/    # Aggregated Messaging System
│   │   │   └── admin/       # API Console, Admin Dashboard
│   │   ├── routing/         # GoRouter configuration
│   │   └── shared/          # Common Widgets (Buttons, Loaders, ErrorViews)
│   └── l10n/                # Localization (.arb files)
├── pubspec.yaml
└── README.md
```
---

## 3. The Dual-Core Data Layer
Since the backends talk different languages, the Data Layer is split into two parallel engines.

### 3.1. Misskey Engine
* **Protocol**: REST (HTTP/2) & WebSocket.
* **Authentication**: MiAuth (Session-based).
* **Real-time**: 
    * A global WebSocketService maintains a persistent connection to the Misskey streaming endpoint.
    * Incoming events (note, notification) are broadcast via a StreamController.
* **Data Models**: Plain Dart objects generated from JSON (using json_serializable).

### 3.2. Flarum Engine
* **Protocol**: REST (JSON:API Specification).
* **Authentication**: Token-based.
* **Parsing Strategy**：
    * Flarum responses are deeply nested (data, included, relationships).
    * We use a dedicated JsonApiParser service to flatten these responses into consumable Domain Entities.

---

## 4. State Management (Riverpod)

We use Riverpod to manage state and inject dependencies.

* **Providers**: Used for singleton services (e.g., dioProvider, secureStorageProvider).
* **Notifiers / AsyncNotifiers**: Used for business logic (e.g., TimelineController, LoginController).
* **StreamProviders**: Used for listening to WebSocket events (e.g., messageStreamProvider).

### Example Data Flow (Posting a Note)

1. **UI**: User clicks "Send" in ComposerWidget.
2. **Controller**: CreateNoteController receives the text.
3. **Repository**: MisskeyRepository.createNote() calls the API via Dio.
4. **State Update**: On success, the controller invalidates the timelineProvider to fetch the new post (or relies on the WebSocket stream to push it).

---

## 5. Adaptive UI/UX Strategy

CyaniTalk uses a Responsive Shell architecture to separate navigation logic from content.

### 5.1. The Breakpoint System

We define a logic breakpoint at 600dp width.

* **< 600dp (Mobile):**
    * Navigation: BottomNavigationBar.
    * Routing: Standard Push/Pop stack.
* **>= 600dp (Desktop):**
    * Navigation: NavigationRail (Left side).
    * Routing: Master-Detail pattern (e.g., clicking a thread in the list opens it on the right side instead of a new page).

### 5.2. Window Management (Desktop)

* **Library**: bitsdojo_window.
* **Behavior**: Custom title bar handling to blend the app header with the OS window frame (removing default white bars on Windows).

---

## 6. Asset Management

Large binary files are strictly kept in the assets/ directory to keep the code clean.

### 6.1. Fonts

Defined in pubspec.yaml.

* **Application Preset Font**: The application uses some built-in fonts.
* **Primary Font**: System default (San Francisco / Segoe UI / Roboto) for readability.
* **Monospace**: Used in the API Console and Code blocks within Markdown.

### 6.2. Sounds

Notification sounds (e.g., ping.mp3, pop.wav) reside in assets/sounds/.

* Implementation: A SoundService class preloads these assets to avoid latency when a message arrives via WebSocket.

Example:
```dart
# pubspec.yaml example
flutter:
  assets:
    - assets/images/
    - assets/sounds/
  fonts:
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
```

---

## 7. Rendering Engine (Markdown & MFM)

Rendering user-generated content is one of the most resource-intensive tasks.

* **Flarum**: Uses standard Markdown. We utilize flutter_markdown with a custom extension for Flarum-specific tags (e.g., [u]user[/u]).
* **Misskey (MFM)**: 
    * Misskey Flavored Markdown includes animations (bounce, shake) and custom syntax.
    * **Strategy**: We implement a custom MfmRenderer widget. It parses the syntax tree and maps it to a RichText widget structure. Complex animations utilize Flutter's AnimationController.

---

## 8. Security & Storage

* **Tokens**:  Access tokens for both platforms are stored in secure storage (flutter_secure_storage or encrypted hive box), never in plain SharedPreferences.
* **Admin Tools**:
    * The API Console and Admin Panels are protected by logic gates.
    * The UI checks user.permissions before rendering the button in the navigation rail.
    * Note: Security ultimately relies on the Backend APIs rejecting unauthorized requests, the UI hiding is just for UX.

---

## 9. Future Considerations

* **Multi-Account**: The architecture supports switching the currentUserId. Providers should be watched/rebuilt when the active user changes.
* **Offline Mode**: We plan to implement hive caching for the Timeline and Forum Thread lists to allow reading without an internet connection.
* **Push Notifications**: We plan to implement push notifications for Misskey and Flarum.