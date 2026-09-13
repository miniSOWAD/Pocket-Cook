# Liza's Kitchen

Liza's Kitchen is a Flutter recipe, pantry, grocery, meal-planning, cooking, and community app using Provider with optional Firebase Authentication, Cloud Firestore, and callable Cloud Functions.

## Current major features

- Recipe discovery, search, category filters, details, serving scaling, and guided cooking.
- Favourites, meal planning, grocery lists, and My Pantry recipe matching.
- Baby-pink, cream, and off-white Liza's Kitchen design system.
- Email/password sign in, sign up, forgot-password flow, editable profile, and profile-photo URL.
- Public Cooks directory.
- Three Firestore-backed roles: Admin, Cook, and Visitor.
- Recipe requests and Become Cook applications.
- Admin user management: list, create, block/unblock, delete, and change roles.
- Admin Cook-request review.
- Admin/Cook recipe management: create, update, publish/draft, delete, and fulfil requested recipes.
- Recipe attribution using `Cook: name`.

## Role summary

| Role | Main permissions |
| --- | --- |
| Admin | Manage users, review Cook applications, review recipe requests, add/update/delete recipes, normal app features |
| Cook | Request recipes, add/update/delete recipes, normal app features |
| Visitor | Default registration role; browse, use normal personal features, request recipes, apply to Become Cook |

Roles and account status are stored in `accounts/{uid}`. Passwords remain inside Firebase Authentication and are never stored in Firestore.

See `docs/ROLE_SYSTEM.md` for the complete model and security boundaries.

## Requirements

- Flutter stable with Dart 3.9 or newer.
- Node.js 22 for the included Firebase tooling/functions.
- Firebase CLI for deployment.
- A Firebase project with Email/Password Authentication and Cloud Firestore enabled.

The checked-in Firebase client configuration currently targets `cook-book-b23be`.

## Install

From the project root:

```powershell
flutter clean
flutter pub get

cd functions
npm install
cd ..\firebase
npm install
cd ..
```

## Run with the real Firebase project

```powershell
flutter run -d chrome --web-port=7357 --dart-define=USE_FIREBASE=true
```

Without the Firebase define, the app uses the local demo workspace.

## Deploy the role backend

Admin user operations use authenticated callable Cloud Functions because client-side Flutter code must not have Firebase Admin privileges.

```powershell
firebase login
firebase deploy --only firestore,functions --project cook-book-b23be
```

Then create/update your one bootstrap Admin securely using the included Admin SDK script. Do **not** place the Admin password in Dart source:

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

For detailed Firebase setup, rules, functions, seeding, and emulator instructions see `docs/FIREBASE_SETUP.md`.

## Important Firebase behavior

- Normal Firebase registration always starts as Visitor.
- Existing Firebase Auth users automatically receive a Visitor account document when they next sign in if they do not already have one.
- Admin approval of a Become Cook request changes that user's database role to Cook.
- Blocking a user disables the Firebase Authentication account and marks the Firestore account as blocked.
- A currently signed-in Admin cannot delete, block, or demote themselves through the Admin UI.
- Admins cannot see user passwords; Firebase does not expose passwords.

## Source structure

```text
lib/
  app/
  core/
  features/
    accounts/            # roles, public Cook directory
    admin/               # privileged admin UI + callable client
    auth/
    cooking/
    favorites/
    grocery_list/
    meal_planner/
    pantry/
    profile/
    recipe_management/   # Admin/Cook CRUD
    recipes/
    requests/            # recipe + Become Cook requests
    settings/

functions/               # trusted Firebase Admin callable backend
firebase/
  admin/                  # one-time secure Admin bootstrap
  rules_tests/
  seed/
  scripts/
```

## Validation included

```powershell
cd firebase
npm run validate
npm run test:data
npm run test:rules
```

Flutter-side checks after installing Flutter dependencies:

```powershell
flutter analyze
flutter test
flutter build web --release
```

## Security

Do not ship a service-account key, Admin password, or Firebase Admin credentials in the Flutter app. Firestore rules enforce role permissions for direct database access, while privileged Authentication management occurs only in Cloud Functions.
