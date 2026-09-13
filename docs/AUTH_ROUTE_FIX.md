# Authentication route fix

## Root cause

The sign-up link used `Navigator.pushNamed<bool>(...)` while `AppRouter.onGenerateRoute` creates `MaterialPageRoute<dynamic>`. On Flutter Web, the navigator attempted to cast the generated route to `Route<bool?>`, throwing before the registration page could open. The same mismatch existed in the shared `ensureSignedIn` guard.

## Fix

- Removed the typed `bool` result from the named Sign up navigation.
- Removed the typed `bool` result from the login guard.
- Added widget regression tests for Sign up and Forgot password navigation.
- Added an actionable Firebase `unauthorized-domain` message.
- Aligned `.firebaserc` with the FlutterFire project `cook-book-b23be`.

## Firebase Console checks

After the route fix, Email/Password must be enabled under Firebase Authentication > Sign-in method. For Flutter Web development, Authentication > Settings > Authorized domains should also contain `localhost` when testing on localhost. These Console settings are separate from Firestore; public recipes can load from Firestore even when Authentication is not enabled.
