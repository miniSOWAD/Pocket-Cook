# Bundled assets

`data/recipes.json` and `data/categories.json` are the local demo catalogue. Matching files under `firebase/seed/` feed the trusted Firestore seed script. Keep the two pairs in sync and run `node firebase/scripts/validate_seed.mjs` plus the seed-data tests after changes.

The current catalog contains **15 recipes**. `images/recipes/` contains 13 original bundled PNG illustrations; some neutral illustrations are intentionally reused across similar recipe types. They are not screenshots or copied tutorial assets.

No font files or external paid assets are included. UI typography uses Flutter/platform defaults. Any third-party images you add remain subject to their own rights and licensing.
