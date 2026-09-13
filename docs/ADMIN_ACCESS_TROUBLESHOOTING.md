# Admin role and Request Recipe troubleshooting

## Symptoms

- Profile shows `Visitor` after the Admin bootstrap.
- Request Recipe shows `permission-denied` / "You do not have access".

These are two backend-state checks, not a UI-only problem.

## 1. Verify the Admin record

From the project `firebase` folder, in the same PowerShell session that has your service-account credential:

```powershell
$env:ADMIN_EMAIL="YOUR_ADMIN_EMAIL"
$env:GCLOUD_PROJECT="cook-book-b23be"
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\FirebaseKeys\YOUR-SERVICE-ACCOUNT.json"

npm run verify:admin
```

A healthy account prints:

```text
Auth claim role: admin
Firestore role: admin
Firestore status: active
ADMIN CHECK PASSED.
```

If it fails, repair it with the idempotent bootstrap:

```powershell
$env:ADMIN_PASSWORD="USE_A_NEW_STRONG_PASSWORD"
$env:ADMIN_NAME="Liza Kitchen Admin"
npm run bootstrap:admin
```

The bootstrap now verifies both Firebase Auth custom claims and Firestore before it reports success.

## 2. Deploy the role-system Firestore rules

From the project root (the folder that contains `firebase.json`):

```powershell
firebase use cook-book-b23be
firebase deploy --only firestore --project cook-book-b23be
```

The current rules allow an active Visitor, Cook, or Admin to create a recipe request, and allow that requester to read their own requests.

If Manage Users / Cook approvals are needed, deploy Functions too:

```powershell
firebase deploy --only functions --project cook-book-b23be
```

Cloud Functions deployment may require the Firebase project billing plan required by Firebase for Functions.

## 3. Refresh the browser session

After changing an Auth custom claim, sign out and sign in again. The Firestore `accounts/{uid}` role is live, but Firebase ID-token claims can remain cached in an existing session until the token refreshes.

## Emergency manual Firestore correction

You may manually repair the database role if necessary:

1. Firebase Console -> Authentication -> Users.
2. Find the Admin email and copy its UID.
3. Firebase Console -> Firestore Database -> Data -> `accounts`.
4. Open the document whose ID is exactly that UID.
5. Set the string field `role` to `admin`.
6. Set the string field `status` to `active`.

Do not create an account document under an email address. The document ID must be the Firebase Authentication UID.

A manual Firestore edit fixes the app/rules role, but rerun the bootstrap afterward so the Firebase Auth custom claim also remains `admin`.
