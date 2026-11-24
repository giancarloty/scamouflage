# Scamouflage v12 — Mascot Evolution & Four-Tab Navigation

## What's new

- Persistent bottom navigation on hub screens: **Home**, **Arcade**, **Shifts**, **Profile**. Same warm mustard, dark navy, round icon style as Scamouflage. Bottom tabs automatically hide in active minigames and Career Shifts to preserve usable portrait space.
- **Profile:** circular rank-progress ring, Career XP and title, horizontally scrollable gallery of all 10 mascot outfit variations, and local equip controls for mascot nickname, body color, title, badge and frame.
- **Mascot introduction:** meet **ChameLeo** once on first run. This independent `mascot_intro_v12` flag doesn't reset Career Shift or Arcade onboarding.
- **10 rank-themed mascot designs:** rookie star, link loops, detective shield, fact notebook, explorer compass, newsroom press pass, verification visor, sentinel shield, cyber circuits, legendary crown and cape. Built as original vector shapes; all colors customizable. No downloaded images.
- **Level 9 Cyber Guardian** at 7,400 XP; **Level 10 Truth Legend** at 10,000 XP. Levels 1–8 retain their original XP thresholds.
- **10 unlockable mascot nicknames** (default ChameLeo, later Sir Checks-a-Lot, Professor Receipts, Pixel Poirot, and more) and **10 unlockable body colors** (mint through legendary gold). No XP is spent; selections are saved through `SharedPreferences`.
- **Level-up celebration dialog** appears after completing a run or shift if XP crossed a level threshold. Leaving early after having earned a level also triggers it. The highest attained level is shown if a large XP award crosses several levels at once.
- Arcade minigames sorted by XP needed to unlock, preserving original three free modes and advanced unlocks. Social-post mode renamed **Trust or Bust**.
- No modifications to existing case generation, scoring, XP/hints rules, other minigame mechanics, audio assets, or offline saving.

## Run on Windows

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

For iPhone Safari on the same Wi-Fi:

```powershell
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Visit `http://YOUR_WINDOWS_WIFI_IPV4:8080` in Safari. Windows Firewall may need permission on the private network.

## Recommended phone QA

1. Test 320×568, 375×667, 390×844 and 430×932 logical-pixel portrait screens. Check that all four tabs remain readable above the home indicator.
2. Open each tab repeatedly; start an Arcade minigame and confirm tabs disappear during the run, then return after leaving.
3. Test the one-time ChameLeo introduction, then restart the app and verify it does not reappear.
4. Reach 150 XP in a minigame or Career Shift; check that the level-up pop-up appears after that run finishes and isn't shown twice.
5. In Profile, try equipping locked/unlocked mascot colors and names. Restart and confirm that earned selections persist; XP should not change.
6. Swipe the 10-outfit preview; check the rank-specific prop or clothing for each evolution.
7. Check Arcade sort: three 0-XP modes first, then Inbox Sprint 300, Comment Chaos 600, Rumor Radar 900 and Clip Check 1,200.
8. Verify that Trust or Bust, swiping, hints, Campaign Shifts, and audio continue working.

## Verification status

Source and archive inspection only in the provided environment: Flutter SDK and iPhone simulator were unavailable, so `flutter analyze`, `flutter test`, and real-device UI/gesture tests must be run locally. No compilation result is claimed.
