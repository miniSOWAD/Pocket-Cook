# Production checklist

This source is a functional implementation to validate and extend, not a claim of a production-certified release.

## Build and device verification

Resolve dependencies on the intended Flutter SDK; review and commit lockfiles. Run formatter, analyzer, unit/widget tests, the device integration test and emulator rules tests. Fix all resulting errors rather than suppressing them. Build and review Android, web and any intended iOS target. Test network loss, resumed sessions, account switching and enlarged text on real devices.

Replace `com.trendintools` / generated identifiers with your own application IDs before release. Configure signing, real app icons, store metadata, supported devices and platform permissions. This package provides recipe illustrations, not final platform launcher-icon assets.

## Accounts and privacy

Design and implement account deletion with deletion of relevant subcollections, export and retention behavior; deleting the profile document alone is not account deletion. Establish privacy policy and consent needs for your audience and jurisdiction. Evaluate email verification and abuse controls. Explain that cooking state/theme are device-local and that sign-out does not erase every cached/local byte.

Do not treat the demo store as encrypted or safe for sensitive data. Never distribute Admin SDK credentials with the client. Review account recovery and error wording with enumeration protection enabled.

## Firebase authorization and operations

Run the authorization tests against emulators. Review all rules before deploying to your explicitly selected project. Strengthen nested validation or use a trusted backend if shared/public writes or richer untrusted data are introduced. Consider App Check and server-side abuse controls. Set budget alerts, quotas, monitoring and backups appropriate to your use.

Use managed identity for operational tooling where possible, with least privilege. Separate development/staging/production configuration. Seed replacement should be an intentional administrative action, not something clients execute.

## Scale and data quality

Replace whole-catalog watches/local search with a scalable query and search strategy before large-scale content growth. Add batching/transactions and conflict handling before huge grocery lists or collaborative editing. Decide how historical meal plans and discontinued recipes should be retained.

Review recipes professionally for intended audiences, allergens and food handling. Do not present sample timing or unverified nutrition as medical/dietary guidance. Ensure rights and accessibility descriptions for any replacement images.

## Product promises

Do not market timers as guaranteed background alarms, favorites as guaranteed offline downloads, or the current rules as full nested data validation. These are explicitly not implemented. Add and test those capabilities before changing the claims.
