# Testing

## Flutter verification

After resolving dependencies:

```powershell
flutter clean
flutter pub get
dart format lib test integration_test tool
flutter analyze
flutter test
flutter build web --release
```

The Flutter tests include auth navigation, account isolation, role parsing/permissions, pantry matching, grocery merging, recipe search, serving calculation, settings, cooking timer behavior, and widget smoke coverage.

## Seed/data verification

These use Node built-ins and can run without the Firebase emulator:

```powershell
node firebase/scripts/validate_seed.mjs
node --test firebase/tests/seed_validation.test.mjs
node firebase/scripts/seed_firestore.mjs --dry-run
```

## Firestore authorization suite

Install Node/Firebase test dependencies first:

```powershell
cd firebase
npm install
npm run test:rules
```

The emulator suite checks:
- guest published recipe access and draft denial
- Visitor recipe-write denial
- Cook/Admin recipe CRUD permissions
- role-escalation prevention
- public Cook/Admin directory visibility without exposing Visitor accounts
- profile/favourite/private-data boundaries
- blocked-user denial
- Become Cook application ownership
- recipe-request ownership and staff visibility
- Cook/Admin recipe-request workflow updates
- unknown collection denial

## Cloud Functions/manual Admin acceptance

After deploying functions, test with separate Admin, Cook, and Visitor accounts:

1. Visitor registers and appears as Visitor in Admin Manage users.
2. Visitor submits Become Cook.
3. Admin accepts; the same signed-in user UI changes to Cook after Firestore updates.
4. Cook adds/edits/deletes a recipe; `Cook: name` appears publicly when published.
5. Visitor/Cook submits a recipe request; Admin and Cook can see it under recipe management.
6. Admin creates a user.
7. Admin blocks another user; their app becomes blocked and future login fails.
8. Admin unblocks them; login works again.
9. Admin changes Visitor <-> Cook role.
10. Admin deletes a test user and that Firebase Authentication user no longer exists.
11. Confirm the current Admin cannot block, delete, or demote itself through the UI/backend.

Never test destructive Admin actions against a real user you cannot recreate.
