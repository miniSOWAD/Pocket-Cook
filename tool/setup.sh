#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v flutter >/dev/null 2>&1 || { echo 'Install Flutter and add flutter/bin to PATH first.' >&2; exit 1; }
echo 'Generating official Android, iOS, and web platform projects...'
flutter create --project-name recipe_app --org com.trendintools --platforms=android,ios,web --no-pub .
dart tool/configure_platforms.dart
flutter pub get
echo 'Setup complete. Try: flutter run -d chrome'
