# Second Brain - Mobile Application

An all-in-one Second Brain mobile application that combines Notion-style note-taking, task management, and file organization in a single, powerful platform.

## Features

### 📝 Note Taking
- Create and edit notes with rich text support
- Search notes by title or content
- Organize notes hierarchically
- View recent notes on the dashboard
- Grid view for better visualization

### ✅ Task Management
- Create tasks with titles and descriptions
- Set task priority (Urgent, High, Medium, Low)
- Assign due dates and reminders
- Track task status (To Do, In Progress, Done, Cancelled)
- Filter tasks by status and priority
- View upcoming tasks in the dashboard
- Swipe to delete tasks

### 📁 File Manager
- Import files from device storage
- Support for various file types (images, videos, PDFs, documents, etc.)
- Grid and list view modes
- File size tracking
- MIME type detection

### 🎨 User Interface
- Material Design 3 (Material You)
- Light and dark theme support
- System theme detection
- Bottom navigation for easy access
- Floating action buttons for quick creation
- Responsive layouts

## Tech Stack

### Frontend (Flutter)
- **Flutter**: Cross-platform mobile framework
- **Riverpod**: State management
- **Go Router**: Navigation and routing
- **Drift**: SQLite database ORM
- **Material Design 3**: UI components

### Backend (Rust) - Stubs
- **Rust**: High-performance core functionality
- Graph index for entity relationships
- Encryption utilities (planned)

### Database
- **SQLite**: Local-first data storage
- **Drift**: Type-safe database queries
- Entities table for polymorphic storage
- Specialized tables for notes, tasks, and files

## Project Structure

```
second-brain/
├── lib/
│   ├── app.dart                    # Main app widget
│   ├── main.dart                   # Entry point
│   ├── core/                       # Core utilities
│   │   ├── constants/              # App constants
│   │   ├── theme/                  # Theme configuration
│   │   ├── utils/                  # Utility functions
│   │   └── extensions/             # Dart extensions
│   ├── domain/                     # Business logic layer
│   │   ├── entities/               # Domain entities
│   │   ├── enums/                  # Enumerations
│   │   └── repositories/           # Repository interfaces
│   ├── data/                       # Data layer
│   │   ├── database/               # Drift database
│   │   │   ├── tables/             # Table definitions
│   │   │   └── daos/               # Data Access Objects
│   │   └── repositories/           # Repository implementations
│   └── presentation/               # UI layer
│       ├── providers/              # Riverpod providers
│       ├── router/                 # Go Router configuration
│       ├── screens/                # Screen widgets
│       │   ├── home/               # Dashboard
│       │   ├── notes/              # Note management
│       │   ├── tasks/              # Task management
│       │   ├── files/              # File management
│       │   └── settings/           # Settings
│       └── widgets/                # Shared widgets
├── rust/                           # Rust core library
│   ├── src/
│   │   ├── graph/                  # Graph index
│   │   └── crypto/                 # Encryption
│   └── Cargo.toml
├── pubspec.yaml                    # Flutter dependencies
└── README.md
```

## Setup Instructions

### Prerequisites
- Flutter SDK (>= 3.2.0)
- Dart SDK (>= 3.2.0)
- Android Studio or Xcode (for mobile development)
- Rust (optional, for core library development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/praju3504/second-brain.git
   cd second-brain
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Drift database code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Development

### Code Generation

The project uses code generation for:
- Drift database (DAOs and tables)
- Riverpod providers (if using annotations)

Run code generation:
```bash
# Watch mode (automatically regenerate on changes)
flutter pub run build_runner watch

# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs
```

### Database Schema

The app uses a polymorphic entity system:
- **Entities table**: Stores common fields for all entity types
- **Specialized tables**: Store type-specific data (notes, tasks, files)
- **Links table**: Manages relationships between entities
- **Tags table**: Supports tagging system

### Adding New Features

1. Define domain entity in `lib/domain/entities/`
2. Create Drift table in `lib/data/database/tables/`
3. Implement DAO in `lib/data/database/daos/`
4. Create repository in `lib/data/repositories/`
5. Add provider in `lib/presentation/providers/`
6. Build UI in `lib/presentation/screens/`

## Roadmap

### Phase 1 - MVP (Current)
- ✅ Note-taking functionality
- ✅ Task management
- ✅ File organization
- ✅ Basic UI and navigation
- ✅ Local SQLite storage

### Phase 2 - Enhanced Features
- [ ] Rich text editor with formatting
- [ ] Markdown support
- [ ] Task recurrence
- [ ] File preview and viewer
- [ ] Tags and labels
- [ ] Advanced search

### Phase 3 - Collaboration
- [ ] Cloud sync
- [ ] Multi-device support
- [ ] Sharing and collaboration
- [ ] Version history
- [ ] Conflict resolution

### Phase 4 - Intelligence
- [ ] Graph view visualization
- [ ] Backlinks and bidirectional links
- [ ] Smart recommendations
- [ ] OCR for images
- [ ] Full-text search with ranking

### Phase 5 - Security
- [ ] End-to-end encryption
- [ ] Biometric authentication
- [ ] Secure file storage
- [ ] Export/import encrypted backups

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter and Dart teams for the amazing framework
- Drift for the excellent SQLite ORM
- Riverpod for state management
- The open-source community

## Contact

Project Link: [https://github.com/praju3504/second-brain](https://github.com/praju3504/second-brain)

---

Built with ❤️ using Flutter
