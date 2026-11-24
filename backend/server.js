'use strict';

try { require('dotenv').config(); } catch (_) {}

const express = require('express');
const cors = require('cors');
const { initializeApp, cert, getApps } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const rules = require('./lib/rules');

// Initialize Firebase Admin once (safe for both Render and Vercel warm invocations)
if (!getApps().length) {
  if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
    initializeApp({ credential: cert(serviceAccount) });
  } else if (process.env.FIREBASE_SERVICE_ACCOUNT_BASE64) {
    const decoded = Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_BASE64, 'base64').toString('utf8');
    initializeApp({ credential: cert(JSON.parse(decoded)) });
  } else {
    // Falls back to GOOGLE_APPLICATION_CREDENTIALS file path if set locally
    initializeApp();
  }
}

const db = getFirestore();
const auth = getAuth();
const app = express();

app.use(cors({ origin: true }));
app.use(express.json({ limit: '32kb' }));

const HOUR_MS = 60 * 60 * 1000;

/** Verifies the Firebase ID token sent by the Flutter app. */
async function requireUser(req, res, next) {
  const header = req.headers.authorization || '';
  const match = header.match(/^Bearer\s+(.+)$/i);
  if (!match) {
    return res.status(401).json({ error: 'Sign in first.' });
  }
  try {
    const decoded = await auth.verifyIdToken(match[1]);
    req.uid = decoded.uid;
    return next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired session.' });
  }
}

app.get(['/', '/health'], (_req, res) => {
  res.json({ ok: true, service: 'scamouflage-backend' });
});

/**
 * Step 1 of a ranked run: issues a one-time run ticket and records start time.
 */
app.post(['/api/startRun', '/startRun'], requireUser, async (req, res) => {
  try {
    const uid = req.uid;
    const { mode, difficulty } = req.body || {};
    if (!rules.MODES.includes(mode) || !rules.DIFFICULTIES.includes(difficulty)) {
      return res.status(400).json({ error: 'Unknown mode or difficulty.' });
    }

    const rateRef = db.collection('rate').doc(uid);
    const runRef = db.collection('runs').doc();

    await db.runTransaction(async (tx) => {
      const snap = await tx.get(rateRef);
      const now = Date.now();
      let { windowStart, count } = snap.data() || {};
      if (!windowStart || now - windowStart > HOUR_MS) {
        windowStart = now;
        count = 0;
      }
      if (count >= rules.MAX_RUNS_PER_HOUR) {
        const err = new Error('Too many runs. Try again later.');
        err.status = 429;
        throw err;
      }
      tx.set(rateRef, { windowStart, count: count + 1 });
      tx.set(runRef, {
        uid,
        mode,
        difficulty,
        status: 'open',
        startedMs: now,
        startedAt: FieldValue.serverTimestamp(),
      });
    });

    return res.json({ runId: runRef.id });
  } catch (err) {
    const status = err.status || 500;
    return res.status(status).json({ error: err.message || 'Server error.' });
  }
});

/**
 * Step 2: validates the finished run ticket, elapsed time, and score plausibility,
 * then writes the leaderboard entries via Admin SDK.
 */
app.post(['/api/submitRun', '/submitRun'], requireUser, async (req, res) => {
  try {
    const uid = req.uid;
    const claim = req.body || {};
    if (typeof claim.runId !== 'string' || claim.runId.length < 5 || claim.runId.includes('/')) {
      return res.status(400).json({ error: 'Missing run ticket.' });
    }

    const userSnap = await db.collection('users').doc(uid).get();
    const username = userSnap.get('username');
    if (!username) {
      return res.status(400).json({ error: 'Choose a username first.' });
    }

    const runRef = db.collection('runs').doc(claim.runId);
    const result = await db.runTransaction(async (tx) => {
      const run = await tx.get(runRef);
      if (!run.exists || run.get('uid') !== uid) {
        const err = new Error('Unknown run ticket.');
        err.status = 404;
        throw err;
      }
      if (run.get('status') !== 'open') {
        const err = new Error('This run was already submitted.');
        err.status = 409;
        throw err;
      }

      const mode = run.get('mode');
      const difficulty = run.get('difficulty');
      const now = Date.now();
      const verdict = rules.validateRun(
        { difficulty, elapsedMs: now - run.get('startedMs') },
        claim,
      );

      const boards = ['allTime', 'weekly'].map((period) => ({
        period,
        ref: db
          .collection('leaderboards')
          .doc(rules.boardId(period === 'weekly' ? 'weekly' : 'all', mode, difficulty, now))
          .collection('entries')
          .doc(uid),
      }));

      const existing = verdict.ok
        ? await Promise.all(boards.map((b) => tx.get(b.ref)))
        : [];

      // Close the ticket regardless so rejected runs cannot be replayed
      tx.update(runRef, {
        status: verdict.ok ? 'accepted' : 'rejected',
        reason: verdict.reason || null,
        claimedScore: Number.isFinite(claim.score) ? claim.score : null,
        closedAt: FieldValue.serverTimestamp(),
      });

      if (!verdict.ok) return verdict;

      boards.forEach((b, i) => {
        const best = existing[i].get('score') || 0;
        if (claim.score > best) {
          tx.set(b.ref, {
            uid,
            username,
            mode,
            difficulty,
            score: claim.score,
            period: b.period,
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
      });

      return verdict;
    });

    if (!result.ok) {
      return res.status(400).json({ error: result.reason });
    }
    return res.json({ accepted: true });
  } catch (err) {
    const status = err.status || 500;
    return res.status(status).json({ error: err.message || 'Server error.' });
  }
});

/**
 * Cloud Save: validates XP progression, unlocks, cosmetics, and stats, merges
 * with stored data, and returns the authoritative player profile.
 */
app.post(['/api/syncProfile', '/syncProfile'], requireUser, async (req, res) => {
  try {
    const uid = req.uid;
    const { mode, profile } = req.body || {};
    if (mode !== 'merge' && mode !== 'adopt') {
      return res.status(400).json({ error: 'Bad sync mode.' });
    }

    const ref = db.collection('players').doc(uid);
    const out = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      const now = Date.now();
      const result = rules.mergeProfile(snap.exists ? snap.data() : null, profile, { mode, now });
      if (result.write) {
        tx.set(ref, {
          ...result.profile,
          lastSyncMs: now,
          flagged: result.flagged === true,
          updatedAt: FieldValue.serverTimestamp(),
        });
      }
      return result.profile;
    });

    return res.json({ profile: out });
  } catch (err) {
    const status = err.status || 500;
    return res.status(status).json({ error: err.message || 'Server error.' });
  }
});

if (require.main === module) {
  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`Scamouflage backend listening on port ${port}`);
  });
}

module.exports = app;