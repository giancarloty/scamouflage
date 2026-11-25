# Changelog — Smarter Difficulty Progression

**Branch:** `feature/smarter-difficulty`  
**Comparison:** `main...feature/smarter-difficulty`

## Added

- Added a shared `DifficultyProfile` model to centralize difficulty settings.
- Added profile properties for starting hearts, scan budget, Inbox Sprint timer, reasoning level, decoy clues, conflicting evidence, and cross-checking requirements.
- Added `test/difficulty_profile_test.dart` to check the difficulty profile configuration.

## Difficulty Configuration

| Setting | Easy | Medium | Hard |
|---|---:|---:|---:|
| Starting hearts | 5 | 4 | 3 |
| Scan budget | 5 | 4 | 2 |
| Inbox timer | Untimed | 10 seconds | Untimed |
| Reasoning level | 1 | 2 | 4 |
| Decoy clues | 0 | 1 | 3 |
| Conflicting evidence | 0 | 1 | 3 |
| Cross-checking requirement | No | No | Yes |

## Updated Arcade Modes

- **Trust or Bust:** Hard mode adds conflicting social-proof comments and decoy opinions. The evidence tool label changes to `SOURCE TRACE` when cross-checking is enabled.
- **Impostor Hunt:** Updated to use the shared difficulty profile for difficulty-sensitive generation.
- **Inbox Sprint:** Updated to use difficulty-based batch and timer configuration.
- **Rumor Radar:** Updated to use difficulty-sensitive puzzle/evidence settings.
- **Clip Check:** Updated to use the shared difficulty profile.

## Tests

- Added `test/difficulty_profile_test.dart`.
- Updated `test/arcade_v11_test.dart`.
- Run the following locally to verify:
  ```bash
  flutter pub get
  flutter analyze
  flutter test
  ```

## Notes Before Merging

- Confirm that the values in `lib/models/arcade_models.dart` match the expectations in `test/difficulty_profile_test.dart`. The branch inspection showed discrepancies between some profile values and test expectations.
- The branch also contains temporary patch files:
  - `Scamouflage_HarderHard_Incremental.patch`
  - `Scamouflage_SmarterDifficulty.patch`

  Remove these if they are not intended to be part of the repository.

This changelog describes the branch changes and does not claim that tests or Flutter analysis have passed.
