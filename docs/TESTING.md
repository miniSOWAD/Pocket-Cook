# Testing

## First verification after extracting

Run the setup script, then:

```bash
dart format lib test integration_test tool
flutter analyze
flutter test
flutter build web --release
```

These commands must pass on your resolved dependency versions before considering the project build-verified. No Flutter SDK was available when the archive was created; the included tests are authored, not claimed as executed.

## Flutter coverage supplied

The `test/` directory contains tests for serving arithmetic, search/filtering, ingredient conversion/merging, duplicate-safe grocery updates and week synchronization, wall-clock timers, account switching, the demo identity, local document-store batching/isolation, date/input validation, theme preferences, and mobile/wide/guest widget smoke checks.

`integration_test/recipe_to_groceries_test.dart` covers a user path through search, details, favorite save, serving adjustment and grocery creation. Use a supported Android/iOS test target:

```bash
flutter test integration_test/recipe_to_groceries_test.dart -d YOUR_DEVICE_ID
```

The widget suite does not replace visual review on real devices. It does not prove production backend behavior or store compliance.

## Node data checks

Node.js can run these without downloading npm dependencies:

```bash
node firebase/scripts/validate_seed.mjs
node --test firebase/tests/seed_validation.test.mjs
node firebase/scripts/seed_firestore.mjs --dry-run
```

These checks validate bundled data and seed-tool behavior only, not Dart implementation correctness. Their actual results are recorded in `verification/` and summarized in `VERIFICATION.md`.

## Firestore authorization tests

With Node 22+, Java 21, and network access to download the emulator:

```bash
cd firebase
npm install
npm run test:rules
```

The script automatically starts a local Firestore emulator, runs the test file, and stops it. Do not run it while another process uses the same port. Assertions exercise guest/private access, published recipe queries, ownership boundaries, client catalogue denial, profile field validation, favorite references, meal slots/servings, grocery envelopes and cross-account writes.

The suite deliberately does not claim full nested grocery ingredient validation because the rules only enforce the envelope at that level. See `DATABASE_SCHEMA.md`.

## Offline source structure checker

```bash
python tool/check_source.py
```

This custom utility checks Dart delimiter/string structure and local import paths, JSON parsing, and bundled recipe image references. **It is not the Dart compiler, analyzer, formatter, or type checker.** A pass does not establish valid Flutter APIs or runtime layouts.

## Manual acceptance before release

Exercise on a small phone, wide screen, dark mode and enlarged text. Test guest -> login -> save, sign-out with an open private form, a second account with different personal data, empty states and invalid input, and app restarts.

Check recipe servings 2 -> 5 -> 2; nonnumeric ingredients; kg/g versus cup/g grocery merging; re-adding a recipe; deleting one contribution; two planned days using the same ingredient; changing/deleting a planned meal and re-syncing the week; and unavailable recipes.

For cooking, test pause/resume, background/foreground, completed session restart and changed serving count. Do not expect an OS alarm. For Firebase, test rule denial, network loss, timeouts, and the same account on a second device.

## CI

`.github/workflows/verify.yml` defines a Flutter analysis/unit-test/web-build job and a Node/emulator rules job. It generates native/web scaffolding on the runner before verification. The workflow has not been run in this delivery; its presence is not a passing CI badge. Pin and commit dependency lockfiles after a successful local resolution for reproducibility.
