import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

function readProjectId(args) {
  const equalsArg = args.find((value) => value.startsWith('--project='));
  if (equalsArg) return equalsArg.slice('--project='.length).trim();

  const projectIndex = args.indexOf('--project');
  if (projectIndex >= 0 && args[projectIndex + 1] && !args[projectIndex + 1].startsWith('--')) {
    return args[projectIndex + 1].trim();
  }

  // npm on some Windows setups can forward `npm run ... -- --project ID`
  // as only the positional project ID. Accept that form as well.
  const positional = args.find((value) => !value.startsWith('--'));
  return positional?.trim() || process.env.GCLOUD_PROJECT?.trim() || process.env.GOOGLE_CLOUD_PROJECT?.trim();
}

const args = process.argv.slice(2);
const projectId = readProjectId(args);
const email = process.env.ADMIN_EMAIL?.trim().toLowerCase();
const password = process.env.ADMIN_PASSWORD;
const displayName = process.env.ADMIN_NAME?.trim() || 'Liza Kitchen Admin';

if (!projectId || !email || !password) {
  console.error('Usage: set ADMIN_EMAIL and ADMIN_PASSWORD, then run:');
  console.error('  node firebase/admin/bootstrap_admin.mjs --project YOUR_PROJECT_ID');
  console.error('or set GCLOUD_PROJECT and run the script without arguments.');
  process.exit(1);
}
if (password.length < 8) {
  console.error('ADMIN_PASSWORD must be at least 8 characters.');
  process.exit(1);
}

initializeApp({ credential: applicationDefault(), projectId });
const auth = getAuth();
const db = getFirestore();
let user;

try {
  user = await auth.getUserByEmail(email);
  user = await auth.updateUser(user.uid, {
    email,
    password,
    displayName,
    disabled: false,
  });
  console.log(`Updated existing Firebase Auth user ${user.uid}.`);
} catch (error) {
  if (error?.code !== 'auth/user-not-found') throw error;
  user = await auth.createUser({ email, password, displayName, disabled: false });
  console.log(`Created Firebase Auth user ${user.uid}.`);
}

await auth.setCustomUserClaims(user.uid, {
  ...(user.customClaims || {}),
  role: 'admin',
});

const accountRef = db.doc(`accounts/${user.uid}`);
const existingAccount = await accountRef.get();
const now = Date.now();
await accountRef.set({
  displayName,
  photoUrl: existingAccount.exists
      ? (existingAccount.get('photoUrl') || user.photoURL || '')
      : (user.photoURL || ''),
  role: 'admin',
  status: 'active',
  createdAt: existingAccount.exists
      ? (existingAccount.get('createdAt') || (user.metadata.creationTime ? Date.parse(user.metadata.creationTime) : now))
      : (user.metadata.creationTime ? Date.parse(user.metadata.creationTime) : now),
  updatedAt: now,
}, { merge: true });

const profileRef = db.doc(`users/${user.uid}`);
const profile = await profileRef.get();
await profileRef.set({
  displayName,
  ...(profile.exists ? {} : { bio: '' }),
  updatedAt: now,
}, { merge: true });

// Read both sources back so the command cannot report success while the
// database still says Visitor.
const [verifiedUser, verifiedAccount] = await Promise.all([
  auth.getUser(user.uid),
  accountRef.get(),
]);
const firestoreRole = verifiedAccount.get('role');
const firestoreStatus = verifiedAccount.get('status');
const claimRole = verifiedUser.customClaims?.role;

if (firestoreRole !== 'admin' || firestoreStatus !== 'active' || claimRole !== 'admin') {
  console.error('Admin verification failed after writing the account.');
  console.error(`Auth custom claim role: ${claimRole ?? '(missing)'}`);
  console.error(`Firestore role: ${firestoreRole ?? '(missing)'}`);
  console.error(`Firestore status: ${firestoreStatus ?? '(missing)'}`);
  process.exit(2);
}

console.log(`Admin ready: ${email} (${user.uid}) in project ${projectId}.`);
console.log('Verified Auth claim: role=admin');
console.log('Verified Firestore account: role=admin, status=active');
console.log('If the browser was already signed in, sign out and sign in once so its Firebase ID token refreshes.');
