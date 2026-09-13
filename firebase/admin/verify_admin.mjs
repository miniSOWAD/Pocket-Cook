import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

function readProjectId(args) {
  const equalsArg = args.find((value) => value.startsWith('--project='));
  if (equalsArg) return equalsArg.slice('--project='.length).trim();
  const index = args.indexOf('--project');
  if (index >= 0 && args[index + 1] && !args[index + 1].startsWith('--')) return args[index + 1].trim();
  const positional = args.find((value) => !value.startsWith('--'));
  return positional?.trim() || process.env.GCLOUD_PROJECT?.trim() || process.env.GOOGLE_CLOUD_PROJECT?.trim();
}

const projectId = readProjectId(process.argv.slice(2));
const email = process.env.ADMIN_EMAIL?.trim().toLowerCase();

if (!projectId || !email) {
  console.error('Set ADMIN_EMAIL, then run: node firebase/admin/verify_admin.mjs --project YOUR_PROJECT_ID');
  process.exit(1);
}

initializeApp({ credential: applicationDefault(), projectId });
const auth = getAuth();
const db = getFirestore();

const user = await auth.getUserByEmail(email);
const account = await db.doc(`accounts/${user.uid}`).get();

console.log(`Project: ${projectId}`);
console.log(`UID: ${user.uid}`);
console.log(`Email: ${user.email || ''}`);
console.log(`Auth disabled: ${user.disabled}`);
console.log(`Auth claim role: ${user.customClaims?.role ?? '(missing)'}`);
console.log(`Firestore account exists: ${account.exists}`);
console.log(`Firestore role: ${account.exists ? (account.get('role') ?? '(missing)') : '(missing)'}`);
console.log(`Firestore status: ${account.exists ? (account.get('status') ?? '(missing)') : '(missing)'}`);
console.log(`Firestore displayName: ${account.exists ? (account.get('displayName') ?? '(missing)') : '(missing)'}`);

const healthy = !user.disabled
  && user.customClaims?.role === 'admin'
  && account.exists
  && account.get('role') === 'admin'
  && account.get('status') === 'active';

if (!healthy) {
  console.error('\nADMIN CHECK FAILED. Run bootstrap_admin.mjs again, then deploy the current Firestore rules.');
  process.exit(2);
}
console.log('\nADMIN CHECK PASSED.');
