import { readFileSync } from 'node:fs';
import { before, after, beforeEach, test } from 'node:test';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';

let env;

const account = (displayName, role = 'visitor', status = 'active') => ({
  displayName,
  photoUrl: '',
  role,
  status,
  createdAt: 1,
  updatedAt: 1,
});

const profile = { displayName: 'Alice Visitor', bio: '', updatedAt: 1 };
const favorite = { recipeId: 'published', savedAt: 1 };
const meal = {
  date: '2026-09-09',
  slot: 'dinner',
  recipeId: 'published',
  recipeTitle: 'Published recipe',
  servings: 2,
  updatedAt: 1,
};
const source = {
  title: 'Rice',
  recipeId: null,
  servings: 1,
  updatedAt: 1,
  ingredients: [{ id: 'rice', name: 'Rice', quantity: 200, unit: 'g', note: '' }],
};
const pantry = {
  ingredientId: 'rice',
  name: 'Rice',
  quantity: 1200,
  unit: 'g',
  lowStockThreshold: 300,
  expiryDate: null,
  note: 'Basmati',
  updatedAt: 1,
};

const recipe = (overrides = {}) => ({
  title: 'Kitchen test recipe',
  description: 'A complete recipe document used for rules tests.',
  categoryId: 'dinner',
  prepMinutes: 10,
  cookMinutes: 20,
  baseServings: 2,
  ingredients: [{ id: 'rice', name: 'Rice', quantity: 200, unit: 'g', note: '' }],
  steps: [{ title: 'Cook', instruction: 'Cook gently.', timerSeconds: 0 }],
  imageAsset: 'assets/images/recipes/bowl.png',
  imageUrl: '',
  difficulty: 'Easy',
  vegetarian: true,
  featured: false,
  isPublished: true,
  tags: ['test'],
  createdByUid: 'system',
  cookName: "Pocket Cook",
  createdAt: 1,
  updatedAt: 1,
  ...overrides,
});

const cookApplication = {
  uid: 'alice',
  requesterName: 'Alice Visitor',
  message: 'I enjoy home cooking.',
  status: 'pending',
  createdAt: 1,
  reviewedAt: null,
};

const recipeRequest = (uid = 'alice', name = 'Alice Visitor', role = 'visitor') => ({
  requesterUid: uid,
  requesterName: name,
  requesterRole: role,
  title: 'Please add kacchi biryani',
  details: 'A traditional version would be lovely.',
  status: 'pending',
  createdAt: 1,
  fulfilledRecipeId: '',
});

const dbFor = (uid) =>
  uid ? env.authenticatedContext(uid).firestore() : env.unauthenticatedContext().firestore();

before(async () => {
  const [host, port] = (process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080').split(':');
  env = await initializeTestEnvironment({
    projectId: 'demo-recipe-app',
    firestore: {
      host,
      port: Number(port),
      rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await Promise.all([
      setDoc(doc(db, 'recipes/published'), recipe()),
      setDoc(doc(db, 'recipes/draft'), recipe({ title: 'Draft recipe', isPublished: false })),
      setDoc(doc(db, 'categories/lunch'), { name: 'Lunch' }),
      setDoc(doc(db, 'accounts/alice'), account('Alice Visitor')),
      setDoc(doc(db, 'accounts/bob'), account('Bob Visitor')),
      setDoc(doc(db, 'accounts/cook'), account('Cook Bob', 'cook')),
      setDoc(doc(db, 'accounts/admin'), account('Kitchen Admin', 'admin')),
      setDoc(doc(db, 'accounts/blocked'), account('Blocked User', 'visitor', 'blocked')),
      setDoc(doc(db, 'users/alice'), profile),
      setDoc(doc(db, 'users/alice/favorites/published'), favorite),
    ]);
  });
});

after(async () => env?.cleanup());

test('guests can read published recipes but not drafts', async () => {
  await assertSucceeds(getDoc(doc(dbFor(), 'recipes/published')));
  await assertFails(getDoc(doc(dbFor(), 'recipes/draft')));
});

test('published-only recipe queries succeed for guests', async () => {
  await assertSucceeds(
    getDocs(query(collection(dbFor(), 'recipes'), where('isPublished', '==', true))),
  );
  await assertFails(getDocs(collection(dbFor(), 'recipes')));
});

test('visitors cannot create catalog recipes', async () => {
  await assertFails(
    setDoc(doc(dbFor('alice'), 'recipes/new'), recipe({
      createdByUid: 'alice',
      cookName: 'Alice Visitor',
    })),
  );
});

test('cooks can create, update, and delete recipes', async () => {
  const ref = doc(dbFor('cook'), 'recipes/cook-recipe');
  await assertSucceeds(
    setDoc(ref, recipe({ createdByUid: 'cook', cookName: 'Cook Bob' })),
  );
  await assertSucceeds(updateDoc(ref, { title: 'Updated by Cook', updatedAt: 2 }));
  await assertSucceeds(deleteDoc(ref));
});

test('admins can manage recipes', async () => {
  const ref = doc(dbFor('admin'), 'recipes/admin-recipe');
  await assertSucceeds(
    setDoc(ref, recipe({ createdByUid: 'admin', cookName: 'Kitchen Admin' })),
  );
  await assertSucceeds(deleteDoc(ref));
});

test('categories are publicly readable but not client-writable', async () => {
  await assertSucceeds(getDoc(doc(dbFor(), 'categories/lunch')));
  await assertFails(setDoc(doc(dbFor('admin'), 'categories/new'), { name: 'Other' }));
});

test('new users can create only their own Visitor account record', async () => {
  await assertSucceeds(setDoc(doc(dbFor('new-user'), 'accounts/new-user'), account('New User')));
  await assertFails(
    setDoc(doc(dbFor('new-admin'), 'accounts/new-admin'), account('Fake Admin', 'admin')),
  );
  await assertFails(setDoc(doc(dbFor('new-user'), 'accounts/someone-else'), account('Other')));
});

test('users can edit account identity but cannot change role or status', async () => {
  await assertSucceeds(
    updateDoc(doc(dbFor('alice'), 'accounts/alice'), {
      displayName: 'Alice Updated',
      photoUrl: 'https://example.com/alice.jpg',
      updatedAt: 2,
    }),
  );
  await assertFails(updateDoc(doc(dbFor('alice'), 'accounts/alice'), { role: 'admin', updatedAt: 3 }));
  await assertFails(updateDoc(doc(dbFor('alice'), 'accounts/alice'), { status: 'blocked', updatedAt: 3 }));
});

test('public users can see active cooks but not visitor account records', async () => {
  await assertSucceeds(getDoc(doc(dbFor(), 'accounts/cook')));
  await assertSucceeds(getDoc(doc(dbFor(), 'accounts/admin')));
  await assertFails(getDoc(doc(dbFor(), 'accounts/alice')));
});

test('admins can read account records', async () => {
  await assertSucceeds(getDoc(doc(dbFor('admin'), 'accounts/alice')));
});

test('users can read and update only their own private profile', async () => {
  await assertSucceeds(getDoc(doc(dbFor('alice'), 'users/alice')));
  await assertFails(getDoc(doc(dbFor('bob'), 'users/alice')));
  await assertSucceeds(
    setDoc(doc(dbFor('alice'), 'users/alice'), { ...profile, displayName: 'Alice Cook' }),
  );
  await assertFails(
    setDoc(doc(dbFor('alice'), 'users/alice'), { ...profile, role: 'admin' }),
  );
});

test('admins can read user profile roots but not bypass private subcollection rules', async () => {
  await assertSucceeds(getDoc(doc(dbFor('admin'), 'users/alice')));
  await assertFails(getDoc(doc(dbFor('admin'), 'users/alice/favorites/published')));
});

test('favorites remain private and require published recipes', async () => {
  await assertFails(getDocs(collection(dbFor(), 'users/alice/favorites')));
  await assertFails(getDoc(doc(dbFor('bob'), 'users/alice/favorites/published')));
  await assertSucceeds(deleteDoc(doc(dbFor('alice'), 'users/alice/favorites/published')));
  await assertFails(
    setDoc(doc(dbFor('alice'), 'users/alice/favorites/draft'), { recipeId: 'draft', savedAt: 1 }),
  );
});

test('valid meal plans, grocery data, and pantry data remain user scoped', async () => {
  await assertSucceeds(
    setDoc(doc(dbFor('alice'), 'users/alice/mealPlans/2026-09-09_dinner'), meal),
  );
  await assertFails(
    setDoc(doc(dbFor('bob'), 'users/alice/mealPlans/2026-09-09_dinner'), meal),
  );
  await assertSucceeds(
    setDoc(doc(dbFor('alice'), 'users/alice/grocerySources/manual-rice'), source),
  );
  await assertSucceeds(
    setDoc(doc(dbFor('alice'), 'users/alice/pantryItems/pantry-rice'), pantry),
  );
  await assertFails(
    setDoc(doc(dbFor('bob'), 'users/alice/pantryItems/pantry-rice'), pantry),
  );
});

test('blocked users lose access to their user-scoped data', async () => {
  await assertFails(getDocs(collection(dbFor('blocked'), 'users/blocked/favorites')));
  await assertFails(
    setDoc(doc(dbFor('blocked'), 'users/blocked/pantryItems/rice'), pantry),
  );
});

test('visitors can submit one valid Cook application for themselves', async () => {
  await assertSucceeds(setDoc(doc(dbFor('alice'), 'cookApplications/alice'), cookApplication));
  await assertFails(
    setDoc(doc(dbFor('alice'), 'cookApplications/bob'), { ...cookApplication, uid: 'bob' }),
  );
  await assertFails(
    setDoc(doc(dbFor('cook'), 'cookApplications/cook'), {
      ...cookApplication,
      uid: 'cook',
      requesterName: 'Cook Bob',
    }),
  );
});

test('Cook applications are visible to their owner and Admin only', async () => {
  await env.withSecurityRulesDisabled((context) =>
    setDoc(doc(context.firestore(), 'cookApplications/alice'), cookApplication),
  );
  await assertSucceeds(getDoc(doc(dbFor('alice'), 'cookApplications/alice')));
  await assertSucceeds(getDoc(doc(dbFor('admin'), 'cookApplications/alice')));
  await assertFails(getDoc(doc(dbFor('cook'), 'cookApplications/alice')));
});

test('active Visitors and Cooks can create recipe requests with their database role', async () => {
  await assertSucceeds(
    setDoc(doc(dbFor('alice'), 'recipeRequests/request-a'), recipeRequest()),
  );
  await assertSucceeds(
    setDoc(
      doc(dbFor('cook'), 'recipeRequests/request-cook'),
      recipeRequest('cook', 'Cook Bob', 'cook'),
    ),
  );
  await assertFails(
    setDoc(
      doc(dbFor('alice'), 'recipeRequests/fake-role'),
      recipeRequest('alice', 'Alice Visitor', 'admin'),
    ),
  );
});

test('recipe requests are visible to the requester and cooking staff', async () => {
  await env.withSecurityRulesDisabled((context) =>
    setDoc(doc(context.firestore(), 'recipeRequests/request-a'), recipeRequest()),
  );
  await assertSucceeds(getDoc(doc(dbFor('alice'), 'recipeRequests/request-a')));
  await assertSucceeds(getDoc(doc(dbFor('cook'), 'recipeRequests/request-a')));
  await assertSucceeds(getDoc(doc(dbFor('admin'), 'recipeRequests/request-a')));
  await assertFails(getDoc(doc(dbFor('bob'), 'recipeRequests/request-a')));
});

test('Cooks and Admins can update only recipe-request workflow fields', async () => {
  await env.withSecurityRulesDisabled((context) =>
    setDoc(doc(context.firestore(), 'recipeRequests/request-a'), recipeRequest()),
  );
  await assertSucceeds(
    updateDoc(doc(dbFor('cook'), 'recipeRequests/request-a'), {
      status: 'accepted',
      fulfilledRecipeId: '',
      updatedAt: 2,
    }),
  );
  await assertFails(
    updateDoc(doc(dbFor('cook'), 'recipeRequests/request-a'), {
      title: 'Changed title',
      status: 'accepted',
      fulfilledRecipeId: '',
      updatedAt: 3,
    }),
  );
});

test('unknown collections are denied', async () => {
  await assertFails(setDoc(doc(dbFor('admin'), 'anything/private'), { value: 1 }));
});
