# Pantry feature update

This update adds the **My Pantry / My Kitchen** feature to Savor.

## Included

- Private, user-scoped pantry inventory in local demo and Firestore modes.
- Add/edit/delete pantry items with ingredient identity, quantity, unit, optional low-stock threshold, expiry date, and note.
- Known recipe-ingredient matching so pantry stock can be compared reliably against recipes.
- All / Low stock / Expiring filters.
- Recipe readiness ranking with Can make now, Almost ready, Missing some, and Needs a shop states.
- kg/g and l/ml conversion; incompatible units are deliberately not guessed.
- Multiple compatible pantry entries for the same ingredient are aggregated for readiness.
- One-tap “Add missing to groceries” using only the measurable deficit.
- Stable grouped grocery contribution IDs, preventing repeated pantry imports from doubling the same deficit source.
- Firestore ownership/schema rules and four additional emulator rule tests.
- Pantry model/matching unit tests.

## Deliberate limits

- Pantry is not deducted automatically after cooking.
- No barcode/camera scanning.
- No fuzzy ingredient aliases.
- No push notifications for expiry or low stock.
- Expiry dates are informational and do not automatically delete stock.

Those can be added as separate follow-up features without changing the current pantry storage contract.
