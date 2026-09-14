import { loadSeed, validateSeed } from './validate_seed.mjs';

function parseArgs(args) {
  const result = { emulator: false, overwrite: false, replaceSystemRecipes: false, dryRun: false, project: null, confirmProject: null };
  for (let i = 0; i < args.length; i++) {
    const flag = args[i];
    if (flag === '--emulator') result.emulator = true;
    else if (flag === '--overwrite') result.overwrite = true;
    else if (flag === '--replace-system-recipes') result.replaceSystemRecipes = true;
    else if (flag === '--dry-run') result.dryRun = true;
    else if (flag === '--project' || flag === '--confirm-project') {
      const value = args[++i];
      if (!value || value.startsWith('--')) throw new Error(`${flag} needs a project ID`);
      result[flag === '--project' ? 'project' : 'confirmProject'] = value;
    } else throw new Error(`Unknown argument: ${flag}`);
  }
  return result;
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const { recipes, categories } = loadSeed();
  const errors = validateSeed(recipes, categories, { checkAssets: true });
  if (errors.length) throw new Error(errors.join('\n'));
  if (options.dryRun) {
    console.log(`Dry run: ${recipes.length} recipe documents and ${categories.length} category documents. No writes performed.`);
    return;
  }
  const projectId = options.project ?? (options.emulator ? 'demo-recipe-app' : null);
  if (!projectId) throw new Error('Use --emulator, or provide --project ID --confirm-project ID for a real project.');
  if (options.emulator) {
    if (!projectId.startsWith('demo-')) throw new Error('Emulator seeding is restricted to demo-* project IDs.');
    process.env.FIRESTORE_EMULATOR_HOST ??= '127.0.0.1:8080';
  } else {
    if (process.env.FIRESTORE_EMULATOR_HOST) throw new Error('Unset FIRESTORE_EMULATOR_HOST before a real-project seed.');
    if (options.confirmProject !== projectId) throw new Error('For a real project, --confirm-project must exactly match --project.');
  }
  const { initializeApp, applicationDefault, deleteApp } = await import('firebase-admin/app');
  const { getFirestore } = await import('firebase-admin/firestore');
  const app = initializeApp(options.emulator ? { projectId } : { projectId, credential: applicationDefault() });
  try {
    const db = getFirestore(app);
    const batch = db.batch();
    let writes = 0, skipped = 0, removed = 0;

    if (options.replaceSystemRecipes) {
      const newRecipeIds = new Set(recipes.map((recipe) => recipe.id));
      const existingSystem = await db.collection('recipes').where('createdByUid', '==', 'system').get();
      for (const doc of existingSystem.docs) {
        if (newRecipeIds.has(doc.id)) continue;
        batch.delete(doc.ref);
        removed++;
      }
    }

    for (const [collection, records] of [['categories', categories], ['recipes', recipes]]) {
      for (const record of records) {
        const { id, ...data } = record;
        const ref = db.collection(collection).doc(id);
        const existing = await ref.get();
        const forceSet = options.overwrite || (options.replaceSystemRecipes && collection === 'recipes');
        if (existing.exists && !forceSet) { skipped++; continue; }
        if (forceSet) batch.set(ref, data);
        else batch.create(ref, data);
        writes++;
      }
    }
    if (writes > 0 || removed > 0) await batch.commit();
    console.log(`Seeded ${writes} documents in ${projectId}; removed ${removed} old system recipe documents; skipped ${skipped} existing documents. User-created recipes were not deleted.`);
  } finally { await deleteApp(app); }
}
main().catch((error) => { console.error(error.message); process.exitCode = 1; });
