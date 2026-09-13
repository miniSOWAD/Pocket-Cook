# Architecture

## Design

Liza's Kitchen uses feature-based Flutter code with Provider/ChangeNotifier presentation state. Widgets render state and forward actions. Repositories own persistence. Pure calculation classes own serving arithmetic, grocery merging, pantry matching and timer deadline logic.

```text
Screen / widget
  -> presentation provider
    -> repository interface
      -> local or Firebase implementation
```

Small features use one shared `DocumentStore` contract beneath feature-specific document repositories. `LocalDocumentStore` persists JSON to a key-value store for the demo. `FirestoreDocumentStore` implements the same watch/write contract with Firestore snapshots and batches. This avoids duplicating favorite, grocery, pantry, profile and meal-plan behavior in two backends.

The catalogue and authentication have distinct local/Firebase repositories because their source semantics differ. `AssetRecipeRepository` reads bundled JSON; `FirestoreRecipeRepository` watches published records. `DemoAuthRepository` is explicitly a workspace selector, not a password database. `FirebaseAuthRepository` delegates real credentials to Firebase Authentication.

## Initialization and dependency lifetime

`main.dart` ensures bindings and calls `bootstrap()`. Bootstrap initializes local preferences, optionally Firebase/emulators, and builds `AppDependencies`. Configuration failures show a setup screen; there is no silent fallback to a different identity/data store.

`AppProviders` creates shared providers. Providers are disposed with the widget tree. `AppDependencies.dispose()` closes local streams when used in tests; the production dependency container normally lives for the application lifetime.

## State scope

| State | Scope |
| --- | --- |
| Authentication and theme | App-wide |
| Published recipe catalogue | App-wide |
| Favorites, profile, groceries, meal plans, pantry | Shared, strictly tied to current user UID |
| Query/category/filter state | Search route |
| Recipe serving selection | Individual detail route |
| Step index and timer | Cooking route, persisted locally under UID/guest + recipe ID |
| Selected calendar date/week | Planner screen |

`UserScopedNotifier` observes the authentication provider. A UID change cancels old subscriptions, increments a generation number, clears private state synchronously and binds the new user's streams. Late stream callbacks and operation results are ignored when their generation is stale.

`LizasKitchenApp` replaces its Navigator key when leaving/replacing an authenticated session. This disposes old profile forms, grocery/pantry modals and other route-local snapshots. Guest-to-authenticated navigation is kept so a pending Save action can return to its recipe.

UI guards only handle navigation and prompts. Firestore rules enforce backend ownership; hiding a button is not authorization.

## Writes and errors

`AsyncNotifier.run()` serializes actions within a provider using a busy flag and maps errors to UI messages. Cloud actions have a 15-second visible timeout. A timeout does not cancel an SDK write already queued; the UI message acknowledges that it may still sync later.

Local document writes are serialized to avoid losing concurrent updates to one JSON snapshot. Firestore writes use a batch. A batch larger than 450 operations is rejected with an error rather than partly saved. Cross-device changes use Firestore's normal last-write-wins behavior; this is not a collaborative editing/transaction conflict system.

Stream conversion validates basic record shape. A malformed remote record raises a recoverable loading error rather than trusting arbitrary nested values. The catalogue is intentionally small and fetched as a whole; an invalid catalogue record can block that snapshot until its data is corrected.

## Recipe and grocery boundaries

The `Recipe` model is the single recipe representation. Favorites store references, not copies. Grocery sources store scaled ingredient contributions, not editable duplicate recipes. Meal-plan entries store recipe IDs plus title snapshots for unavailable-recipe display.

`ServingCalculator` always calculates from base recipe quantities. `IngredientMerger` and `PantryMatcher` use ingredient IDs and compatible canonical units, never labels alone or inferred cup/gram density.

## Platform and dependencies

Native/web scaffolding is generated with `flutter create` on the recipient's SDK. The package manifest targets Dart 3.9+, Provider, Firebase Core/Auth/Firestore, shared_preferences, and uuid. There is no generated dependency lockfile in the source archive because package resolution did not run here.

Provider, repositories and pure functions are sufficient for this project's scale. There is deliberately no extra use-case layer, custom navigation framework, server deployment, or admin application without an implemented requirement.
