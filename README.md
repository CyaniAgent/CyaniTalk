# CyaniTalk

[**中文**](README_CN.md) | [**English**](README.md)

---

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Misskey](https://img.shields.io/badge/Misskey-97c41a?style=for-the-badge&logo=misskey&logoColor=white)
![Flarum](https://img.shields.io/badge/Flarum-E7742E?style=for-the-badge&logo=flarum&logoColor=white)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow?style=for-the-badge)

**CyaniTalk** is a diversified, cross-platform social client built with Flutter. It bridges the gap between **Misskey** (decentralized micro-blogging) and **Flarum** (structured community forums), offering a unified experience for both casual social interaction and deep technical discussions.

Designed with a **Responsive Shell**, CyaniTalk adapts seamlessly between mobile (iOS/Android) and desktop (Windows/macOS/Linux) environments, providing native-tier features like real-time streaming and advanced administrative tools.

---

## 🌟 Key Features

### 🎨 Adaptive UI/UX
CyaniTalk decouples the navigation logic from the content to provide an ergonomic experience on any device:
*   **Mobile:** Classic **Bottom Navigation Bar** for one-handed use.
*   **Desktop:** Vertical **Navigation Rail** for wide screens, utilizing a Master-Detail view for efficient browsing.
*   **Unified Sections:** Access Misskey, Forum, Drive, Messages, and Profile seamlessly.

### 🪐 Misskey Integration (The "Dynamic" Layer)
*   **Real-time Streaming:** Connects to the Misskey WebSocket (`streaming`) to deliver notes, notifications, and messaging instantly.
*   **Rich Interaction:** Supports posting notes, reactions (Emoji), and basic MFM (Misskey Flavored Markdown) rendering.
*   **Misskey Drive:** A dedicated visual interface for managing cloud files and images.
*   **AiScript & API:** Support for running basic AiScript interactions and an embedded API Console.

### 💬 Flarum Integration (The "Static" Layer)
*   **Structured Discussions:** Browse tags, discussions, and posts with a clean reading experience.
*   **Community interaction:** Create discussions, reply to posts, and manage your forum identity.
*   **Authentication:** Seamless JSON:API based login and token management.

### 🛡️ Admin & Power Tools (Admin Only)
*   **Unified Dashboard:** Detects admin privileges to reveal hidden control panels.
*   **Misskey Control Panel:** View instance health, stats, and moderate users.
*   **Flarum Management:** Basic moderation tools and backend management.
*   **API Console:** A built-in developer tool to test endpoints and inspect JSON responses directly within the app.

---

## 🛠 Tech Stack

*   **Framework:** [Flutter](https://flutter.dev/) (Dart)
*   **State Management:** [Riverpod](https://riverpod.dev/) (Handling multi-account states).
*   **Networking:**
    *   `dio` (REST API calls).
    *   `web_socket_channel` (Misskey Streaming).
*   **UI Components:** `flutter_adaptive_scaffold` (or custom LayoutBuilder implementation), `flutter_markdown`.
*   **Storage:** `hive` or `shared_preferences` for local caching and token storage.

---

## 🗺️ Development Roadmap

### Phase 1: The Responsive Foundation 🚧
- [ ] Initialize Flutter project.
- [ ] Implement the **Responsive Shell** (Bottom Nav vs. Nav Rail).
- [ ] Create skeleton pages for the 5 main tabs.

### Phase 2: Authentication & Core Connectivity
- [ ] Implement **MiAuth** flow for Misskey.
- [ ] Implement Token retrieval for Flarum.
- [ ] Create the Unified Login Manager.

### Phase 3: The Real-time Engine
- [ ] Establish WebSocket connections for Misskey.
- [ ] Implement global event distribution (Notifications/New Notes).
- [ ] Build the "Messages" tab aggregation.

### Phase 4: Content & Creation
- [ ] **Misskey:** Timeline rendering and Posting interface.
- [ ] **Flarum:** Discussion list and Thread view.
- [ ] **Drive:** File grid view and upload functionality.

### Phase 5: Admin Tools & Polish
- [ ] Build the API Console.
- [ ] Implement Admin-only route protection.
- [ ] Desktop-specific optimizations (keyboard shortcuts, window management).

---

## 🚀 Getting Started

*Prerequisites: Flutter SDK installed.*

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/cyanitalk.git
    cd cyanitalk
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    # For Mobile
    flutter run

    # For Desktop (macOS/Windows/Linux)
    flutter run -d windows # or macos/linux
    ```

---

## 🤝 Contributing

This project is currently in the **Greenfield** stage. Contributions, especially regarding MFM parsing and Flarum JSON:API handling, are welcome!

## 📄 License

[MIT License](LICENSE)