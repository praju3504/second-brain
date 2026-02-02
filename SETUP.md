# Second Brain - Setup Guide

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (>= 3.2.0)
  - Download from: https://docs.flutter.dev/get-started/install
- **Dart SDK** (comes with Flutter)
- **Android Studio** or **Xcode** (for mobile development)
- **Git** (for version control)

## Step-by-Step Setup

### 1. Verify Flutter Installation

```bash
flutter --version
flutter doctor
```

The `flutter doctor` command will show if there are any issues with your Flutter setup.

### 2. Clone the Repository

```bash
git clone https://github.com/praju3504/second-brain.git
cd second-brain
```

### 3. Install Dependencies

```bash
flutter pub get
```

This will download all the required packages specified in `pubspec.yaml`.

### 4. Generate Database Code

The app uses Drift for database management, which requires code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or use watch mode for automatic regeneration during development:

```bash
flutter pub run build_runner watch
```

### 5. Run the Application

#### On Android Emulator/Device:
```bash
flutter run
```

#### On iOS Simulator (macOS only):
```bash
flutter run -d ios
```

#### On Specific Device:
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

## Troubleshooting

### Issue: "flutter: command not found"

**Solution:** Make sure Flutter is in your PATH. Add to your shell profile:

```bash
export PATH="$PATH:[PATH_TO_FLUTTER_DIRECTORY]/flutter/bin"
```

### Issue: Build runner fails

**Solution:** Clean and rebuild:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: "Target file ... doesn't exist"

**Solution:** This means the generated files are missing. Run build_runner again.

### Issue: Android licenses not accepted

**Solution:**

```bash
flutter doctor --android-licenses
```

## Development Workflow

### 1. Making Changes

When you modify database tables or use code generation annotations:

```bash
# Stop current app
# Run build_runner
flutter pub run build_runner build --delete-conflicting-outputs

# Restart app
flutter run
```

### 2. Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### 3. Formatting Code

```bash
# Format all Dart files
dart format lib/

# Analyze code for issues
flutter analyze
```

### 4. Building for Release

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle (recommended for Play Store):**
```bash
flutter build appbundle --release
```

**iOS (macOS only):**
```bash
flutter build ios --release
```

## Project Structure Overview

```
second-brain/
├── lib/
│   ├── main.dart               # App entry point
│   ├── app.dart                # App configuration
│   ├── core/                   # Core utilities (theme, constants)
│   ├── domain/                 # Business logic (entities, repositories)
│   ├── data/                   # Data layer (database, DAOs)
│   └── presentation/           # UI layer (screens, widgets, providers)
├── rust/                       # Rust core library (stubs)
├── test/                       # Test files
├── pubspec.yaml                # Dependencies
└── README.md                   # Documentation
```

## Key Technologies

- **Flutter**: UI framework
- **Riverpod**: State management
- **Drift**: SQLite ORM with type safety
- **Go Router**: Navigation
- **Material Design 3**: UI components

## Common Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Hot reload (in running app)
# Press 'r' in terminal

# Hot restart (in running app)
# Press 'R' in terminal

# Clean build artifacts
flutter clean

# Check for issues
flutter doctor
flutter analyze
```

## Next Steps

After setup:

1. Explore the app structure
2. Read the main README.md for feature details
3. Check individual screen files in `lib/presentation/screens/`
4. Review the database schema in `lib/data/database/tables/`
5. Start building new features!

## Support

For issues or questions:
- Check existing GitHub issues
- Create a new issue with detailed description
- Include output of `flutter doctor -v`

Happy coding! 🚀
