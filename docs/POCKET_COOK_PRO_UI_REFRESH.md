# Pocket Cook professional UI refresh

This build replaces the previous theme-only landing page with a new dashboard-style interface.

## UI changes

- New Pocket Cook bowl logo built into the Flutter UI.
- Simplified app bar with cleaner brand placement and profile access.
- New landing dashboard with a personal welcome, smart-kitchen hero, Make ur plate CTA, search panel, category cards, recommendation card, and recipe grid.
- Mobile bottom navigation now uses a floating glassmorphism surface with backdrop blur.
- Shared feature-page headers were redesigned to remove decorative blobs and provide a cleaner hierarchy across the app.
- Login/register pages now use a responsive split-panel layout on larger screens and a compact professional card layout on mobile.
- Recipe cards were redesigned with tighter information hierarchy and cleaner metadata.
- Sparkle icons were removed from the entire Dart source.

## Admin display name

The default Admin bootstrap display name is now `Md Mahruf`. Re-run the Admin bootstrap with `ADMIN_NAME="Md Mahruf"` to update the existing Firebase Auth, account, and profile records. The UI also migrates the previous generated Admin placeholder name while the database is being updated.

## Recipe catalog

The bundled catalog contains 15 new recipes:

1. Peri-peri chicken rice bowl
2. Creamy spinach pasta
3. Beef keema toast
4. Coconut fish curry
5. Chicken shawarma wrap
6. Smoky chickpea couscous
7. Tomato egg skillet
8. Honey garlic chicken bites
9. Roasted vegetable soup
10. Mango yogurt breakfast bowl
11. Peanut banana smoothie
12. Orange cinnamon pancakes
13. Spicy tuna cucumber bites
14. Mocha mug pudding
15. Garlic herb noodle bowl

Firebase mode now uses the bundled catalog as the current system baseline and ignores stale `system` recipe IDs from an older seed. Admin/Cook-created recipes are still merged into the public catalog. This means old tutorial recipes no longer remain on the landing page simply because an older Firestore seed is still present.

To make Firestore itself match the new system catalog for Admin recipe management, run the existing replacement seed command with your service-account credentials:

```powershell
cd firebase
node scripts/seed_firestore.mjs --project cook-book-b23be --confirm-project cook-book-b23be --replace-system-recipes
```
