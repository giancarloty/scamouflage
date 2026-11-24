# Scamouflage v1.3 — MVC-aligned Flutter architecture

There are **28 application Dart files** under `lib/` (versus 29 in v1.2). This refactor retains individual mini-game generators and views where they have different mechanics. The goal is to make responsibility clear, not to combine everything into huge files.

```text
lib/
  main.dart                         app setup; only entrypoint
  models/
    models.dart                     Career Shift case / result data
    arcade_models.dart              ArcadeCase, modes, answers, findings
    player_progression.dart         rank, badge, unlock definitions
  controllers/
    engine.dart                     Career game state, rules, persistence
    arcade_session.dart             run lifecycle, XP, hearts, streak, next case
    navigation_controller.dart      tab transitions, gameplay / summary routes
    inbox_motion.dart               pure swipe-decision and visual-feedback rules
  views/
    screens.dart                    Home, Career, Profile routing and Career UI
    arcade_screens.dart             Arcade hub, gameplay shell, result / exit
    arcade_modes_a.dart             Trust, Impostor, Scam Slam, Clip UI
    arcade_modes_b.dart             Rumor, Inbox, Comment UI
    arcade_widgets.dart             shared arcade presentation widgets
    career_identity.dart            investigator customization UI
    case_media.dart                 offline editorial artwork widgets
    mascot.dart                     mascot widget and its illustrations
    theme.dart                      colors, typography, responsive UI helpers
  services/
    generator.dart                  classic Career scenario generator
    arcade_generator.dart           randomization dispatcher, recent-family filter
    arcade_common.dart              seeded RNG helpers, fictional data pools
    arcade_gen_trust.dart           Trust or Bust scenarios
    arcade_gen_impostor.dart        Impostor Hunt scenarios
    arcade_gen_chat.dart            Scam Slam scenarios
    arcade_gen_rumor.dart           Rumor Radar scenarios
    arcade_gen_inbox.dart           Inbox Sprint batches
    arcade_gen_thread.dart          Comment Chaos threads
    arcade_gen_clip.dart            Clip Check scenarios
    game_audio.dart                 audio playback and saved preferences
```

## MVC responsibility boundaries

- **Model:** `ArcadeCase`, `EmailItem`, `CommentView`, `PlayCase`, career ranks, and other data types describe the game and do not own a screen.
- **Controller:** `ArcadeSession` manages hearts, answer validation, progress, and the next case. `GameEngine` handles Career Shift state and local storage. `NavigationController` validates menu transitions and represents which screen is active. These classes do not build the arcade UI.
- **View:** `GameScreens`, `ArcadeHub`, and the seven mini-game views render the interface and forward player actions to the controller. Flutter-specific view state (animations, currently open sheet, drag offset) stays inside these widgets.
- **Service:** Generators prepare internally coherent fictional cases; `GameAudio` handles music and SFX, not scoring or UI layout.

This is **MVC-aligned**, not a fully decoupled enterprise implementation: the existing game widgets still coordinate some navigation, sound cues and view-local interactions. This was deliberate to preserve the prototype and keep the refactor understandable.

## Music lifecycle

- HOME / ARCADE HUB / SHIFTS HUB / PROFILE / SETTINGS use `MusicScene.menu` (switching tabs **does not change the track or restart it**).
- Entering an actual Career shift or training starts `MusicScene.career`.
- Entering an actual Arcade run starts the first mini-game's track; Endless Mix changes the track when the *next mini-game* is dealt.
- Ending / exiting an Arcade run or Career shift returns to menu music.
- `GameAudio.enter` checks whether a track change or a retry is actually needed before queuing music playback. It still retries after browser autoplay rejection on a later user gesture.

## Anti-repeat and scenario variation

- `ArcadeGenerator.familyOfSignature` identifies a scenario's underlying family rather than its randomized names, amounts or IDs.
- `ArcadeSession` consults recently used family signatures from both persisted and current-run history, and prefers not to deal one again while alternatives exist.
- For fixed-template modes, the generator tries alternate indices rather than repeatedly rolling the same index. For Inbox Sprint it retries distinct batch signatures.
- Hard Trust replies no longer always contradict the truth or use answer-correlated fixed like counts.
- Comment Chaos can contain zero violations even on Easy. Inbox Sprint can produce all-spam or all-legitimate batches after the tutorial; First Day remains mixed for instruction.
- Hard Rumor "changed version" tasks may include harmless forwarding labels to encourage fact-level comparison instead of exact string matching.
- Trust/Clip rewards checking decisive evidence with 15 bonus XP (previously 5).

## Testing and limitations

Automated test files are under `test/`; added navigation-controller tests and updated generator diversity + menu-audio regression assertions. Run `flutter pub get`, `flutter analyze`, and `flutter test` locally. Device audio also needs hands-on playtesting (especially mobile Safari and Windows).

**This refactor did not add a backend, adaptive learner profiles, an infinite procedural scenario bank or new game modes.** Templates still exist and may recur after sufficient play; new scenario families would be the next content-expansion step.
