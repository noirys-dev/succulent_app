# Succulent

A calm, gamified habit tracker built with Flutter, focused on deep work, mindful routines, and growth through consistency. Succulent blends a minimal task system with focus sessions, progress tracking, and a zen visual language.

## Features
- Branded splash screen and calm, minimal UI
- Home dashboard with daily progress and animated habit list
- Habit entry with duration picker (hours/minutes wheel)
- Automatic task categorization (e.g., Productivity, Physical Activity)
- Deep Focus mode with countdown timer
- Optional lofi / ambient audio during focus sessions
- Session completion feedback with subtle sound cues
- Gamified progress tied to habit completion

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
    focus/
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
- `assets/audio/` (lofi tracks and focus sound effects)

## Notes
- Focus mode is currently available for productivity habits only.
- All data is stored locally for now (no backend).
- UI and interactions are optimized primarily for iOS.

## License
Private project (not published to pub.dev).
