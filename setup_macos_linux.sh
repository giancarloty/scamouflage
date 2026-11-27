#!/usr/bin/env bash
set -euo pipefail
command -v flutter >/dev/null || { echo 'Install Flutter and add it to PATH.'; exit 1; }
flutter pub get
echo 'Setup complete. Run flutter run -d chrome to start the app.'
