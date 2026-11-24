# Scamouflage — Music & Investigator Identity Update

## Audio direction
- New original bright, upbeat menu and Arcade Hub themes. Music changes on entering a game.
- Seven distinct mellow investigation loops (plus Career Shift music). The Trust or Bust mode now uses its own calm `trust.mp3`, not the hub music.
- Softer flip, inspect, swipe, snap, and hint cues. Short mechanical keyboard/mouse-like click on existing button action cues. Correct and victory jingles retained from v11D.
- Added separate **Sound effect intensity** slider alongside the original master volume and on/off switches. Volume preference saved on device. No network required.
- Playback starts after user interaction on Safari. Audio never carries educational information essential to play.

## Progression and customization
- Career XP automatically raises a separate **Investigator Level** (not the shift number).
- Eight unlockable investigative/journalistic titles, six badges, and five colored profile frames, all earned permanently at XP thresholds. Unlocks cost **no XP** and do not affect the existing hints or Arcade unlocks.
- Titles automatically advance when earned until the player manually equips a prior earned title.
- The **My Investigator** screen is accessible from the main menu and Arcade Hub. Selection is persisted with SharedPreferences alongside existing progress.

## Future feature previews (intentionally disabled)
- Greyed username and email fields, `Create Account / Sign In` button, and global leaderboard section.
- These do not collect credentials, authenticate players, upload scores, or imply an active online service. A future production version would require an authentication provider, database, backend rules, privacy safeguards, and leaderboard anti-cheat systems.

## Installation
1. Back up your current Flutter project and keep generated native folders if upgrading from the source ZIP.
2. Copy the included `lib`, `assets`, `test`, and `pubspec.yaml` into the project.
3. Run `flutter pub get`, `flutter analyze`, and `flutter test` locally.
4. Test on a real phone: menu music → enter an investigation (volume should drop/change); tap/flip/swipe; earn XP; equip title/badge/frame; close and reopen; confirm account buttons remain disabled.

## Validation
Asset presence, MP3 decoding, file structure, and static checks were performed. A working Flutter SDK was not available in this build environment, so compilation and mobile playback must be verified on your development machine.
