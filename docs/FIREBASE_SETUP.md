# Firebase setup for Liza's Kitchen

The checked-in Firebase client configuration points at project `cook-book-b23be`. If you move the app to another Firebase project, rerun `flutterfire configure` and use that new project ID in all commands below.

## 1. Firebase Console

Enable:
1. Authentication -> Sign-in method -> Email/Password.
2. Cloud Firestore.
3. For web development, keep `localhost` in Authentication -> Settings -> Authorized domains.

## 2. Install project dependencies

From the project root:

```powershell
flutter pub get
cd functions
npm install
cd ..\firebase
npm install
cd ..
```

`cloud_functions` is now a Flutter dependency because Admin user operations are callable backend functions.

## 3. Deploy database rules, indexes, and Admin functions

From the project root:

```powershell
firebase login
firebase use cook-book-b23be
firebase deploy --only firestore,functions --project cook-book-b23be
```

Cloud Functions deployment requires the Firebase project to be on the Blaze plan. Firestore-only/local-emulator development can still be used separately.

## 4. Create your Admin securely

Download a service-account key from Firebase Console -> Project settings -> Service accounts and keep it outside this project.

```powershell
cd firebase
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\FirebaseKeys\liza-admin-sdk.json"
$env:ADMIN_EMAIL="YOUR_DESIRED_ADMIN_EMAIL"
$env:ADMIN_PASSWORD="YOUR_DESIRED_ADMIN_PASSWORD"
$env:ADMIN_NAME="Liza Kitchen Admin"
npm run bootstrap:admin -- --project cook-book-b23be
Remove-Item Env:ADMIN_EMAIL, Env:ADMIN_PASSWORD, Env:ADMIN_NAME, Env:GOOGLE_APPLICATION_CREDENTIALS
cd ..
```

The script is idempotent: if that email already exists in Firebase Authentication, it updates that account and assigns the Admin role instead of creating a duplicate.

## 5. Seed recipes (if needed)

```powershell
cd firebase
node scripts/seed_firestore.mjs --dry-run
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\FirebaseKeys\liza-admin-sdk.json"
node scripts/seed_firestore.mjs --project cook-book-b23be --confirm-project cook-book-b23be
Remove-Item Env:GOOGLE_APPLICATION_CREDENTIALS
cd ..
```

## 6. Run against Firebase

```powershell
flutter run -d chrome --web-port=7357 --dart-define=USE_FIREBASE=true
```

Normal sign-up accounts are created as `visitor`. The bootstrapped account is `admin`. A Visitor can submit Become Cook; the Admin accepts it under Cook Requests, which changes the database role to `cook`.

## 7. Local emulators

Install dependencies under both `firebase/` and `functions/`, then from `firebase/`:

```powershell
npm run emulators
```

Run Flutter with:

```powershell
flutter run -d chrome --web-port=7357 --dart-define=USE_EMULATORS=true
```

Auth: 9099, Firestore: 8080, Functions: 5001, Emulator UI: 4000.

## Security notes

- Never hardcode an Admin password into Dart/web source.
- Never ship a Firebase service-account JSON in the app.
- Firestore rules enforce recipe and request permissions server-side.
- Admin Authentication operations are executed only by callable Cloud Functions using Admin SDK.
- Firebase Authentication passwords cannot be read back, including by an Admin.
