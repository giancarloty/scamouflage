#!/usr/bin/env bash
set -euo pipefail
command -v flutter >/dev/null || { echo 'Install Flutter SDK and add it to PATH.'; exit 1; }
echo 'Generating Android, iOS and web projects from official Flutter templates...'
flutter create --platforms=android,ios,web --project-name scamouflage .
flutter pub get
flutter analyze
flutter test
echo 'Run web: flutter run -d chrome | Android: flutter run | iOS: flutter run -d ios (macOS/Xcode only)'
