# Pocket Cook

Pocket Cook is a Flutter recipe and kitchen-planning app built with Provider and optional Firebase Authentication, Cloud Firestore, and callable Cloud Functions.

## Current major features

- **Pocket Cook branding** across Flutter, Android, iOS, web/PWA metadata, documentation, seed data, and tests.
- **Cyan + light-blue + light-orange design system** with coordinated light and dark themes.
- **15 completely new bundled recipes** covering breakfast, lunch, dinner, snacks, dessert, and drinks.
- **Make ur plate**: users enter ingredients they already have, optionally add amounts/units, and receive ranked recipe suggestions.
- Recipe discovery, search, category filters, details, serving scaling, and guided cooking.
- Favourites, meal planning, grocery lists, and My Pantry recipe matching.
- Email/password sign in, sign up, forgot-password flow, editable profile, and profile-photo URL.
- Public Cooks directory.
- Three Firestore-backed roles: Admin, Cook, and Visitor.
- Recipe requests and Become Cook applications.
- Admin user management through callable Cloud Functions: list, create, block/unblock, delete, and change roles.
- Admin/Cook recipe management: create, update, publish/draft, delete, and fulfil requested recipes.
- Recipe attribution using `Cook: name`.

## Make ur plate

The new navbar destination lets a user add ingredients such as:

```text
Chicken        500 g
Rice           amount optional
Onion          2 pcs
```

If the amount is omitted, Pocket Cook treats that ingredient as available. When an amount is supplied, the matcher compares compatible units such as `kg ↔ g` and `l ↔ ml`, and also understands common cooking-volume units (`tsp`, `tbsp`, `cup`). Results are ranked as **Ready to cook**, **Almost there**, or a percentage match. Missing and insufficient ingredients are shown on each result.

The matcher is local application logic and does not require Cloud Functions or an AI API.

## Bundled recipe catalog

The project now ships these 15 recipes:

1. Chicken fried rice
2. Garlic butter noodles
3. Beef & potato curry
4. Vegetable khichuri
5. Egg paratha roll
6. Masala omelette
7. Chickpea tomato curry
8. Lemon fish with rice
9. Cheesy potato skillet
10. Apple cinnamon French toast
11. Strawberry lassi
12. Chocolate mug cake
13. Crispy chicken wrap
14. Red lentil dal
15. Spicy tuna pasta

Demo mode reads the new catalog from `assets/data/recipes.json`. Firebase mode reads Firestore, so an existing Firebase project must be reseeded if it still contains the previous system recipes.

## Replace the old Firebase system recipes

The updated seeder includes `--replace-system-recipes`. It removes only recipe documents where `createdByUid == "system"` that are no longer part of the bundled catalog, then writes the 15 new system recipes. Recipes created by real Cooks/Admins are not deleted.

From the project root:

```powershell
cd firebase
npm install
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\FirebaseKeys\YOUR-SERVICE-ACCOUNT.json"
node scripts/seed_firestore.mjs --project cook-book-b23be --confirm-project cook-book-b23be --replace-system-recipes
Remove-Item Env:GOOGLE_APPLICATION_CREDENTIALS
cd ..
```

Always verify that `cook-book-b23be` is the Firebase project you intend to modify before running the real-project seed command.

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

Firestore-only features can be deployed separately:

```powershell
firebase deploy --only "firestore:rules,firestore:indexes" --project cook-book-b23be
```

Privileged Admin Authentication operations use callable Cloud Functions and require a Firebase plan that supports Functions deployment:

```powershell
firebase deploy --only functions --project cook-book-b23be
```

Do **not** place the Admin password or Firebase Admin credentials in Dart source.

For detailed Firebase setup, rules, functions, seeding, and emulator instructions see `docs/FIREBASE_SETUP.md`.

## Source structure

```text
lib/
  app/
  core/
  features/
    accounts/
    admin/
    auth/
    cooking/
    favorites/
    grocery_list/
    make_plate/          # Make ur plate input + matching engine
    meal_planner/
    pantry/
    profile/
    recipe_management/
    recipes/
    requests/
    settings/

functions/               # trusted Firebase Admin callable backend
firebase/
  admin/
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

The Android application ID and iOS bundle identifier are intentionally left aligned with the existing Firebase app registrations so the current Firebase connection is not broken by the Pocket Cook rebrand. Their user-visible display names are Pocket Cook.
