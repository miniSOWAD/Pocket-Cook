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

## Planner

Each calendar day has four slots. Selecting an occupied slot prompts before replacing another recipe. Servings can be changed. Previous/next week navigation uses calendar arithmetic rather than UTC-hour offsets.

Sync week to groceries is explicit, not automatic. Re-sync after editing/deleting planned meals. An empty week's sync removes its previously imported slots after confirmation; other grocery sources stay intact. Editing an imported grocery contribution does not edit the plan, and the next plan sync restores planned servings.

## Cooking

Instructions display one step at a time. Progress and countdown state are saved locally when an action occurs. An unfinished session with the same selected servings resumes; completed sessions or changed servings start fresh. Back/next/reset update saved progress.

Timers use a deadline, not decrementing state tied to foreground execution. Leaving the foreground should not freeze remaining time; resuming re-evaluates the deadline. There is no alarm notification, audible alert, background execution guarantee or keep-screen-awake feature. Device clock changes affect wall-clock deadlines.

## Empty/error states

The app includes catalogue loading/empty/error states, empty favorites and groceries, unavailable recipe references, sign-in prompts and operation errors. Invalid remote record shapes surface as load errors instead of being silently trusted. Network write timeouts warn that queued writes may still complete.

## Not included

No admin dashboard, image upload, nutrition calculation, ratings/reviews, multi-user shared grocery lists, AI generator, push notification service, account-deletion cascade or production monitoring. A recipe catalogue larger than a small app needs a new backend query/pagination/search design.
