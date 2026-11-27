# Scamouflage

Scamouflage is a Flutter game about digital literacy. Players act as content moderators on Tambayan, a fictional social platform, and investigate suspicious posts, messages, accounts and videos.

## Features

- Seven Arcade mini-games, Endless Mix and Career Shifts
- Three difficulty levels, randomized cases and educational feedback
- Daily challenges, XP, unlockable cosmetics and player profiles
- Firebase authentication, cloud saves and online leaderboards

See the [user manual](USER_MANUAL.md) for gameplay instructions and [architecture](ARCHITECTURE.md) for the code structure.

## Running the app

Requirements: Flutter 3.32 or later, Dart 3.8 or later, and Chrome or an Android device.

```sh
flutter pub get
flutter run -d chrome
```

To run on a connected Android device, use `flutter run`. Do not regenerate the existing platform folders.

## Testing

```sh
flutter analyze
flutter test
```

See [Testing](docs/TESTING.md) for the manual checks. Guest gameplay uses local storage; account features and ranked submissions require the configured online services. Firebase is configured in this project for Android and web.

## Project layout

| Folder | Purpose |
| --- | --- |
| `lib/` | Flutter application code |
| `assets/` | Game audio |
| `backend/` | Ranked-run API and score validation |
| `test/` | Automated Flutter tests |
| `android/`, `ios/`, `web/` | Platform-specific files |
| `docs/` | Testing notes |

Development updates are recorded in [CHANGELOG.md](CHANGELOG.md).
