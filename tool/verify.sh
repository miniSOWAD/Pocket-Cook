#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
dart format lib test integration_test tool
flutter analyze
flutter test
flutter build web --release
if command -v node >/dev/null 2>&1; then
  node firebase/scripts/validate_seed.mjs
  node --test firebase/tests/seed_validation.test.mjs
fi
