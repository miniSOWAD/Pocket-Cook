# Firebase and emulator setup

The default demo does not need any of this. Follow this guide only for emulator-backed or cloud-backed operation. All commands are run from the project root unless a `cd` command says otherwise.

## A. Local Firebase emulators

Install Node.js 22+ and Java 21, then install the provided tooling:

```bash
cd firebase
npm install
npm run emulators
```

Leave that terminal running. The project ID is deliberately `demo-recipe-app`; emulator hosts are bound to localhost, not the public network. Auth uses port 9099, Firestore 8080, and the local emulator UI 4000.

In another terminal, from the project root:

```bash
node firebase/scripts/seed_firestore.mjs --emulator
flutter run -d chrome --web-port=7357 --dart-define=USE_EMULATORS=true
```

Register a test email/password account in the app. Emulator accounts are not real production accounts. Password-reset links are inspected through emulator output/UI rather than real delivery. The supplied commands do not preserve emulator contents across restarts; re-seed and register test accounts again, or explicitly configure emulator export/import for your development workflow.

Android emulators use `10.0.2.2` to reach the host. Web and the iOS simulator use `127.0.0.1`. The app selects these defaults. Physical-device emulator access is not turn-key in this package because servers intentionally bind to localhost; configure a trusted development-only tunnel/network setup rather than exposing emulators publicly. Some native debug network policies may need development-only configuration on your SDK/device. Do not add permissive cleartext or transport exceptions to a release build.

A custom host can be passed as `--dart-define=EMULATOR_HOST=HOSTNAME`. The server still needs to be reachable from the target device.

Emulator mode initializes Firebase with non-secret demo-only options. It does not use the placeholder production configuration getter. Never ship a production application using these flags.

## B. Your own Firebase project

### 1. Create and configure your backend

Create a Firebase project in your own account. Enable Firebase Authentication's **Email/Password** sign-in provider. Create a Cloud Firestore database, choose your intended region, and use rules rather than an open test-mode database.

This implementation uses Authentication and Firestore only. No Cloud Storage bucket or Functions deployment is required for the bundled sample images.

Review project quotas, service pricing and budget alerts in your account. This guide is not a promise of free hosting or unlimited usage.

### 2. Install and log in to the CLIs

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

Make the Dart global package executable directory available on PATH if `flutterfire` is not found. On Windows that is commonly the `bin` directory under the user's Pub cache; use the path shown by your Dart installation.

Run the project setup script before registering platform apps so that application identifiers are established. Replace `YOUR_PROJECT_ID` below with the actual Firebase **project ID**, not its display name:

```bash
flutterfire configure --project=YOUR_PROJECT_ID
```

Select the platforms you intend to use. This generates/replaces `lib/firebase_options.dart` and configures platform applications. Follow any additional platform requirements printed by the CLI. Re-run configuration when adding platforms or changing application identifiers.

The supplied `.firebaserc` intentionally defaults to `demo-recipe-app`. Use explicit `--project` flags for production operations; do not accidentally deploy to the wrong project or broaden the rules to make a failing query work.

### 3. Deploy authorization rules

Inspect `firestore.rules` first. The following command changes the rules/index configuration of your selected project:

```bash
firebase deploy --only firestore:rules,firestore:indexes --project YOUR_PROJECT_ID
```

The app queries recipes with `isPublished == true`. Do not remove that filter: authorization is not a query-time filter for unpublished documents.

Private document ownership is enforced by UID. Client catalogue writes are always denied; the trusted Admin SDK seed script is the content-management path. See `DATABASE_SCHEMA.md` for validation boundaries, especially grocery ingredient arrays.

### 4. Seed the sample catalogue

```bash
cd firebase
npm install
cd ..
node firebase/scripts/seed_firestore.mjs --dry-run
```

For real database writes, provide Application Default Credentials with permissions for the selected project. A local developer identity configured using `gcloud auth application-default login` is one option. Another is a service-account credential stored **outside the repository**, referenced only through an environment variable.

PowerShell example when you deliberately use a service-account credential:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\secure\YOUR_PROJECT_ID-admin.json"
node firebase/scripts/seed_firestore.mjs --project YOUR_PROJECT_ID --confirm-project YOUR_PROJECT_ID
Remove-Item Env:GOOGLE_APPLICATION_CREDENTIALS
```

macOS/Linux equivalent:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/secure/YOUR_PROJECT_ID-admin.json"
node firebase/scripts/seed_firestore.mjs --project YOUR_PROJECT_ID --confirm-project YOUR_PROJECT_ID
unset GOOGLE_APPLICATION_CREDENTIALS
```

Do not create, share, upload or commit a service-account key casually. Prefer a suitable managed/developer identity where possible. Never bundle privileged credentials in Flutter assets, Dart code, the generated Firebase client options, or this ZIP.

**Seed behavior:** 13 recipe and 6 category records are validated before writes. Existing records are skipped by default. Pass `--overwrite` only when you deliberately want the bundled data to replace records with the same IDs. The script never deletes the rest of the catalogue. `--project` and `--confirm-project` must match for a real write. A set `FIRESTORE_EMULATOR_HOST` blocks a real-project seed until you unset it.

### 5. Start the cloud-connected app

```bash
flutter run -d chrome --web-port=7357 --dart-define=USE_FIREBASE=true
```

Register an account in the app, save a recipe, and test with a second account to confirm isolation. On a second configured device/browser, sign in to the same account to exercise cloud synchronization.

Local demo workspace data is not automatically imported into the Firebase account. Cooking progress and theme preference remain device-local in both modes.

## Rules tests

Close a running Firestore emulator before using the automatic rules-test command on the same port:

```bash
cd firebase
npm run test:rules
```

The test suite uses a demo project and emulator environment. It must not target your production database. Rules tests were included but not executed in the source-generation environment.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Setup screen says Firebase options are missing | Run `flutterfire configure`, or remove Firebase flags to run the local demo. |
| Firebase project has no recipes | Run the seed command against the correct project and confirm `isPublished` is true. |
| `permission-denied` | Check deployed rules, active UID, query filter and project ID. Do not switch to allow-all rules. |
| Email/password operation disabled | Enable the provider in Firebase Authentication. |
| Emulator connection refused | Check the server is running, ports are available, and the device can reach the configured host. |
| `flutter` or `dart` not found | Correct the Flutter SDK PATH and open a new terminal. |
| Dependency resolution fails | Check SDK constraint, network access and package resolver output; no lockfile was pre-generated. |
| Unexpectedly empty demo after browser restart | Use the same browser profile, host and port; private mode/site-data deletion does not preserve local data. |

## Official setup references

Consult these official references for version-specific platform and account requirements:

- Flutter CLI: https://docs.flutter.dev/reference/flutter-cli
- Firebase for Flutter setup: https://firebase.google.com/docs/flutter/setup
- Flutter email/password authentication: https://firebase.google.com/docs/auth/flutter/password-auth
- Emulator Suite: https://firebase.google.com/docs/emulator-suite
- Security Rules testing: https://firebase.google.com/docs/firestore/security/test-rules-emulator
- Application Default Credentials: https://cloud.google.com/docs/authentication/application-default-credentials

Package constraints and setup scripts in this archive were authored from official documentation but were not resolved or compiled in the generation environment. Check their output on your installed toolchain before deployment.
