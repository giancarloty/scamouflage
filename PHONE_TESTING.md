# Scamouflage v9 — Phone-first layout and iPhone Safari testing

This updates the existing v8 Flutter project. **Game logic, randomization, modes and saved career progress are preserved.**

## Responsive changes

- Designed primarily for portrait viewports from **320–430 logical pixels wide**, including iPhone SE, modern iPhones and most Android devices.
- Arcade's narrow header stacks title and scores so the hint button, hearts and XP do not collide.
- Classic and Arcade decision controls stay docked to the bottom while case content scrolls.
- Multi-answer controls cap their height and can scroll on short screens.
- Impostor Hunt profiles have internal scrolling so long names or bios cannot spill outside the panel.
- Pop-up dialogs have maximum height and scroll internally on short screens.
- Tutorial instructions stay visible above the case during the first five rounds.
- Swipe-to-sort email thresholds work on narrow touch screens; buttons remain an accessible backup.
- Web viewport settings enable iPhone Safari's device-width scaling and safe-area support.

## Install in the existing Windows project

1. Back up the existing project.
2. Replace `lib/` and `test/` with the folders from this ZIP. Update `pubspec.yaml` if yours is different.
3. For **mobile Safari web testing**, merge the `web/index.html` changes into your existing `web/index.html` (especially the viewport meta tag) if you already have customizations; do not overwrite custom app icons.
4. Keep your existing `android/` and `ios/` folders. No need to regenerate them.
5. In the project terminal run:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Connect the iPhone to the **same Wi-Fi** as your laptop, find your Windows IPv4 address with `ipconfig`, then open `http://YOUR-LAPTOP-IP:8080` in Safari.

## Physical-phone QA checklist

- On 320px, 360px, 375px, 390px and 430px wide screens: no black/yellow dialogs with clipped text; all text in results is readable.
- First-day tutorial: instruction, case and decision actions are visible and can be reached without horizontal scrolling.
- Impostor Hunt: both accounts can be inspected and neither bio clips.
- SMS challenge: every choice remains reachable even on short phones.
- Inbox Swipe: swipe both directions with touch; also try the Spam and Keep buttons.
- Rumor Radar and Clip Check: cases scroll vertically and bottom answer buttons remain visible.
- iPhone Safari: test with address bar shown/hidden; rotate to landscape and back; test Add to Home Screen if needed.
- Android: check system navigation bar/gesture area. Native iOS requires macOS + Xcode to build.

**Verification:** The source was checked for balanced delimiters and ZIP integrity in the authoring environment. Flutter is not available there; run `flutter analyze`, `flutter test`, and a real-device smoke test locally before release.
