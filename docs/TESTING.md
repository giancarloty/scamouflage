# Testing

## Automated checks

```sh
flutter pub get
flutter analyze
flutter test
```

## Manual checks

- Switch between menu tabs; music should continue without restarting.
- Start and exit Career Shifts and Arcade runs; verify scoring, hearts, feedback and navigation.
- Play each Arcade mode at different difficulties. Check that scenarios vary and answers follow the available evidence.
- In Clip Check, judge whether the post's claim is supported, not just whether footage was edited.
- In timed Inbox Sprint, verify that an expired timer does not freeze the game.
- Complete and claim a daily challenge; check persistence and the daily reset.
- Sign in, change profile settings, restart the app and verify cloud progress and leaderboard submission.
- Test a narrow phone viewport for clipped text, overflow and unreachable buttons.

## Phone testing

For a phone and laptop on the same Wi-Fi network:

```sh
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

Open `http://<laptop-ip>:8080` in the phone browser. Native iOS builds require macOS and Xcode; online iOS features are not configured in the supplied Firebase options.

Record actual test results separately before submission.
