# Scamouflage v11D — Original Audio Edition

Based directly on **v11C Smooth Flip & Swipe**. Gameplay, scenarios, progression, heart and XP systems, UI theme, and flip/swipe animations were preserved. This update adds sound; it does not replace the game architecture.

## Original, bundled audio

- **9 musical loops**: menu, career, arcade, Inbox Sprint, Impostor Hunt, Scam Slam, Rumor Radar, Comment Chaos, Clip Check. Post Autopsy shares the arcade loop.
- **12 effects**: tap, inspect, hint, flip, swipe, snap-back, correct, wrong, unlock, victory, defeat, choice.
- Entire audio collection is approximately **0.8 MB** of compressed MP3. All files were newly synthesized specifically for Scamouflage; no copyrighted game/film soundtracks or online audio required.
- Audio files are in `assets/audio/music` and `assets/audio/sfx`.

## Interaction map

| Interaction | Audio |
| --- | --- |
| Main menu (tap note icon or Settings) | Menu loop |
| Career Shifts | Career background loop |
| Arcade Hub | Arcade background loop |
| Each Arcade mode / Endless Mix changes mode | Matching mode loop |
| Tap source, account, profile or clue | Inspect chime |
| Flip an email | Short soft flip sound |
| Swipe/press Spam or Keep | Swipe sound |
| Incomplete swipe snaps back | Snap-back sound |
| Pick an answer, source, comment, or timeline beat | Choice click |
| Reveal a hint | Hint motif |
| Correct/wrong submission | Positive chime or gentle error tone |
| Complete a Career Shift, intro, or unlock a minigame | Victory or unlock motif |

## Settings and accessibility

- Music on/off, sound effects on/off, and master volume slider with numeric percentage.
- Settings persist locally across restarts using `shared_preferences`.
- Audio does **not** convey any information that isn't already shown visually.
- No real content/passwords or external audio streaming is used.
- The first visit to the Home screen does not autoplay audio; **tap the music-note icon, Settings, Career, or Arcade** to begin. Mobile Safari blocks unguided autoplay.
- Audio pauses when the app is backgrounded and resumes if allowed.
- Music does not restart when a clue, flip, or short effect plays.
- Spoken narration/character voice acting is not included. The new mascot-like cues are synthesized effects, not speech.

## Installation

From project folder:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

For testing on your iPhone over the same Wi-Fi:

```powershell
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Open `http://YOUR-LAPTOP-IP:8080` in Safari and **tap a visible game control once to enable audio**. Check the phone's mute switch, media volume, and app audio controls if you hear nothing. There is no microphone permission or internet audio API.

### Suggested phone playtest

1. Open Home and tap the music-note button; verify the menu music starts.
2. In Settings, turn music off while leaving effects on; confirm effects still play.
3. Drag Inbox Sprint partially and release; hear a snap but no completed swipe.
4. Tap email to flip; hear a soft whoosh; fully swipe in both directions.
5. Enter Rumor Radar, then Impostor Hunt; music should change only on mode transitions.
6. Background Safari, return, and interact if autoplay is blocked.
7. Force-close/reopen the game; confirm music/SFX/volume settings remain saved.
8. Test on 320–430 logical-pixel phone widths in portrait.

**Build verification:** Dart/Flutter SDK is not available in the artifact-authoring environment. Audio assets have been generated and probed as MP3, source syntax was checked structurally, and the project should be compiled and playtested locally before grading or publishing.
