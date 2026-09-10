import { readFileSync, existsSync } from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';
import path from 'node:path';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const validId = (value) => typeof value === 'string' && /^[a-z0-9][a-z0-9-]{0,79}$/.test(value);
const text = (value, max = 2000) => typeof value === 'string' && value.trim().length > 0 && value.length <= max;
const integer = (value, min, max) => Number.isInteger(value) && value >= min && value <= max;
const units = new Set(['', 'g', 'kg', 'ml', 'l', 'tsp', 'tbsp', 'cup', 'pcs']);

export function validateSeed(recipes, categories, { checkAssets = false } = {}) {
  const errors = [];
  const fail = (where, reason) => errors.push(`${where}: ${reason}`);
  if (!Array.isArray(categories) || categories.length === 0) return ['categories: expected a nonempty array'];
  if (!Array.isArray(recipes) || recipes.length === 0) return ['recipes: expected a nonempty array'];
  const categoryIds = new Set();
  categories.forEach((category, index) => {
    const where = `category[${index}]`;
    if (!category || !validId(category.id) || !text(category.name, 40)) { fail(where, 'invalid id or name'); return; }
    if (categoryIds.has(category.id)) fail(where, 'duplicate id');
    categoryIds.add(category.id);
  });
  const ids = new Set();
  recipes.forEach((recipe, index) => {
    const where = `recipe[${index}] ${recipe?.id ?? ''}`;
    if (!recipe || typeof recipe !== 'object') { fail(where, 'expected an object'); return; }
    if (!validId(recipe.id)) fail(where, 'invalid id');
    if (ids.has(recipe.id)) fail(where, 'duplicate id');
    ids.add(recipe.id);
    if (!text(recipe.title, 120) || !text(recipe.description, 2000)) fail(where, 'invalid title or description');
    if (!categoryIds.has(recipe.categoryId)) fail(where, 'unknown category');
    for (const field of ['prepMinutes', 'cookMinutes']) if (!integer(recipe[field], 0, 1440)) fail(where, `invalid ${field}`);
    if (!integer(recipe.baseServings, 1, 12)) fail(where, 'baseServings must be an integer from 1 to 12');
    for (const field of ['isPublished', 'vegetarian', 'featured']) if (typeof recipe[field] !== 'boolean') fail(where, `${field} must be boolean`);
    if (!['Easy', 'Medium', 'Advanced'].includes(recipe.difficulty)) fail(where, 'invalid difficulty');
    const asset = recipe.imageAsset;
    if (typeof asset !== 'string' || !/^assets\/images\/recipes\/[a-z0-9-]+\.png$/.test(asset)) {
      fail(where, 'invalid image asset path');
    } else if (checkAssets && !existsSync(path.join(root, asset))) fail(where, `missing asset ${asset}`);
    if (recipe.imageUrl !== '') {
      try { if (new URL(recipe.imageUrl).protocol !== 'https:') fail(where, 'imageUrl must use HTTPS'); }
      catch { fail(where, 'invalid imageUrl'); }
    }
    if (!Array.isArray(recipe.tags) || recipe.tags.length > 20 || recipe.tags.some((tag) => !text(tag, 40))) fail(where, 'invalid tags');
    if (!Array.isArray(recipe.ingredients) || recipe.ingredients.length < 1 || recipe.ingredients.length > 80) fail(where, 'expected 1 to 80 ingredients');
    else recipe.ingredients.forEach((ingredient, i) => {
      const position = `${where} ingredient[${i}]`;
      if (!ingredient || !validId(ingredient.id) || !text(ingredient.name, 80)) { fail(position, 'invalid ingredient id or name'); return; }
      if (ingredient.quantity !== null && (!Number.isFinite(ingredient.quantity) || ingredient.quantity <= 0 || ingredient.quantity > 100000)) fail(position, 'invalid quantity');
      if (!units.has(ingredient.unit)) fail(position, 'unsupported unit');
      if (ingredient.quantity !== null && ingredient.unit === '') fail(position, 'numeric quantities require a unit');
      if (typeof ingredient.note !== 'string' || ingredient.note.length > 240) fail(position, 'invalid note');
    });
    if (!Array.isArray(recipe.steps) || recipe.steps.length < 1 || recipe.steps.length > 40) fail(where, 'expected 1 to 40 steps');
    else recipe.steps.forEach((step, i) => {
      if (!step || !text(step.title, 100) || !text(step.instruction, 2500) || !integer(step.timerSeconds, 0, 86400)) fail(`${where} step[${i}]`, 'invalid cooking step');
    });
  });
  return errors;
}

export function loadSeed() {
  return {
    recipes: JSON.parse(readFileSync(path.join(root, 'firebase/seed/recipes.json'), 'utf8')),
    categories: JSON.parse(readFileSync(path.join(root, 'firebase/seed/categories.json'), 'utf8')),
  };
}
if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  const { recipes, categories } = loadSeed();
  const errors = validateSeed(recipes, categories, { checkAssets: true });
  if (errors.length) { console.error(errors.join('\n')); process.exitCode = 1; }
  else console.log(`Validated ${recipes.length} recipes, ${categories.length} categories, and all bundled image paths.`);
}
