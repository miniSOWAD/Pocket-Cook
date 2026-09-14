#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v flutter >/dev/null 2>&1 || { echo 'Install Flutter and add flutter/bin to PATH first.' >&2; exit 1; }
if [[ ! -d android || ! -d ios || ! -d web ]]; then
  echo 'Generating missing platform projects using the existing Firebase technical app identifier...'
  flutter create --project-name recipe_app --org com.trendintools --platforms=android,ios,web --no-pub .
else
  echo 'Platform projects already exist; keeping their Firebase application identifiers unchanged.'
fi
dart tool/configure_platforms.dart
flutter pub get
echo 'Setup complete. Try: flutter run -d chrome'
