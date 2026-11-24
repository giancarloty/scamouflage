# Scamouflage v8 — Gameplay Finalization

This update **extends v7 on the existing v5 foundation**; it is not a new two-file app. The native platform folders you already generated in Windows can be preserved.

## Fixed from playtesting

- **Clear verdict language:** Keep/Allow is green; Remove/Block/Spam is red, including classic-mode stamps and new arcade controls. Non-binary SMS actions remain neutral so the answer isn't leaked by color.
- **No extra MARK button:** Classic-mode evidence collects when you tap a detail; no second marking step. The optional old tag mechanic is no longer shown.
- **No arbitrary source-check limit:** Classic mode now allows one free source verification per case. Its counter and lookup labels were removed from the visible case controls. Arcade inspections remain free.
- **Hints earned with XP:** A player starts with one free hint and earns a new one every **50 permanent Career XP**. Spent hints are stored locally. Hints point toward a reasoning strategy instead of simply revealing the answer. The icon and available hint number are in each challenge header.
- **More specific case explanations:** Impostor Hunt feedback names the actual impersonating side (or neither) and explains which directory/contact evidence settles the result. Rumor Radar feedback cites the relevant item.
- **Rumor Radar now has FIVE challenge formats:** trace the original, spot an altered screenshot, identify an outdated item, locate independent corroboration, and compare a quote with its context. These use different reference panels and tasks, and the correct item position is shuffled.
- **More varied Comment Chaos:** Neutral and critical comments vary; comment order is shuffled and the harmful statement's position is recalculated correctly.
- **Persistent first-day tutorial, seven existing modes, Easy/Medium/Hard hearts, permanent career XP, unlock thresholds, and Endless Mix** continue as before.
- **Readable feedback:** Fixed high-contrast results and hints; no deliberately empty or color-matched toast. Existing Result/Next area remains anchored above the action bar.

## Project remains modular

```
lib/
  main.dart              App bootstrap
  engine.dart            Classic game + shared career XP / hints
  models.dart            Classic game entities
  generator.dart         Classic case generator
  screens.dart           Original classic menus/desk
  art.dart               Chameleon painter
  case_media.dart        Offline illustrated case-media
  theme.dart             Shared visual system / stamps
  arcade_models.dart     Seven-mode models + rumor variants
  arcade_generator.dart  Offline procedural cases
  arcade_session.dart    Run state and hearts
  arcade_screens.dart    Arcade hub + minigame screens
```

## Build and test

You need your installed Flutter SDK. No Flutter SDK was available in the file-authoring environment, so this release **has not been compiled locally**. A lexical source-balance check and ZIP integrity check were completed, and new test cases were added.

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

To use the web build on an iPhone and Windows laptop connected to the same private Wi-Fi:

```powershell
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Open `http://<YOUR-LAPTOP-IPv4>:8080` in iPhone Safari. A native iOS build requires a Mac with Xcode.

## Boundaries

All media, identities, organizations, and .example domains are fictional. The media minigame uses still illustrations and comparison, **not** a video-file player or real AI detector. Procedural generation uses authored, fact-consistent scenario families, not unlimited text generation; long sessions will inevitably reuse themes. It is not connected to real social media or messaging accounts.
