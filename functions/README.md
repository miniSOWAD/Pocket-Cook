# Pocket Cook Admin functions

These Node.js callable functions perform privileged Firebase Authentication actions that must not run inside the Flutter client.

Install:

```powershell
npm install
```

Deploy from the project root:

```powershell
firebase deploy --only functions --project cook-book-b23be
```

Every callable re-checks `accounts/{callerUid}` and requires `role=admin` and `status=active` before using Firebase Admin SDK.
