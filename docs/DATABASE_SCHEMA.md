# Database schema

Cloud collections are below. In demo mode the same private paths are stored in a local JSON document store. Demo mode is not a secure multi-user backend.

```text
categories/{categoryId}
recipes/{recipeId}
users/{uid}
users/{uid}/favorites/{recipeId}
users/{uid}/mealPlans/{YYYY-MM-DD_slot}
users/{uid}/grocerySources/{sourceId}
users/{uid}/groceryChecks/{encodedIngredientKey}
users/{uid}/pantryItems/{itemId}
```

## Categories

`id` (implied by document ID) and `name`. All users may read categories; mobile/web clients cannot write them.

## Recipes

Fields: `title`, `description`, `categoryId`, `prepMinutes`, `cookMinutes`, `baseServings`, `imageAsset`, optional `imageUrl`, `difficulty`, `vegetarian`, `featured`, `isPublished`, `tags`, `ingredients`, `steps`.

A bundled seed record includes `id`; the trusted seeder stores the ID as the document key. The Firestore repository always uses the document ID as the model ID.

An ingredient is `{id, name, quantity, unit, note}`. `quantity` is a positive number or null for nonnumeric amounts such as salt to taste. Seed units are a deliberately small explicit vocabulary. A step is `{title, instruction, timerSeconds}`; zero means no suggested timer.

Recipe times are not scaled with servings. This project contains no rating/review records or verified nutrition fields. Optional remote image URLs must use HTTPS in the seed validator; bundled images are used by default.

Public recipe reads require `isPublished == true`. Queries include this exact restriction. Client writes to the catalogue are denied regardless of authentication; publishing is via trusted tooling.

## Profile

`users/{uid}` contains only `displayName`, `bio`, `updatedAt`. Name length is 2-60; bio is at most 240 characters. `updatedAt` is a client-supplied epoch-millisecond integer, not a trusted audit timestamp. Authentication identity/email are held by Firebase Authentication, not copied into this profile record. Missing profiles display the authentication name/default until edited.

There is no client-writable administrator/role field. The rule denies extra fields. Profile deletion does not cascade to subcollections and is not an implemented account deletion workflow.

## Favorites

`{recipeId, savedAt}`. The document ID equals the recipe ID, preventing duplicate favorites. A new favorite must reference a published recipe. Own deletes remain allowed when a recipe has become unavailable.

## Meal plans

`{date, slot, recipeId, recipeTitle, servings, updatedAt}`. Dates are local-calendar `YYYY-MM-DD` strings rather than UTC instants. Slots are breakfast/lunch/dinner/snack; servings are integer 1-12. The ID is `date_slot`, so saving a slot replaces that slot rather than silently creating duplicates.

The title is a display snapshot. Current recipe data is read from the published catalogue. Rule date checks enforce shape/ranges, not every real calendar combination; the client date parser performs calendar validation. Client timestamps are not audit evidence.

## Grocery contributions

`{title, recipeId, servings, updatedAt, ingredients}`. `recipeId` is null for a manual contribution. Ingredient quantities here already reflect the contribution's servings.

IDs have these meanings:

- `recipe_<id>`: added directly from recipe details; re-adding updates instead of doubling.
- `plan_<date>_<slot>`: imported from a meal-plan slot; repeated week sync replaces the same source.
- `manual-<uuid>`: manual ingredient contribution.
- `pantry_<recipeId>_missing`: grouped deficit created from a pantry recipe match; refreshing that recipe's missing items replaces the same contribution instead of doubling it.

Merged grocery rows are derived in memory. Compatible kg/g and l/ml are canonicalized; all other units require exact identity. Null amounts are not combined numerically with measured amounts. The row key is URL-safe Base64 of ingredient ID, canonical unit and amount/note type.

`groceryChecks` contains `{checked: true}`; unchecking deletes that key. Updating/removing a source deletes the checkmarks for affected ingredients. The source update/removal and checkmark resets are in the same batch.

Week sync removes outdated imported sources only for that selected week. It leaves manual sources, direct recipe sources and other weeks unchanged. Unavailable recipes block a sync instead of silently dropping their contribution.


## Pantry items

`users/{uid}/pantryItems/{itemId}` contains `{ingredientId, name, quantity, unit, lowStockThreshold, expiryDate, note, updatedAt}`.

`ingredientId` is the important link to recipe ingredients. The add/edit UI can select a known recipe ingredient so `rice` in the pantry matches `rice` in recipes. Custom names are normalized into an ID, but similarly spelled custom IDs are not guessed to be equivalent.

`quantity` is nonnegative. Supported units are `pcs`, `g`, `kg`, `ml`, `l`, `tsp`, `tbsp`, and `cup`. A null low-stock threshold disables low-stock status. `expiryDate` is null or a local-calendar `YYYY-MM-DD` value; expiry is informational and does not delete stock automatically. `updatedAt` is a client-supplied epoch-millisecond value, not trusted audit evidence.

Recipe matching scales the recipe to its requested servings, aggregates pantry entries with the same ingredient ID, and converts only kg/g and l/ml. It never guesses mass/volume conversions such as cups to grams. Nonnumeric recipe amounts such as “salt to taste” do not block readiness because stock sufficiency cannot be calculated precisely.

A missing-ingredient grocery action writes only the measurable deficit in canonical units. It does not deduct the pantry after cooking and it does not mutate the recipe.

## Rule validation boundary

Rules enforce UID ownership, allowed top-level fields, bounded names/IDs, serving ranges, timestamp types, published references for favorites/meal plans, pantry field/unit/quantity bounds, and grocery ingredient list size 1-80. **Rules do not iterate and fully validate every nested grocery ingredient record.** Client deserialization/seed tooling validate nested content, but are not a substitute for server validation. A modified authenticated client can write malformed nested data within its own grocery documents, not another user's documents. It can disrupt its own view until the data is repaired.

Before supporting shared lists, public submissions or privileged server processing, add stronger nested validation or a trusted write API. Do not describe this as a complete untrusted-input validation backend.

## Device-local records

- `savor.demo.session`: whether the explicitly labeled demo workspace is active.
- `savor.documents.v1`: local demo document JSON.
- `savor.theme`: theme choice.
- `savor.cooking.<scope>.<recipeId>`: index, servings, completed and timer state.

These preferences are not an encrypted vault. Signing out clears visible account state but does not erase all device storage. No password is stored in these preferences. Firebase SDK authentication persistence is managed by that SDK.
