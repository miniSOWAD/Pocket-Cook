const { onCall, HttpsError } = require('firebase-functions/https');
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore } = require('firebase-admin/firestore');

initializeApp();
const auth = getAuth();
const db = getFirestore();

const roles = new Set(['admin', 'cook', 'visitor']);

async function requireAdmin(request) {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Sign in first.');
  const account = await db.doc(`accounts/${uid}`).get();
  if (!account.exists || account.get('role') !== 'admin' || account.get('status') !== 'active') {
    throw new HttpsError('permission-denied', 'Admin access required.');
  }
  return uid;
}

function requiredString(value, name, max = 200) {
  if (typeof value !== 'string' || value.trim().length === 0 || value.trim().length > max) {
    throw new HttpsError('invalid-argument', `${name} is invalid.`);
  }
  return value.trim();
}

function parseRole(value) {
  if (typeof value !== 'string' || !roles.has(value)) {
    throw new HttpsError('invalid-argument', 'Unknown role.');
  }
  return value;
}

async function accountForUser(user) {
  const ref = db.doc(`accounts/${user.uid}`);
  const snapshot = await ref.get();
  if (!snapshot.exists) {
    const now = Date.now();
    const record = {
      displayName: user.displayName || 'Home cook',
      photoUrl: user.photoURL || '',
      role: 'visitor',
      status: user.disabled ? 'blocked' : 'active',
      createdAt: user.metadata.creationTime ? Date.parse(user.metadata.creationTime) : now,
      updatedAt: now,
    };
    await ref.set(record);
    return record;
  }
  const existing = snapshot.data();
  if (user.disabled && existing.status !== 'blocked') {
    const updated = { ...existing, status: 'blocked', updatedAt: Date.now() };
    await ref.set({ status: 'blocked', updatedAt: updated.updatedAt }, { merge: true });
    return updated;
  }
  return existing;
}

exports.adminListUsers = onCall(async (request) => {
  await requireAdmin(request);
  const users = [];
  let pageToken;
  do {
    const page = await auth.listUsers(1000, pageToken);
    for (const user of page.users) {
      const account = await accountForUser(user);
      users.push({
        uid: user.uid,
        email: user.email || '',
        displayName: account.displayName || user.displayName || 'Home cook',
        photoUrl: account.photoUrl || user.photoURL || '',
        role: roles.has(account.role) ? account.role : 'visitor',
        status: user.disabled || account.status === 'blocked' ? 'blocked' : 'active',
        createdAt: account.createdAt || (user.metadata.creationTime ? Date.parse(user.metadata.creationTime) : 0),
      });
    }
    pageToken = page.pageToken;
  } while (pageToken);
  return { users };
});

exports.adminCreateUser = onCall(async (request) => {
  await requireAdmin(request);
  const email = requiredString(request.data?.email, 'Email', 320).toLowerCase();
  const displayName = requiredString(request.data?.displayName, 'Display name', 60);
  const password = requiredString(request.data?.password, 'Password', 200);
  const role = parseRole(request.data?.role);
  if (password.length < 8) throw new HttpsError('invalid-argument', 'Password must be at least 8 characters.');

  let created;
  try {
    created = await auth.createUser({ email, password, displayName, disabled: false });
    await auth.setCustomUserClaims(created.uid, { role });
    const now = Date.now();
    await db.doc(`accounts/${created.uid}`).set({
      displayName,
      photoUrl: '',
      role,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    });
    await db.doc(`users/${created.uid}`).set({
      displayName,
      bio: '',
      updatedAt: now,
    }, { merge: true });
  } catch (error) {
    if (created?.uid) await auth.deleteUser(created.uid).catch(() => {});
    if (error?.code === 'auth/email-already-exists') {
      throw new HttpsError('already-exists', 'An account already uses that email.');
    }
    throw error;
  }
  return { uid: created.uid };
});

exports.adminDeleteUser = onCall(async (request) => {
  const adminUid = await requireAdmin(request);
  const uid = requiredString(request.data?.uid, 'User ID', 128);
  if (uid === adminUid) throw new HttpsError('failed-precondition', 'You cannot delete the account you are currently using.');

  // Disable first, then leave a blocked account tombstone. Firebase ID tokens
  // may remain usable briefly after Auth deletion; the tombstone makes Firestore
  // rules deny that stale token instead of treating the UID as a first-time user.
  const existingUser = await auth.getUser(uid);
  await accountForUser(existingUser);
  await auth.updateUser(uid, { disabled: true });
  await auth.revokeRefreshTokens(uid);
  await db.recursiveDelete(db.doc(`users/${uid}`)).catch(() => {});
  await db.doc(`cookApplications/${uid}`).delete().catch(() => {});
  await db.doc(`accounts/${uid}`).set({
    displayName: 'Deleted user',
    photoUrl: '',
    role: 'visitor',
    status: 'blocked',
    updatedAt: Date.now(),
  }, { merge: true });
  await auth.deleteUser(uid);
  return { ok: true };
});

exports.adminSetUserBlocked = onCall(async (request) => {
  const adminUid = await requireAdmin(request);
  const uid = requiredString(request.data?.uid, 'User ID', 128);
  const blocked = request.data?.blocked;
  if (typeof blocked !== 'boolean') throw new HttpsError('invalid-argument', 'Blocked must be true or false.');
  if (uid === adminUid && blocked) throw new HttpsError('failed-precondition', 'You cannot block the account you are currently using.');

  const existingUser = await auth.getUser(uid);
  await accountForUser(existingUser);
  await auth.updateUser(uid, { disabled: blocked });
  if (blocked) await auth.revokeRefreshTokens(uid);
  await db.doc(`accounts/${uid}`).set({
    status: blocked ? 'blocked' : 'active',
    updatedAt: Date.now(),
  }, { merge: true });
  return { ok: true };
});

exports.adminSetUserRole = onCall(async (request) => {
  const adminUid = await requireAdmin(request);
  const uid = requiredString(request.data?.uid, 'User ID', 128);
  const role = parseRole(request.data?.role);
  if (uid === adminUid && role !== 'admin') {
    throw new HttpsError('failed-precondition', 'You cannot demote the Admin account you are currently using.');
  }

  const user = await auth.getUser(uid);
  await accountForUser(user);
  await auth.setCustomUserClaims(uid, { ...(user.customClaims || {}), role });
  await db.doc(`accounts/${uid}`).set({ role, updatedAt: Date.now() }, { merge: true });
  return { ok: true };
});

exports.adminReviewCookApplication = onCall(async (request) => {
  await requireAdmin(request);
  const uid = requiredString(request.data?.uid, 'User ID', 128);
  const approve = request.data?.approve;
  if (typeof approve !== 'boolean') throw new HttpsError('invalid-argument', 'Approve must be true or false.');

  const applicationRef = db.doc(`cookApplications/${uid}`);
  const application = await applicationRef.get();
  if (!application.exists || application.get('status') !== 'pending') {
    throw new HttpsError('failed-precondition', 'This Cook request is no longer pending.');
  }

  if (approve) {
    const user = await auth.getUser(uid);
    await auth.setCustomUserClaims(uid, { ...(user.customClaims || {}), role: 'cook' });
    await db.doc(`accounts/${uid}`).set({ role: 'cook', status: 'active', updatedAt: Date.now() }, { merge: true });
  }
  await applicationRef.set({
    status: approve ? 'approved' : 'rejected',
    reviewedAt: Date.now(),
  }, { merge: true });
  return { ok: true };
});
