# Pocket Cook - a Flutter recipe app

A feature-based Flutter + Provider recipe application, with a local demo and an optional Firebase backend. This is an original implementation of the project we planned, not source extracted from the referenced YouTube tutorial.

**Delivery status:** Application source, bundled artwork/data, Firebase rules, setup tools, and tests are included. Flutter/Dart were unavailable in the generation environment, so this ZIP is **not a verified compiled build**. See [the verification report](docs/VERIFICATION.md) for the exact checks that did run.

## Start here: Windows

Install a stable Flutter SDK containing Dart 3.9 or newer, put its `bin` directory on PATH, and install Chrome for the simplest first run. Extract this archive, then open PowerShell **inside `savor_recipe_app`**:

```powershell
flutter doctor
powershell -ExecutionPolicy Bypass -File .\tool\setup.ps1
flutter run -d chrome --web-port=7357
```

The execution-policy setting applies to that PowerShell process. Inspect the script before running it. A manual alternative is below.

## Start here: macOS / Linux

```bash
cd savor_recipe_app
flutter doctor
bash tool/setup.sh
flutter run -d chrome --web-port=7357
```

**The default is demo mode. No Firebase project, email, password, or Node installation is needed to try it.** Browse as a guest. Open Saved, Plan, Groceries, Pantry, or the profile button and choose **Enter demo workspace** to use local personal features. This is deliberately not represented as real authentication.

Use the same browser origin/port to retain browser-local demo data. Demo data is stored on that device/browser and can be lost when app data or site storage is cleared.

### What the setup script does

1. Uses your installed Flutter SDK to create official Android, iOS, and web platform projects around the included application code.
2. Configures Savor display names, Android internet access, an Android API 24 minimum (or the SDK's higher default), and iOS 15 minimum.
3. Runs `flutter pub get` to resolve dependencies and generate `pubspec.lock`.

This archive deliberately does **not** contain fabricated Gradle/Xcode scaffolding, compiled binaries, dependency downloads, or a fabricated lockfile. The platform folders and lockfile are generated on your machine. Review and commit the generated lockfile and platform projects after setup. Keep your work in version control before re-running scaffolding on a modified project.

Manual equivalent:

```bash
flutter create --project-name recipe_app --org com.trendintools --platforms=android,ios,web --no-pub .
dart tool/configure_platforms.dart
flutter pub get
```

## Included features

| Feature | Implementation |
| --- | --- |
| Discovery | Featured recipe, six categories, recipe cards, responsive phone/wide layouts. |
| Search | Local matching across titles, ingredients and tags; category, vegetarian and 30-minute filters; sort and progressive display. |
| Details | Ingredients/instructions, 1-12 servings, base-quantity scaling, nonnumeric "to taste" amounts. |
| Authentication | Explicit local demo workspace; real Firebase email/password registration, sign-in, reset, and sign-out in Firebase mode. |
| Favorites | Persistent saved recipe IDs; user-scoped state; unavailable-recipe handling. |
| Guided cooking | Step progress, pause/resume/reset countdown, saved wall-clock deadline, saved device-local session. |
| Grocery list | Recipe and manual contributions, compatible-unit merging, checkmarks, source editing/removal, duplicate-safe updates. |
| Meal planner | Weekly planning, breakfast/lunch/dinner/snack slots, serving counts, add/replace/remove, explicit week-to-groceries sync. |
| My Pantry | Private ingredient inventory, quantity/unit tracking, low-stock thresholds, expiry dates, recipe readiness ranking, and one-tap missing-ingredient grocery handoff. |
| Profile/settings | Display name, bio, system/light/dark preference, account-aware navigation reset. |
| Content | 13 original sample recipes and 13 bundled original PNG illustrations. No external image service is required. |
| Backend tooling | Firestore rules, safe seed script, localhost emulators, data checks, rule tests, and a CI workflow. |

There is no admin dashboard, recipe-upload UI, user reviews, nutrition database, social feed, payment flow, or AI recipe generator. These were not part of the agreed implementation. The content-management path is the trusted seed script.

## Three operating modes

| Mode | Launch | Data and authentication |
| --- | --- | --- |
| Local demo | `flutter run -d chrome --web-port=7357` | Bundled recipes, local workspace, preferences-backed persistence. |
| Firebase emulators | `flutter run -d chrome --web-port=7357 --dart-define=USE_EMULATORS=true` | Real Firebase SDK APIs against local Auth/Firestore emulators; no production project. |
| Your Firebase project | `flutter run -d chrome --web-port=7357 --dart-define=USE_FIREBASE=true` | Your configured Firebase Authentication and Firestore. Requires setup below. |

Emulator mode takes precedence when both flags are set. Do not use emulator flags in a production release. A Firebase configuration error shows a setup screen instead of silently switching the user into a local demo.

[Firebase and emulator setup](docs/FIREBASE_SETUP.md) contains all commands. `lib/firebase_options.dart` is an intentional configuration guard until `flutterfire configure` generates your client configuration. Do not paste service-account credentials into that file.

## Run on Android or iOS

After setup, start an Android emulator or connect an Android phone with development/debugging enabled:

```bash
flutter devices
flutter run -d YOUR_DEVICE_ID
```

For a debug APK after local verification:

```bash
flutter build apk --debug
```

The expected Flutter output location is `build/app/outputs/flutter-apk/app-debug.apk`. No APK is included in this archive. An iOS build requires macOS, Xcode and the appropriate signing/device setup. Web is included as a convenient demo target, not as a claim of production web deployment.

## Verify the project on your machine

```bash
dart format lib test integration_test tool
flutter analyze
flutter test
flutter build web --release
```

Or run `bash tool/verify.sh` / `powershell -ExecutionPolicy Bypass -File .\tool\verify.ps1`.

The included device integration test can be run with an Android/iOS test target:

```bash
flutter test integration_test/recipe_to_groceries_test.dart -d YOUR_DEVICE_ID
```

Node-only checks need no npm dependency installation:

```bash
node firebase/scripts/validate_seed.mjs
node --test firebase/tests/seed_validation.test.mjs
node firebase/scripts/seed_firestore.mjs --dry-run
```

Full Firebase rule tests require the emulator tooling; see [testing](docs/TESTING.md). The CI workflow is provided, but was not executed as part of this delivery.

## Repository map

```text
lib/app/                   Startup, dependencies, navigation and app shell
lib/core/                  Shared state, storage, errors, theme and widgets
lib/features/              Auth, recipes, favorites, cooking, groceries, planner, pantry,
                           profile and settings
assets/data/               Bundled demo catalogue
assets/images/recipes/     Original recipe illustrations
firebase/                  Seed data/scripts, rule tests and Node checks
firestore.rules            Backend authorization and record-envelope validation
test/                      Flutter unit and widget tests
integration_test/          Device user-journey test
tool/                      Windows/POSIX setup, platform patching and verification
docs/                      Architecture, schema, setup, behavior and test status
```

Several small modules share the `DocumentStore` abstraction rather than duplicating Firebase and local implementations for every feature. See [architecture](docs/ARCHITECTURE.md) and [the complete file tree](docs/PROJECT_TREE.txt).

## Deliberate boundaries

- **Small catalogue:** Firestore watches all published recipes. Search and Show more work on that in-memory catalogue; they are not server-side full-text search or server pagination. Introduce a dedicated query/search design before scaling to a large catalogue.
- **Timer:** There is no OS-level background alarm, notification, or sound. The deadline is recalculated when the app resumes; changing the device clock affects it. Use a separate cooking alarm when needed.
- **Offline:** Bundled demo content works without a backend. Firebase mode relies on SDK behavior and is not a guaranteed offline-download product. A favorite is not a downloaded recipe.
- **Local privacy:** Demo data is not encrypted. Cooking progress and theme preferences are device-local in both modes; cloud-synchronized data includes favorites, profile, meal plans, groceries, and pantry items.
- **Meal-plan sync:** Use Sync week to groceries after changing or deleting planned meals. Sync replaces that week's imported contributions, not other weeks or manual items. It is not a background process.
- **Units:** kg/g and l/ml conversions are supported in grocery merging and pantry matching; cups/grams are never guessed. Ingredients with different IDs do not match just because their labels look similar.
- **Pantry readiness:** Numeric recipe ingredients are compared against pantry stock at the recipe's base serving count. Nonnumeric ingredients such as ‘salt to taste’ do not block readiness. Pantry quantities are not automatically deducted after cooking in this version.
- **Concurrency:** Batches are atomic within the repository. Cross-device edits are last-write-wins, not collaborative conflict resolution. Cloud operations time out visibly after 15 seconds; a queued operation can still complete later.
- **Scale limits:** A batch is capped at 450 writes. Extremely large grocery lists need a chunking/server transaction strategy; this version reports an error instead of partially applying a batch.
- **Content:** Sample cooking times and recipes are demonstration content, not professionally validated nutrition or dietary advice. Check allergens and handling requirements for your ingredients.
- **Production:** Email verification enforcement, in-app account deletion/data export, App Check, release signing, monitoring, privacy policy and store compliance are not implemented. Read the [production checklist](docs/PRODUCTION_CHECKLIST.md).

## Documentation and licenses

- [Quick start](START_HERE.md)
- [Firebase setup](docs/FIREBASE_SETUP.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Database schema](docs/DATABASE_SCHEMA.md)
- [Feature behavior](docs/FEATURE_BEHAVIOR.md)
- [Testing](docs/TESTING.md)
- [Verification report](docs/VERIFICATION.md)
- [Production checklist](docs/PRODUCTION_CHECKLIST.md)

Original code and illustrations are provided under the [MIT License](LICENSE). Dependencies retain their own licenses; see [third-party notes](THIRD_PARTY_NOTICES.md). No tutorial source, paid assets, font files, Firebase credentials, or user data are bundled.
