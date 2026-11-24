# Scamouflage v10 — Clearer Campaign & Less Predictable Cases

This is an update to the **v9 phone-first Flutter project**, not a rebuilt application.

## Changes

- **Classic source verification is neutral blue**, both in the information pop-up and in the evidence strip. Reading a source never automatically awards bonus XP or visually reveals a red/green verdict. The source provides facts for the player to evaluate.
- **Career navigation is now distinct from Arcade.** The home screen has two separate destinations: Arcade Minigames and Career Shifts. The Career page lists Shift 1 to Shift 6 in numerical order and highlights the next shift. Prior shifts can be replayed.
- **After finishing Shift N, the Continue button starts Shift N+1** for N=1–5. Shift 6 ends at Career overview. Career grades remain feedback and do not block sequential progression.
- **The first Classic training leads to Career Shift 1** instead of unexpectedly opening Arcade. Arcade's own five-game First Day is independent.
- **Impostor Hunt generates a wider range of stories:** account takeovers, established impostors vs newly announced official pages, honest fan accounts, two acknowledged official branches, renamed accounts and copied identities. The deceptive account can be on either side or neither can be deceptive; account age, followers and polished bios are no longer automatic answers.
- **Scam Slam's three response buttons use orange, pink and blue**, with randomized answer positions. Red and green remain reserved for Keep/Allow and Remove/Block decisions.

## Integration

Copy `lib/` and `test/` into a backup of your existing v9 project. Keep your generated `android/`, `ios/`, and `web/` folders unchanged. For a completely fresh project, the archive contains a `pubspec.yaml` and source; run `flutter create --platforms=android,ios,web --project-name scamouflage .` first.

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

For testing on an iPhone via local Wi-Fi:

```powershell
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Use the Windows laptop's LAN IP and port 8080 from Safari on the same Wi-Fi.

## Verification

Automated Flutter compilation and device testing have not been performed in the authoring container, which does not contain the Flutter SDK. The Dart files underwent static structural checks; a new `test/v10_gameplay_regression_test.dart` tests shift ordering, neutral source scoring, and impostor diversity when Flutter is run locally.

## Decision-color legend

- **Green:** Keep/Allow or correct-result feedback.
- **Red:** Remove/Block/Spam or incorrect-result feedback.
- **Blue:** neutral source/inspect information. A source button never tells you the verdict through its color.
- **Orange, pink and blue:** choices in three-answer SMS scenarios. These colors identify positions only; the correct answer is shuffled and not color-coded.

## Distinct navigation

- **Career Shifts**: story progression Shift 1 → 2 → 3 → 4 → 5 → 6. Each completed shift unlocks the next regardless of grade.
- **Arcade Minigames**: standalone modes and randomized Endless Mix; this is not the sequential career campaign.
