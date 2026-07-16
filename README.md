# RetroAchievements Library

A desktop application built with Flutter to organize, browse, and interact with your RetroAchievements library. 

*Development started in April 2025, with a primary focus on Windows 10/11 environments for now, but since it uses flutter it shoul be easily compiled on linux and MacOs*

<img width="480" height="250" alt="{A8A50461-F7B9-4A1F-A842-704F9AF072C9}" src="https://github.com/user-attachments/assets/35213278-c7d0-4165-80bf-9d9bf9d5a8f8" />

<img width="480" height="250" alt="{C1B5A2DC-DDD6-40BE-8A7A-C7A6D70C0131}" src="https://github.com/user-attachments/assets/2a3489d9-77a8-43a9-9ec9-f45981c0e5b8" />

<img width="480" height="250" alt="{AFAFAA23-60C6-4289-8682-567CDD61D429}" src="https://github.com/user-attachments/assets/96bc4be4-1492-4434-8649-54354aabfa7f" />

<img width="480" height="250" alt="{2359DF18-9E9F-4E15-9ED6-1FBD1977A8CC}" src="https://github.com/user-attachments/assets/136ac14e-ffff-47bd-8e68-b36912f872c1" />

<img width="480" height="250" alt="{AC9CDC21-BE09-43C6-902F-B31FB2F9A406}" src="https://github.com/user-attachments/assets/6305da2f-30aa-47ef-8a27-af049827eeb5" />

<img width="480" height="250" alt="{3F1FF01B-DCE0-484A-989E-70653E8CCB3C}" src="https://github.com/user-attachments/assets/db8833f4-77bf-40c6-9230-7cbf9b7c9690" />

<img width="480" height="250" alt="{C1D66248-0FE2-4C07-AA5C-466C4438856F}" src="https://github.com/user-attachments/assets/55f6f780-c46d-49db-aa00-3c848549f94c" />

<img width="480" height="250" alt="{818494D2-3C46-4D37-9187-6164D2DF8B4C}" src="https://github.com/user-attachments/assets/09fc6739-ed92-4123-902d-92fd23683150" />


## ✨ Features

- **Dashboard**: All main user stats on the dashboard.
- **Library Organization**: Manage and view your retro games and achievements seamlessly.
- **Hashing Tools**: You can hash individual files or your entire library against RA's database.
- **Modern UI**: A sleek, dark-themed interface built with Material 3 and a custom frameless window.
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
