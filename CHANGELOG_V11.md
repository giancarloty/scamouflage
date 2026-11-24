# v11 changelog

## Gameplay
- **All seven arcade games rebuilt around different mechanics** (see README table). No more read, click, answer loop.
- **Truth-first generation** for every mode, with surface cues (tone, badges, account age, popular replies) independent of the verdict.
- **Post Autopsy**: five neutral inspection checks with a budget (5/4/3 by difficulty). Useless buttons removed. Hard mode adds misleading popular replies.
- **Impostor Hunt**: independent directory card, 12 ownership stories including hijacked real accounts, rebrands, parody, fan pages and paid badges. The old "verify" button is gone.
- **Scam Slam**: your own phone activity, link preview, and consequence bubbles after your reply. 18 scenarios, 8 of them legitimate, so "block everything" loses.
- **Rumor Radar**: reorder chain, spot-the-edit, stale deadline, independent proof, edited words.
- **Inbox Sprint**: whole-batch swiping, flip-card headers, timers on Medium and Hard, partial XP.
- **Comment Chaos**: multi-flag with zero, one or two violators; rude-but-allowed comments are the point.
- **Clip Check**: real timeline with viral cut vs full video and five checks.
- Case-specific hints that also glow the right tool.
- Streak bonus (up to +12 XP). Hearts, XP, unlock thresholds, Easy/Medium/Hard and Endless Mix unchanged.

## Tutorial and UX
- First Day now coaches with glowing targets and gated buttons, and uses fixed clear teaching cases. Skippable and replayable.
- Result card is a large scrollable bottom card with the key clue, what happens next, and the lesson.
- Colors: green Keep/Allow, red Remove/Flag, orange/pink/blue for other choices. Evidence buttons are neutral.
- Android back button asks before leaving a run.

## Content
- Over 100 scenarios and templates across the seven games, including: flood-control accountability (both a fair critique and a wrong-photo "ghost project"), recycled typhoon media, fake class suspensions, election screenshots, fake ayuda, recruitment and task scams, SIM and e-wallet scams, concert-ticket resale, AI deepfake endorsements, labeled AI parody, subtitle swaps, P-pop and drag fandom drama.
- 19 new Career Shift patterns on the same themes.

## Fixes
- Removed dead `_start` in `screens.dart`; tutorial replay from Settings now awaits the reset.
- Removed an unused generator helper and an unused variable.
- Fixed Impostor Hunt handle collisions, and handles built from city names containing spaces.
- Pubspec now requires Flutter 3.32+ (the code uses APIs from 3.27 to 3.31).
