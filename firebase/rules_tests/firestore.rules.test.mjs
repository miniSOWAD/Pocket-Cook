import { readFileSync } from 'node:fs';
import { before, after, beforeEach, test } from 'node:test';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, setDoc, getDoc, getDocs, deleteDoc, collection, query, where } from 'firebase/firestore';
let env;
const profile = { displayName: 'Home cook', bio: '', updatedAt: 1 };
const favorite = { recipeId: 'published', savedAt: 1 };
const meal = { date: '2026-09-09', slot: 'dinner', recipeId: 'published', recipeTitle: 'Published recipe', servings: 2, updatedAt: 1 };
const source = { title: 'Rice', recipeId: null, servings: 1, updatedAt: 1,
  ingredients: [{ id: 'rice', name: 'Rice', quantity: 200, unit: 'g', note: '' }] };
const dbFor = (uid) => uid ? env.authenticatedContext(uid).firestore() : env.unauthenticatedContext().firestore();
before(async () => {
  const [host, port] = (process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080').split(':');
  env = await initializeTestEnvironment({ projectId: 'demo-recipe-app', firestore: {
    host, port: Number(port), rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8'),
  }});
});
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await Promise.all([
      setDoc(doc(db, 'recipes/published'), { title: 'Published recipe', isPublished: true }),
      setDoc(doc(db, 'recipes/draft'), { title: 'Draft recipe', isPublished: false }),
      setDoc(doc(db, 'categories/lunch'), { name: 'Lunch' }),
      setDoc(doc(db, 'users/alice'), profile),
      setDoc(doc(db, 'users/alice/favorites/published'), favorite),
    ]);
  });
});
after(async () => env?.cleanup());
test('guests can read published recipes', async () => assertSucceeds(getDoc(doc(dbFor(), 'recipes/published'))));
test('guests cannot read drafts', async () => assertFails(getDoc(doc(dbFor(), 'recipes/draft'))));
test('published-only queries succeed', async () => assertSucceeds(getDocs(query(collection(dbFor(), 'recipes'), where('isPublished', '==', true)))));
test('unfiltered recipe queries fail', async () => assertFails(getDocs(collection(dbFor(), 'recipes'))));
test('clients cannot create catalog recipes', async () => assertFails(setDoc(doc(dbFor('alice'), 'recipes/new'), { isPublished: true })));
test('categories are publicly readable but not writable', async () => {
  await assertSucceeds(getDoc(doc(dbFor(), 'categories/lunch')));
  await assertFails(setDoc(doc(dbFor('alice'), 'categories/new'), { name: 'Other' }));
});
test('users can read their own profile', async () => assertSucceeds(getDoc(doc(dbFor('alice'), 'users/alice'))));
test('another user cannot read the profile', async () => assertFails(getDoc(doc(dbFor('bob'), 'users/alice'))));
test('profile role escalation is rejected', async () => assertFails(setDoc(doc(dbFor('alice'), 'users/alice'), { ...profile, role: 'admin' })));
test('valid profile updates succeed', async () => assertSucceeds(setDoc(doc(dbFor('alice'), 'users/alice'), { ...profile, displayName: 'Alice Cook' })));
test('guests cannot read favorites', async () => assertFails(getDocs(collection(dbFor(), 'users/alice/favorites'))));
test('another user cannot read or remove favorites', async () => {
  await assertFails(getDoc(doc(dbFor('bob'), 'users/alice/favorites/published')));
  await assertFails(deleteDoc(doc(dbFor('bob'), 'users/alice/favorites/published')));
});
test('owners can remove favorites', async () => assertSucceeds(deleteDoc(doc(dbFor('alice'), 'users/alice/favorites/published'))));
test('favorite IDs must match their documents', async () => assertFails(setDoc(doc(dbFor('alice'), 'users/alice/favorites/wrong'), favorite)));
test('draft recipes cannot be newly favorited', async () => assertFails(setDoc(doc(dbFor('alice'), 'users/alice/favorites/draft'), { recipeId: 'draft', savedAt: 1 })));
test('valid meal plans succeed', async () => assertSucceeds(setDoc(doc(dbFor('alice'), 'users/alice/mealPlans/2026-09-09_dinner'), meal)));
test('invalid meal servings fail', async () => assertFails(setDoc(doc(dbFor('alice'), 'users/alice/mealPlans/2026-09-09_dinner'), { ...meal, servings: 0 })));
test('meal IDs must match the date and slot', async () => assertFails(setDoc(doc(dbFor('alice'), 'users/alice/mealPlans/other'), meal)));
test('meal plans are isolated between users', async () => assertFails(setDoc(doc(dbFor('bob'), 'users/alice/mealPlans/2026-09-09_dinner'), meal)));
test('valid grocery contributions succeed', async () => assertSucceeds(setDoc(doc(dbFor('alice'), 'users/alice/grocerySources/manual-rice'), source)));
test('invalid grocery envelopes fail', async () => assertFails(setDoc(doc(dbFor('alice'), 'users/alice/grocerySources/manual-rice'), { ...source, ingredients: [] })));
test('grocery sources and checkmarks are private', async () => {
  await assertFails(setDoc(doc(dbFor('bob'), 'users/alice/grocerySources/manual-rice'), source));
  await assertFails(setDoc(doc(dbFor('bob'), 'users/alice/groceryChecks/key'), { checked: true }));
});
test('checkmarks only accept their schema', async () => assertFails(setDoc(doc(dbFor('alice'), 'users/alice/groceryChecks/key'), { checked: true, admin: true })));
test('unknown collections are denied', async () => assertFails(setDoc(doc(dbFor('alice'), 'anything/private'), { value: 1 })));
