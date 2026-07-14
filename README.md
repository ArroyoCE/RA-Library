# RetroAchievements Organizer

A desktop application built with Flutter to organize, browse, and interact with your RetroAchievements library. 

*Development started in April 2025, with a primary focus on Windows 10/11 environments for now.*

## ✨ Features

- **Modern UI**: A sleek, dark-themed interface built with Material 3 and a custom frameless window.
- **Library Organization**: Manage and view your retro games and achievements seamlessly.
- **Desktop First**: Optimized for Windows desktop experiences, complete with customized window borders and maximize/minimize behaviors.
- **Robust Architecture**: Built with Riverpod for state management and GoRouter for declarative routing.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (SDK >= 3.7.0)
- **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
- **Routing**: `go_router`
- **Window Management**: `window_manager`
- **Network & Storage**: `http`, `shared_preferences`, `path_provider`, `file_picker`

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Windows Desktop development tools (Visual Studio)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository_url>
   cd ra_launcher
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application on Windows:
   ```bash
   flutter run -d windows
   ```

## 📁 Project Structure

```text
lib/
├── api/          # RetroAchievements API integration
├── constants/    # App-wide constants and configurations
├── models/       # Data classes and entities
├── providers/    # Riverpod state providers
├── repositories/ # Data repository layer
├── router/       # GoRouter configuration
├── screens/      # Main application screens
├── services/     # Core services (storage, preferences, etc.)
├── widgets/      # Reusable UI components
└── main.dart     # Application entry point
```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page or submit a Pull Request if you'd like to help improve the project.
