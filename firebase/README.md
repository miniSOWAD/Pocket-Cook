# Firebase tools

This folder contains Liza's Kitchen seed data, Firestore rule tests, validation utilities, and the secure Admin bootstrap.

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
npm run bootstrap:admin -- --project cook-book-b23be
```

The emulator commands use the isolated project ID `demo-recipe-app`; they do not write to production. The Admin bootstrap uses the project passed with `--project` and Application Default Credentials.

See `../docs/FIREBASE_SETUP.md` and `../docs/ROLE_SYSTEM.md` before deploying.
