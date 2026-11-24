# Scamouflage v1.3 — hands-on test checklist

1. Start the app and tap **HOME → ARCADE → SHIFTS → PROFILE → HOME**. Music should stay on exactly the **same menu track** without restarting or skipping.
2. Start **First Day** from Arcade. Music should change to the first game track; when progressing into a different mini-game it should change again.
3. Complete or leave First Day / an Arcade run. The menu soundtrack should resume and remain unchanged when switching menu tabs.
4. Start a **Career Shift**. Career music should play only after entering the case desk. Finish or exit and confirm the menu soundtrack resumes.
5. Use **Settings → Replay interactive tutorial**. Verify Career music starts for the tutorial, not the menu track.
6. Tap the music note on Home and toggle music off/on. It should not start a second copy of the same track. Test returning after backgrounding the app.
7. Play 10+ rounds of one game mode; the same scenario family should not repeat immediately when alternatives exist (personalized names alone do not count as different families).
8. Play **Trust or Bust** on Hard. Popular comments should not always be the reverse of the correct answer and likes should vary.
9. Play **Comment Chaos** on Easy repeatedly: sometimes the correct answer is ALLOW ALL, with no violations.
10. Play **Inbox Sprint** outside the tutorial: some full batches can all be spam or all be legitimate; both are valid outcomes.
11. Play **Rumor Radar** on Hard: forwarding captions on otherwise matching versions should not count as factual changes.
12. Check decisive evidence before correctly answering a Trust / Clip case: result overlay includes a +15 XP inspection bonus.
13. Verify old progress and unlockables survive upgrade (XP, outfits, ranks, previous first-day completion).
14. On Android, Chrome and a narrow phone screen, verify no overflow, broken back navigation or black screen.
15. Run `flutter analyze` and `flutter test`; compare any failures with the v1.3 change log.
