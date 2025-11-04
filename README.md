# 🍸 Cocktails App

A beautiful, feature-rich Flutter application for discovering, creating, and managing cocktail recipes. Browse through an extensive cocktail database, find recipes based on available ingredients, and save your favorites for quick access.

[![Flutter](https://img.shields.io/badge/Flutter-3.35.7-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart)](https://dart.dev)

## Information
**This README was partially made by AI, just to speed up the process :)**

## Features

### 🔍 Discovery & Browse
- **Real-time Search**: Find cocktails instantly with auto-suggest search functionality
- **Masonry Grid Layout**: Beautiful visual layout with cached network images for optimal performance
- **Favorites System**: Save your favorite cocktails for quick access with persistent local storage

### 🧪 Smart Mixer (Creator)
- **Ingredient-based Matching**: Select available ingredients and find cocktails you can make
- **Glass Type Filtering**: Choose your glass type to refine results
- **Intelligent Algorithm**: Advanced matching system that scores cocktails based on several factors
- **Best Match Recommendations**: Get the perfect cocktail suggestion from your available ingredients

### 📖 Detailed Information
- **Comprehensive Information**: View ingredients, measurements, alcohol percentages, glass types, and categories
- **Step-by-step Instructions**: Complete preparation instructions
- **Hero Animations**: Smooth, beautiful transitions between screens

### 🎨 User Experience
- **Dark/Light Theme**: Toggle between dark and light modes with persistent preference
- **Material Design 3**: Modern, clean interface following Google's latest design standards
- **Adaptive App Icon**: Dynamic, Material You themed app icon that adapts to your device's color scheme
- **Profile Statistics**: Track your app usage with favorites count, viewed cocktails, and creator uses
- **Offline-first Architecture**: Cached data ensures functionality even with limited connectivity (but its pretty limited)

## Tech Stack

### Core Framework
- **Flutter 3.35.7** - Cross-platform UI framework
- **Dart 3.9.2+** - Programming language

### State Management & Architecture
- **flutter_riverpod** (^3.0.3) - Robust state management with provider pattern
- **hooks_riverpod** (^3.0.3) - React-style hooks integration
- **flutter_hooks** (^0.21.3+1) - Lifecycle and state hooks
- **riverpod_annotation** (^3.0.3) - Code generation for providers

### Networking & API
- **dio** (^5.9.0) - Powerful HTTP client with interceptors
- API Base URL: `https://cocktails.solvro.pl/api/v1`

### Data Persistence
- **hive** (^2.2.3) - Fast, lightweight NoSQL database
- **hive_flutter** (^1.1.0) - Flutter integration for Hive

### UI/UX Libraries
- **skeletonizer** (^2.1.0+1) - Beautiful loading skeleton animations
- **cached_network_image** (^3.4.1) - Network image loading with caching
- **flutter_animate** (^4.5.2) - Declarative animation library
- **nil** (^1.1.1) - Null safety utilities

## Getting Started

### Prerequisites
- Flutter SDK (>=3.9.2)
- Dart SDK (>=3.9.2)
- Android Studio / Xcode (for mobile development)
- An IDE (VS Code, Android Studio, or IntelliJ IDEA)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/cocktails.git
   cd cocktails
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For development
   flutter run

   # For specific platform
   flutter run -d chrome        # Web
   flutter run -d android       # Android
   flutter run -d ios          # iOS
   flutter run -d macos        # macOS
   flutter run -d windows      # Windows
   flutter run -d linux        # Linux
   ```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

## Project Structure

```
lib/
├── main.dart                    # App entry point, theme, and initialization
├── Screens/                     # Main screen widgets
│   ├── Home.dart               # Discovery screen with infinite scroll
│   ├── Cocktail.dart           # Detailed cocktail view
│   ├── creator.dart            # Ingredient/glass selector
│   ├── mix.dart                # Matching algorithm logic
│   ├── mixed.dart              # Search results display
│   ├── Profile.dart            # User statistics
│   └── Settings.dart           # App settings and theme toggle
├── Widgets/                     # Reusable UI components
│   ├── ImageCard.dart          # Cocktail card component
│   ├── Home/
│   │   └── CreatorPrompt.dart  # Creator feature promotion
│   └── Mixed/
│       ├── Match.dart          # Match result component
│       └── NotFound.dart       # Empty state component
├── API/                         # Data layer
│   ├── api.dart                # REST client and data models
│   ├── cache.dart              # Repository with caching logic
│   └── ThemeProvider.dart      # Theme state management
└── Data/
    └── ingridients_list.dart   # Ingredient type icon mappings
```

## Architecture

The app follows a clean architecture pattern with clear separation of concerns:

- **Presentation Layer**: Flutter widgets and screens
- **State Management**: Riverpod providers for reactive state
- **Data Layer**: Repository pattern with caching strategy
- **API Layer**: REST client with Dio

## CI/CD

The project includes GitHub Actions workflow for continuous integration:

- **Automated Builds**: Android APK built on every push and PR
- **Artifact Upload**: APK available as downloadable artifact
- **Multi-trigger**: Supports push, PR, and manual dispatch

## Screenshots

| | | |
|:---:|:---:|:---:|
| ![](https://pub-56c207439a0f46c691997b6e4e97f986.r2.dev/Cocktails/Screenshot_20251102-225703786.jpg) | ![](https://pub-56c207439a0f46c691997b6e4e97f986.r2.dev/Cocktails/Screenshot_20251102-225627945.jpg) | ![](https://pub-56c207439a0f46c691997b6e4e97f986.r2.dev/Cocktails/Screenshot_20251102-225716264.jpg) |
