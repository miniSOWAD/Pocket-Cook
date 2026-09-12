# Feature behavior and acceptance guide

## Recipes and search

The included catalogue has 13 sample recipes and six categories. Guest browsing does not require login. Search splits the query into words and matches the local title/ingredient/tag index; filters and sort apply to the loaded published catalogue. There is no typo correction, semantic search or paid external search service.

Select 1-12 servings. Displayed amounts always equal base amount multiplied by selected/base servings. Repeated adjustment must not introduce drift from re-scaling rounded display text. Null amounts stay nonnumeric. Changing servings does not change the recipe's suggested cooking time.

## Authentication and identity

Demo mode has one clearly labeled local workspace. Email/password controls are not used or persisted in that mode. Real email/password flows require Firebase or its emulators. A guest attempting to save is prompted to sign in and can return to the recipe afterward.

Private providers clear when the UID changes. Leaving a signed-in session also resets the navigator, preventing old private edit forms/modal content remaining in view. Profile editing changes the Firestore profile, not the Firebase Authentication display-name attribute; Home reads the profile first.

## Favorites

Favorites are IDs, not duplicated recipe documents. Saving an already saved recipe toggles its state. Catalogue changes can make a favorite unavailable; the saved-list UI can remove unavailable references. Saving is not an offline-download request.

## Groceries

A direct recipe contribution uses a stable source ID, so pressing Add to groceries again updates that source to the currently selected servings. Two different planned slots are separate sources and their compatible ingredients add together.

Do not merge by display name alone. `flour/g` and `flour/cup` remain different rows. `rice/kg` and `rice/g` can merge after scaling to grams. Manual ingredient IDs are normalized from their entered names; different spellings may need a consistent name to merge.

Edit the contribution rather than directly editing an aggregated row. Changes reset the purchase checkmarks of affected ingredients. Manual contributions can be edited/deleted. Removing one recipe preserves the amounts contributed by other recipes.


## My Pantry

Pantry is private, user-scoped inventory. Users can add or edit an ingredient, stored quantity and unit, an optional low-stock threshold, an optional expiry date, and a short note. Matching an entry to a known recipe ingredient ID is recommended because readiness compares IDs rather than fuzzy display-name similarity.

The All, Low stock, and Expiring filters operate on saved pantry data. “Expiring soon” means an expiry date from today through the next seven calendar days. Already expired items remain visible in All and are labeled expired; they are not silently removed.

Recipe suggestions rank the loaded catalogue by the percentage of measurable ingredients available at the recipe's base serving count, breaking ties by total recipe time. Statuses are Can make now, Almost ready, Missing some, and Needs a shop. kg/g and l/ml convert; incompatible units stay missing. Multiple pantry entries for the same ingredient ID and compatible unit are summed.

“Add missing to groceries” calculates each measurable deficit and stores it as one grouped grocery contribution with the stable ID `pantry_<recipeId>_missing`. Repeating the action updates that contribution instead of doubling it. Grouped pantry contributions can be removed from Groceries; edit them by refreshing from Pantry rather than editing one aggregated ingredient as though it were a single manual item.

Pantry does not currently deduct ingredients after cooking, scan barcodes, infer aliases such as `onions` = `onion`, or send expiry/low-stock notifications. Those are explicit later extensions.

## Planner

Each calendar day has four slots. Selecting an occupied slot prompts before replacing another recipe. Servings can be changed. Previous/next week navigation uses calendar arithmetic rather than UTC-hour offsets.

Sync week to groceries is explicit, not automatic. Re-sync after editing/deleting planned meals. An empty week's sync removes its previously imported slots after confirmation; other grocery sources stay intact. Editing an imported grocery contribution does not edit the plan, and the next plan sync restores planned servings.

## Cooking

Instructions display one step at a time. Progress and countdown state are saved locally when an action occurs. An unfinished session with the same selected servings resumes; completed sessions or changed servings start fresh. Back/next/reset update saved progress.

Timers use a deadline, not decrementing state tied to foreground execution. Leaving the foreground should not freeze remaining time; resuming re-evaluates the deadline. There is no alarm notification, audible alert, background execution guarantee or keep-screen-awake feature. Device clock changes affect wall-clock deadlines.

## Empty/error states

The app includes catalogue loading/empty/error states, empty favorites and groceries, unavailable recipe references, sign-in prompts and operation errors. Invalid remote record shapes surface as load errors instead of being silently trusted. Network write timeouts warn that queued writes may still complete.

## Not included

No admin dashboard, image upload, nutrition calculation, ratings/reviews, multi-user shared grocery lists, AI generator, push notification service, barcode scanning, automatic pantry deduction, account-deletion cascade or production monitoring. A recipe catalogue larger than a small app needs a new backend query/pagination/search design.
