# Pocket Cook role system

Pocket Cook has three database-backed roles stored in `accounts/{uid}.role`:

- `admin` - user management, Cook-request approval, recipe-request review, and full recipe management.
- `cook` - recipe requests and full recipe management.
- `visitor` - the default role for normal registration; browsing, favourites, normal personal features, recipe requests, and Become Cook applications.

Account status is stored separately as `accounts/{uid}.status` with `active` or `blocked`.

## Collections

```text
accounts/{uid}
  displayName
  photoUrl
  role: admin | cook | visitor
  status: active | blocked
  createdAt
  updatedAt

cookApplications/{uid}
  uid
  requesterName
  message
  status: pending | approved | rejected
  createdAt
  reviewedAt

recipeRequests/{requestId}
  requesterUid
  requesterName
  requesterRole
  title
  details
  status: pending | accepted | rejected | fulfilled
  createdAt
  fulfilledRecipeId
  updatedAt (after staff action)

recipes/{recipeId}
  ...recipe fields...
  createdByUid
  cookName
  createdAt
  updatedAt
```

`users/{uid}` remains the private editable profile document. Authentication passwords are held only by Firebase Authentication and are never stored in Firestore or shown to admins.

## Role menus

Admin profile menu:
- Profile
- Favourites
- Manage users
- Cook Requests
- Manage Recipes
- Log out

Cook profile menu:
- Profile
- Favourites
- Request Recipe
- Manage Recipes
- Log out

Visitor profile menu:
- Profile
- Favourites
- Request Recipe
- Become Cook
- Log out

## Secure Admin creation

Do not put an Admin password in Flutter/Dart source code. The included one-time Admin SDK bootstrap script creates or updates the desired Firebase Authentication account and writes the Admin role to Firestore.

From `firebase/` after `npm install`:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\FirebaseKeys\pocket-cook-admin-sdk.json"
$env:ADMIN_EMAIL="your-admin@example.com"
$env:ADMIN_PASSWORD="replace-with-your-password"
$env:ADMIN_NAME="Md Mahruf"
npm run bootstrap:admin -- --project cook-book-b23be
Remove-Item Env:ADMIN_EMAIL, Env:ADMIN_PASSWORD, Env:ADMIN_NAME, Env:GOOGLE_APPLICATION_CREDENTIALS
```

Use a service-account JSON only on your trusted development/admin machine. Never put it in the Flutter assets, repository, ZIP you publish, or web build.

## Why Cloud Functions are included

Deleting, disabling, creating, and changing other Firebase Authentication users is privileged work. The Flutter client calls authenticated callable functions for these Admin actions. Each callable independently verifies that the caller's Firestore account is an active Admin before using Firebase Admin SDK.

Deployed callable functions:
- `adminListUsers`
- `adminCreateUser`
- `adminDeleteUser`
- `adminSetUserBlocked`
- `adminSetUserRole`
- `adminReviewCookApplication`

The current Admin cannot delete, block, or demote the account they are signed into, reducing accidental lockout risk.

## Existing users

Existing Firebase Authentication users do not need to register again. When an existing signed-in user has no `accounts/{uid}` document, the app creates an active `visitor` account record automatically. Run the Admin bootstrap for the one account that must be Admin.
