# SCAMOUFLAGE: Trust or Bust (v13 MVC / Replayability Update)

A Flutter game for Filipino teens and young adults. You are a content moderator on a fictional platform called **Tambayan**. Every case is a small puzzle about scams, fake news, impersonation, edited media and online harassment. It teaches by letting you investigate, not by quizzing you.

All people, brands, agencies and websites in the game are **fictional** (`.example` addresses only). No real links are ever opened.

## How it plays

1. Use the four-tab bottom navigation (**Home**, **Arcade**, **Shifts**, **Profile**) to explore. Tap the Arcade tab or big cover to open the **Arcade**. First time only: **First Day**, five quick tries where a glowing hint shows what to tap. It can be skipped, and replayed from the Arcade hub.
2. Free from the start: **Trust or Bust**, **Impostor Hunt**, **Scam Slam**, and **Endless Mix**.
3. Cumulative **Career XP** (saved, never spent) unlocks: **Inbox Sprint** (300), **Comment Chaos** (600), **Rumor Radar** (900), **Clip Check** (1,200).
4. **Easy** 5 hearts, **Medium** 4, **Hard** 3. Difficulty also changes how many checks you may open, whether replies are noisy, and how fast Inbox Sprint runs.
5. **Career Shifts** (classic mode) still go 1 → 2 → 3 → … in order. Finishing a shift always unlocks the next one. Endless Career unlocks after Shift 6.
6. **Hints** work as before (1 to start, +1 per 50 XP). Hints are now specific to the case and glow the right tool.

## Seven different games

| Game | What you actually do |
| --- | --- |
| **Trust or Bust** | Open up to 3 to 5 neutral checks (media trace, account, date, original source, replies) on a viral post, then **Keep** or **Remove**. Your check budget forces you to choose. |
| **Impostor Hunt** | Read an independent **directory**, open two profiles, flag **A**, flag **B**, or say **Both OK**. Stories include look-alike handles, hijacked real accounts, rebrands, labeled parodies, fan pages and paid badges. |
| **Scam Slam** | Check **your own phone activity**, preview the link, then reply in a chat. The right reply changes with the facts (real messages are answered normally). You see what happens next. |
| **Rumor Radar** | Five puzzles: rebuild a repost chain (▲▼), tap the one version that was changed, find the stale post by deadline, find the independent proof, tap the words that were edited. |
| **Inbox Sprint** | Swipe a whole batch of emails (left = spam, right = keep). Tap a card to flip it for the real sender, reply-to and link target. Medium and Hard are timed. |
| **Comment Chaos** | Flag any number of comments (or none) in a heated thread. Harsh criticism is allowed; threats, doxxing, scams and group hate are not. |
| **Clip Check** | Scrub a timeline comparing the viral cut with the full video, then open upload info, audio, creator, label and full-video checks. |

Colors: **green** = Keep / Allow / Both OK, **red** = Remove / Flag / Spam. **Orange, pink and blue** are used for every other choice. Evidence buttons look the same whatever they reveal, so color never gives the answer away.

## Randomization

Each case is built **truth first**: the generator decides what is really happening, then writes the clues. Account age, follower counts, badges, hype or calm wording, and popular replies are rolled independently of the verdict, so they never predict it. Honest posts can shout, false posts can sound calm, real messages can be urgent, and scams can know your name.

Content covers school life, barangay and city hall, flood-control accountability, class suspensions and typhoon posts, election screenshots, fake ayuda and job offers, task scams, SIM and e-wallet scams, concert-ticket resale, P-pop and drag fandom drama, sports, AI art and deepfaked endorsements, and Taglish comments.

## Setup (Android, iOS, Web)

This ZIP contains the Flutter source (`lib/`, `test/`, `web/`, `pubspec.yaml`). The archive includes Flutter source, tests, assets, and the existing Android, iOS and Web shells. On a new computer, run the setup script to refresh Flutter dependencies and platform templates:

```bash
# macOS / Linux
./setup_macos_linux.sh
# Windows PowerShell
.\setup_windows.ps1
```

or by hand:

```bash
flutter create --platforms=android,ios,web --project-name scamouflage .
flutter pub get
flutter analyze
flutter test
flutter run -d chrome        # web
flutter run                  # Android device or emulator
flutter run -d ios           # macOS with Xcode only
```

Requires Flutter 3.32 or newer. If you already have a generated `android/` or `ios/` folder from an earlier version, keep it and copy over `lib/`, `test/`, `pubspec.yaml` and `analysis_options.yaml`.

See `CHANGELOG_V13_MVC_AND_RANDOMIZATION.md` for the new fixes and `ARCHITECTURE.md` for the MVC-oriented file layout.

## Audio (Original Audio Edition)

Scamouflage includes 10 original, offline background-music loops and 12 short sound effects. The first user interaction (entering a Career Shift or Arcade, tapping the music-note icon or Settings) enables audio on platforms such as iPhone Safari that restrict autoplay. Use **Settings** for independent Music/Sound Effects switches and a persistent master volume slider; Arcade also has an audio-settings button while playing. All sound is optional and all clues remain readable without audio. For filenames, phone tests and implementation notes, see `CHANGELOG_AUDIO.md`.

## Investigator levels, unlockables, and the new audio direction

The main menu now has a **My Investigator** card (also accessible from the Arcade Hub's medal icon). Career XP earned from either Career Shifts or Arcade increases a separate cosmetic level. Ten investigator titles, ten mascot nicknames, ten mascot colors, six badges and five profile frames are earned at fixed thresholds. The current title upgrades automatically when a level is gained, unless you've manually equipped an earlier unlocked title. No XP is spent. Cosmetics and selections are saved locally and do not affect the current hint and game-mode unlock rules.

**Music:** Home, Arcade hub, shift picker and Profile now share **one uninterrupted menu track**, including while changing tabs. Only entering an active mini-game or Career Shift switches to gameplay music. Returning to any hub resumes the common menu track. Game audio works offline, with a quiet click for buttons and subtle flips/swipes. The existing correct/victory cues are kept relatively prominent. Settings include Music, SFX, Master Volume, and SFX Intensity controls.

**Coming Soon:** an intentionally disabled preview for usernames, email sign-in, cloud saves and global leaderboards appears below the customization controls. No login or backend exists yet; don't enter credentials. Production authentication, privacy protections, and score verification would require a backend and persistent database.

For full changes and phone testing, see `CHANGELOG_CAREER_AUDIO.md`.

## New in v12 — bottom navigation, mascot evolutions and level celebrations

- **Home / Arcade / Shifts / Profile** remain visible at the bottom on phone-sized hub screens; the tabs hide when a challenge is active. Career Shifts and Arcade remain separate.
- **Profile** includes a circular XP progress ring, current title, 10 mascot outfit evolutions, equippable nicknames, and equippable body colors. They are all locally saved, permanent cosmetic unlocks; XP is never spent.
- **Meet ChameLeo** appears once when launching the updated game without previous mascot-onboarding data. Existing career and tutorial data are preserved.
- **Level-up pop-ups** appear after a game or run ends when Career XP crossed an investigator rank.
- **Arcade** cards appear in required-XP order and **Trust or Bust** is the title of the social-post game.
- New levels: Level 9 **Cyber Guardian** at 7,400 XP and Level 10 **Truth Legend** at 10,000 XP. The original eight level thresholds are unchanged.

The game continues working entirely offline with no real sign-in or leaderboards. See `CHANGELOG_V12_MASCOT_AND_NAV.md` for phone-playtesting notes.

## New in v13 — MVC structure and less predictable rounds

- Source files are grouped under `lib/models/`, `lib/views/`, `lib/controllers/`, and `lib/services/`. The app entrypoint remains `lib/main.dart`. The total `lib/` count is 28 Dart files instead of 29. Large independent mini-game generators remain separate for maintainability.
- Fixed unintended music changes across Home / Arcade / Shifts / Profile tabs.
- Prefer unseen scenario **families**, not merely new randomized surface details. Recent history carries into new runs.
- Removed the answer-correlated hard Trust comments / likes; allowed no-rule-breaking Easy comment threads and non-tutorial inbox batches that can be all legitimate or all spam.
- Hard Rumor versions can have different forwarding wrappers while retaining identical facts. Trust and Clip reward decisive evidence checks with 15 bonus XP.
- New / updated regression tests are included, but **not executed in this environment** (no Flutter SDK). On your computer run `flutter pub get`, `flutter analyze` and `flutter test` before submission.

See `CHANGELOG_V13_MVC_AND_RANDOMIZATION.md` and `WHAT_TO_TEST.md`.
