# Pocket Cook: global navigation and second Admin

## Global bottom navigation

The glass navigation bar is now shared by the app shell and every named route.
That includes recipe details, cooking, search, profile, settings, authentication,
request pages, Manage Users, Cook Requests, and Manage Recipes.

On a nested page, choosing a primary destination resets the current route stack
and returns to the selected main Pocket Cook destination.

Primary destinations:

- Home
- Saved
- Plan
- Groceries
- Pantry
- Make ur plate
- Cooks

## Add another Admin securely

Do not hardcode an Admin password in Flutter. Use the Firebase Admin bootstrap
script. Running it for a new email creates a second Admin; it does not demote or
remove an existing Admin.

From the project root, enter the Firebase tooling folder:

```powershell
cd firebase
npm install
```

Set your service-account credential path:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\FirebaseKeys\YOUR-SERVICE-ACCOUNT.json"
```

Set the new Admin details. Replace the example email and password with the real
ones for Md Mahruf:

```powershell
$env:ADMIN_EMAIL="MD_MAHRUF_EMAIL_HERE"
$env:ADMIN_PASSWORD="A_NEW_STRONG_PASSWORD"
$env:ADMIN_NAME="Md Mahruf"
$env:GCLOUD_PROJECT="cook-book-b23be"
```

Create or promote that account:

```powershell
npm run bootstrap:admin
```

Verify both Firebase Authentication custom claims and Firestore role data:

```powershell
npm run verify:admin
```

Expected role state:

```text
Firebase Authentication custom claim: role = admin
Firestore accounts/{uid}: role = admin
Firestore accounts/{uid}: status = active
```

After the command succeeds, sign out and sign back in as Md Mahruf so the
browser receives a fresh Firebase ID token containing the Admin claim.

Clean the PowerShell environment afterward:

```powershell
Remove-Item Env:ADMIN_EMAIL -ErrorAction SilentlyContinue
Remove-Item Env:ADMIN_PASSWORD -ErrorAction SilentlyContinue
Remove-Item Env:ADMIN_NAME -ErrorAction SilentlyContinue
Remove-Item Env:GCLOUD_PROJECT -ErrorAction SilentlyContinue
Remove-Item Env:GOOGLE_APPLICATION_CREDENTIALS -ErrorAction SilentlyContinue
```

Never commit the service-account JSON or Admin password to this project.
