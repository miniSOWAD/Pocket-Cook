# Bundled assets

`data/recipes.json` and `data/categories.json` are the local demo catalogue. Matching files under `firebase/seed/` feed the trusted Firestore seed script. Keep the two pairs in sync and run `node firebase/scripts/validate_seed.mjs` plus the seed-data tests after changes.

`images/recipes/` contains 13 original programmatically drawn PNG illustrations, one per recipe. They are not screenshots, photos of actual dishes, or copies from the tutorial. They are included under the root MIT license.

No font files or external paid assets are included. UI typography uses Flutter/platform defaults. Any third-party images you add remain subject to their own rights and licensing.
