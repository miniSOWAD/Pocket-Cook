# Database schema

Production roles and shared workflow data live in top-level Firestore collections. Personal recipe-app data remains under each Firebase Authentication UID.

```text
accounts/{uid}
categories/{categoryId}
recipes/{recipeId}
cookApplications/{uid}
recipeRequests/{requestId}

users/{uid}
users/{uid}/favorites/{recipeId}
users/{uid}/mealPlans/{YYYY-MM-DD_slot}
users/{uid}/grocerySources/{sourceId}
users/{uid}/groceryChecks/{encodedIngredientKey}
users/{uid}/pantryItems/{itemId}
```

## Accounts and roles

`accounts/{uid}` contains:

```text
displayName: string
photoUrl: string
role: admin | cook | visitor
status: active | blocked
createdAt: epoch milliseconds
updatedAt: epoch milliseconds
```

Normal registrations create `visitor`. The trusted Admin bootstrap can assign `admin`; Admin approval can assign `cook`. A normal client may update only its own display name/photo URL, never its role or status.

Active Cook/Admin account summaries are publicly readable so the Cooks directory can be viewed by Visitors/guests. Visitor account records are not public. Admin's callable backend lists Firebase Authentication users and combines those records with this collection.

## Private profile

`users/{uid}` contains only `displayName`, `bio`, and `updatedAt`. Authentication email/password are managed by Firebase Authentication, not copied into this profile. Passwords cannot be read back by the app or Admin UI.

## Categories

Category documents contain a display name. They are publicly readable and not client-writable.

## Recipes

Every recipe includes the existing recipe fields plus ownership/attribution:

```text
title, description, categoryId
prepMinutes, cookMinutes, baseServings
ingredients[], steps[]
imageAsset, imageUrl
difficulty, vegetarian, featured, isPublished, tags[]
createdByUid
cookName
createdAt
updatedAt
```

Guests/Visitors can read only published recipes. Active Cooks and Admins can read drafts and can add, edit, publish/unpublish, and delete recipes. New recipes must attribute `createdByUid` and `cookName` to the signed-in Cook/Admin. Existing seed recipes are attributed to `system` / `Liza's Kitchen`.

The UI displays `Cook: <name>` on recipe cards/details and management screens.

## Become Cook applications

`cookApplications/{uid}` contains:

```text
uid
requesterName
message
status: pending | approved | rejected
createdAt
reviewedAt
```

Only an active Visitor can create their own pending application. The owner and Admin can read it. Approval/rejection is performed through the trusted Admin callable function; approval updates `accounts/{uid}.role` to `cook`.

## Recipe requests

`recipeRequests/{requestId}` contains:

```text
requesterUid
requesterName
requesterRole
title
details
status: pending | accepted | rejected | fulfilled
createdAt
fulfilledRecipeId
updatedAt (after a staff action)
```

Any active registered role may create a request for itself. The requester can read their own requests. Active Cook/Admin users can read all requests and update workflow status. The Manage Recipes screen can use a pending/accepted request to prefill a new recipe and mark it fulfilled.

## Favorites

`users/{uid}/favorites/{recipeId}` stores `{recipeId, savedAt}`. It is private to the active owner and new favorites must reference a published recipe.

## Meal plans

`users/{uid}/mealPlans/{YYYY-MM-DD_slot}` stores `{date, slot, recipeId, recipeTitle, servings, updatedAt}`. Slots are breakfast/lunch/dinner/snack and servings are 1-12.

## Grocery data

`grocerySources` stores ingredient contributions from manual entry, recipes, plans, and pantry deficits. `groceryChecks` stores checked state. Both are private to the active owner.

## Pantry

`users/{uid}/pantryItems/{itemId}` stores `{ingredientId, name, quantity, unit, lowStockThreshold, expiryDate, note, updatedAt}`. Supported units are `pcs`, `g`, `kg`, `ml`, `l`, `tsp`, `tbsp`, and `cup`.

Recipe matching scales requested servings, aggregates pantry entries by ingredient ID, converts kg/g and l/ml where safe, and calculates measurable deficits for grocery handoff.

## Blocking

Blocking is represented in two places:

1. Firebase Authentication user is set `disabled=true` by a callable Cloud Function.
2. `accounts/{uid}.status` becomes `blocked`.

Firestore rules immediately deny that user's owner-scoped writes/reads even if an older Auth token remains temporarily valid. Blocking also revokes refresh tokens.

## Trusted versus direct-client writes

Direct Flutter writes are governed by `firestore.rules`. Privileged Authentication operations (list users, create another user, delete another user, block/unblock, change roles, approve Cook requests) run only in `functions/index.js` with Firebase Admin SDK after re-checking the caller's Admin role.

The one-time `firebase/admin/bootstrap_admin.mjs` script is also trusted tooling and must be run only with protected Application Default Credentials/service-account credentials.

## Device-local legacy keys

The `savor.*` keys still present in source are intentional migration fallbacks from the old branding. Current Liza's Kitchen keys are used for new writes; the old keys remain readable so existing local demo/theme/cooking data is not lost after the rename.
