# Scamouflage v1.3 — Menu music, MVC and replayability

## Audio and navigation
- Fixed tabs changing soundtrack: Home, Arcade hub, Shifts, Profile and Settings consistently use `menu.mp3`.
- A game track plays only when the user begins a Career Shift/tutorial or an Arcade game.
- Return from a finished/abandoned Arcade session switches back to the common menu track (not the old Arcade hub track).
- When a mode changes mid–Endless Mix, the new mode's soundtrack takes over.
- Repeated taps on menu tabs don't unnecessarily queue another music transition; playback still retries when it failed to start.

## Code organization
- Reorganized into `models`, `views`, `controllers`, `services`.
- Added `NavigationController` for menu/game/summary transitions.
- Merged mascot art with the mascot view and mobile layout helpers with theme, reducing source files from 29 to 28 even after adding navigation controller.
- Kept the 7 independent scenario generators. Combining them would create huge mixed-responsibility files.
- Updated all library and test imports and removed generated caches from the deliverable.

## Gameplay variety
- Replaced 16 blind attempts with family-aware selection and a fuller fallback search.
- Avoids recently played scenario *archetypes* (e.g. the same type of parcel scam), not only identical signatures.
- Hard Trust comments and like counts are randomized independently of the truth.
- Easy Comment Chaos can now legitimately contain no rule-breaking comments.
- Non-tutorial Inbox Sprint occasionally has all-spam or all-legitimate batches. Tutorial batches still show both.
- Hard Rumor Radar can vary forwarding labels without changing what is factually claimed.
- Checking decisive evidence in Trust or Clip now provides a visible +15 XP bonus.
- Removed a fixed past-dated scholarship deadline from an otherwise valid Trust example.

## Tests added or updated
- NavigationController transition tests.
- Menu-tab music assertions in the navigation widget test.
- Generator tests for previously predictable cases, family freshness, independently varying hard replies, inbox extreme cases and easy zero-violation threads.

## Not yet done
- Runtime tests must be executed with a local Flutter 3.32+ SDK; this editing environment does not have Flutter or Dart installed.
- The seven mini-games still use handcrafted template banks. Improved distribution reduces repetitiveness but is not a full procedural content-generation system.
- Some view code remains fairly large; a further step could separate self-contained UI sections once the tests run cleanly and the team agrees on an MVC convention.
