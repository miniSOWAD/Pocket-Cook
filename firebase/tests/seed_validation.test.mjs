import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { validateSeed, loadSeed } from '../scripts/validate_seed.mjs';
const seed = loadSeed();
const changed = (mutate) => { const value = structuredClone(seed); mutate(value); return validateSeed(value.recipes, value.categories); };

test('all bundled recipes and assets validate', () => assert.deepEqual(validateSeed(seed.recipes, seed.categories, { checkAssets: true }), []));
test('demo and Firestore recipe catalogs are identical', () => {
  const demo = JSON.parse(readFileSync(new URL('../../assets/data/recipes.json', import.meta.url), 'utf8'));
  assert.deepEqual(demo, seed.recipes);
});
test('demo and Firestore categories are identical', () => {
  const demo = JSON.parse(readFileSync(new URL('../../assets/data/categories.json', import.meta.url), 'utf8'));
  assert.deepEqual(demo, seed.categories);
});
test('duplicate recipe IDs are rejected', () => assert.ok(changed((s) => s.recipes.push(s.recipes[0])).some((e) => e.includes('duplicate'))));
test('unknown categories are rejected', () => assert.ok(changed((s) => s.recipes[0].categoryId = 'missing').some((e) => e.includes('category'))));
test('zero servings are rejected', () => assert.ok(changed((s) => s.recipes[0].baseServings = 0).some((e) => e.includes('baseServings'))));
test('fractional servings are rejected', () => assert.ok(changed((s) => s.recipes[0].baseServings = 2.5).some((e) => e.includes('baseServings'))));
test('negative quantities are rejected', () => assert.ok(changed((s) => s.recipes[0].ingredients[0].quantity = -1).some((e) => e.includes('quantity'))));
test('non-finite quantities are rejected', () => assert.ok(changed((s) => s.recipes[0].ingredients[0].quantity = Infinity).some((e) => e.includes('quantity'))));
test('to-taste quantities are valid', () => assert.deepEqual(changed((s) => { s.recipes[0].ingredients[0].quantity = null; s.recipes[0].ingredients[0].unit = ''; }), []));
test('unrecognized units are rejected', () => assert.ok(changed((s) => s.recipes[0].ingredients[0].unit = 'mystery').some((e) => e.includes('unit'))));
test('empty instructions are rejected', () => assert.ok(changed((s) => s.recipes[0].steps = []).some((e) => e.includes('steps'))));
test('negative timers are rejected', () => assert.ok(changed((s) => s.recipes[0].steps[0].timerSeconds = -1).some((e) => e.includes('step'))));
test('unsafe remote image schemes are rejected', () => assert.ok(changed((s) => s.recipes[0].imageUrl = 'http://example.org/x.png').some((e) => e.includes('HTTPS'))));
test('asset traversal is rejected', () => assert.ok(changed((s) => s.recipes[0].imageAsset = '../../secret.png').some((e) => e.includes('asset'))));
test('missing assets are reported', () => {
  const s = structuredClone(seed); s.recipes[0].imageAsset = 'assets/images/recipes/missing.png';
  assert.ok(validateSeed(s.recipes, s.categories, { checkAssets: true }).some((e) => e.includes('missing asset')));
});
