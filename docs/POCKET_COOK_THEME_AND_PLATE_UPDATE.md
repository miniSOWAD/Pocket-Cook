# Pocket Cook — Cyan Theme + Make ur plate Update

## What changed

- Rebranded all user-facing application text to **Pocket Cook**.
- Replaced the previous pink/cream visual system with a **cyan + light blue + light orange** palette in both light and dark themes.
- Replaced the bundled catalog with **15 different recipes**.
- Added **Make ur plate** to the main navigation.

## Make ur plate

Users can enter ingredients they currently have. Quantity is optional. When a quantity is supplied, the matcher compares compatible units such as:

- `g` / `kg`
- `ml` / `l`
- `tsp` / `tbsp` / `cup`
- `pcs`

The results are ranked into recipes that are ready to cook and close matches. Missing ingredients and quantity shortages are displayed. Water and salt are treated as common kitchen staples.

The matcher is local application logic and does not require Cloud Functions or an AI API.

## New bundled recipes

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

## Important for Firebase mode

Editing the JSON seed files does not replace recipe documents that are already stored in Cloud Firestore. To replace only the old **system-seeded** recipes while leaving Cook/Admin-created recipes untouched, run from the project root:

```powershell
cd firebase
npm install
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\FirebaseKeys\YOUR-SERVICE-ACCOUNT.json"
node scripts/seed_firestore.mjs --project cook-book-b23be --confirm-project cook-book-b23be --replace-system-recipes
Remove-Item Env:GOOGLE_APPLICATION_CREDENTIALS
cd ..
```

The replacement command deletes obsolete documents only when `createdByUid == "system"`; user-created recipes are preserved.

## Firebase application identifiers

The user-facing application name is Pocket Cook. Existing Firebase-linked technical identifiers such as Android package `com.trendintools.recipe_app` are intentionally preserved so the current Firebase Android registration and `google-services.json` keep working. Renaming those identifiers requires registering new platform apps in Firebase and downloading replacement configuration files.

## Verification performed in the delivery environment

- Structural/local-import checks passed for 151 Dart files.
- JSON and all 15 recipe image references passed validation.
- 15 recipes and 6 categories passed seed validation.
- 16/16 seed validation tests passed.
- Cloud Functions, admin tools, and seed scripts passed Node syntax checks.
- Flutter/Dart SDK was not installed in the delivery environment, so `flutter analyze`, `flutter test`, and a device/web build could not be executed here.
