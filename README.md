# Succulent

A modern, gamified habit tracker built with Flutter. The app currently includes
custom UI for a splash screen and a sample home dashboard, plus a lightweight
classification utility used in a debug screen.

## Features
- Splash screen with branded SVG assets
- Home dashboard with daily progress and sample habits
- Simple task and succulent domain models
- Debug classification screen (for quick category checks)

## Project Structure
The app follows a clean architecture-inspired layout:

```
lib/
  core/
    classification/
  debug/
  features/
    home/
      presentation/
    splash/
      presentation/
    succulents/
      domain/
    tasks/
      domain/
  main.dart
```

## Getting Started
1) Install dependencies:
```
flutter pub get
```

2) Run the app:
```
flutter run
```

## Assets
- `assets/splash-icon.svg`
- `assets/app-icon.svg`
- `assets/fonts/Brawler-Regular.ttf`

## Notes
- The debug classification screen is not wired into navigation by default.
- Sample data in the home screen is hard-coded for now.

## License
Private project (not published to pub.dev).
