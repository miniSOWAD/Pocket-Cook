# Firebase tools

This folder contains Pocket Cook seed data, Firestore rule tests, validation utilities, the secure Admin bootstrap, and catalog seeding utilities.

Install once:

```powershell
npm install
```

Useful commands:

```powershell
npm run validate
npm run test:data
npm run test:rules
npm run emulators
```

Create/repair the Admin using the environment variables documented in `../docs/FIREBASE_SETUP.md`, then run the bootstrap directly or use `npm run bootstrap:admin` with `GCLOUD_PROJECT` set.

## Replace the bundled system recipe catalog

For a real Firebase project that still contains the old bundled recipes:

```powershell
node scripts/seed_firestore.mjs --project cook-book-b23be --confirm-project cook-book-b23be --replace-system-recipes
```

`--replace-system-recipes` removes obsolete recipes created by the system seed and writes the current 15 Pocket Cook recipes. It does **not** delete recipes created by real Cooks/Admins.

The emulator commands use the isolated project ID `demo-recipe-app`; they do not write to production.

See `../docs/FIREBASE_SETUP.md`, `../docs/ROLE_SYSTEM.md`, and the root `README.md` before deploying.
