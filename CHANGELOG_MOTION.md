# Inbox Sprint — Mobile Motion Polish

This is a focused upgrade to the uploaded v11B Flutter project. The generator, game modes, XP, shifts, and progress data are unchanged.

## Changes
- Tapping an email now performs a 430 ms perspective Y-axis turn (front → sender/link details, and back again), rather than swapping the text instantly.
- Both faces contribute to card layout so the card remains the same height during a flip, even when long sender and URL details wrap on narrow phones.
- Horizontal drags follow your finger. The card tilts subtly in the drag direction.
- The **whole card** gradually tints soft **red when dragged left (SPAM)** or **green when dragged right (KEEP)**; its border also gets a subtle matching tint. The old floating stamps were removed.
- Short/incomplete swipes animate smoothly back to center. Sufficient-distance swipes and intentional fast flicks fly fully off the viewport, then the next email appears.
- The fixed SPAM/KEEP button pair remains for accessibility and uses the same exit animations.
- An expiring Inbox Sprint timer now animates a card upward instead of leaving it momentarily static before advancing.
- A pure swipe decision/tint helper and widget tests were added to `lib/inbox_motion.dart` and `test/inbox_motion_test.dart`.

## Run locally
```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Open your computer's Wi-Fi IP with `:8080` in iPhone Safari, while both devices share the same network. Test tap-to-flip, dragging slowly in either direction, cancelling a swipe, fast flicks, and the fixed decision buttons.

Note: Flutter SDK was unavailable in the creation environment, so compilation and physical iPhone touch performance must be verified on your machine.
