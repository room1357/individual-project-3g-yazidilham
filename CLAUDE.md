# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter project called "pemrograman_mobile" - a mobile programming course project for Polinema (Politeknik Negeri Malang). The project is a starting Flutter application with a basic login screen interface.

## Common Commands

### Development
- `flutter run` - Run the app in development mode
- `flutter run -d chrome` - Run the app in web browser
- `flutter run -d ios` - Run on iOS simulator
- `flutter run -d android` - Run on Android emulator

### Code Quality
- `flutter analyze` - Run static analysis on Dart code
- `flutter test` - Run all unit and widget tests
- `flutter test test/widget_test.dart` - Run a specific test file

### Build
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter build web` - Build web version

### Dependencies
- `flutter pub get` - Get dependencies from pubspec.yaml
- `flutter pub upgrade` - Upgrade dependencies to latest versions
- `flutter pub deps` - Show dependency tree

### Clean
- `flutter clean` - Remove build artifacts and caches

## Architecture

### Project Structure
- `lib/main.dart` - Entry point containing MyApp and LoginScreen widgets
- `test/` - Contains widget and unit tests
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` - Platform-specific code
- `pubspec.yaml` - Dependencies and project configuration

### Key Components
- **MyApp**: Root widget with MaterialApp configuration using deep purple color scheme
- **LoginScreen**: Main login interface with username/password fields, login button, and register link

### Dependencies
- `flutter_lints ^5.0.0` - Linting rules for code quality
- `cupertino_icons ^1.0.8` - iOS-style icons
- Uses Material Design components

### Code Style
- Follows Flutter/Dart linting rules defined in `analysis_options.yaml`
- Uses `package:flutter_lints/flutter.yaml` for recommended lints
- Comment out lint rules in analysis_options.yaml if needed for project requirements