'use strict';

// ---------------------------------------------------------------- constants
const MODES = ['mix', 'trust', 'impostor', 'scamSlam', 'rumor', 'inbox', 'comments', 'clip'];
const DIFFICULTIES = ['easy', 'medium', 'hard'];
const DIFFICULTY_BONUS = { easy: 0, medium: 10, hard: 20 }; // ArcadeDifficulty.bonusXp

// Leaderboard runs
const MAX_ROUNDS = 400;
const MIN_MS_PER_ROUND = 3000;
const GRACE_MS = 5000;
const MAX_RUN_MS = 6 * 60 * 60 * 1000;
const MAX_RUNS_PER_HOUR = 60;

// Cloud save
const MAX_FIRST_SYNC_XP = 5000;
const MAX_XP_PER_SECOND = 10;
const XP_BURST = 300;
const MIN_SYNC_GAP_MS = 5000;
const SHIFT_SECONDS = 20;

// [id, xp needed] -- mirrors CareerProgression in player_progression.dart
const RANKS = [
  ['rookie', 0], ['link_sleuth', 150], ['scam_detective', 400], ['fact_finder', 850],
  ['source_scout', 1400], ['newsroom_analyst', 2300], ['verification_expert', 3600],
  ['digital_sentinel', 5200], ['cyber_guardian', 7400], ['truth_legend', 10000],
];
const BADGES = [
  ['chameleon', 0], ['magnifier', 200], ['shield', 500], ['newspaper', 1000],
  ['spark', 1800], ['trophy', 3200],
];
const FRAMES = [
  ['classic', 0], ['sunny', 300], ['bubblegum', 700], ['mint', 1300], ['violet', 2600], ['gold', 9500],
];
const MASCOT_NAMES = [
  ['chameleo', 0], ['checks', 150], ['linky', 400], ['factgecko', 850], ['receipts', 1400],
  ['pixel', 2300], ['nootp', 3600], ['clicklock', 5200], ['hiss', 7400], ['truth', 10000],
];
const MASCOT_COLORS = [
  ['mint', 0], ['sky', 150], ['rose', 400], ['sunny', 700], ['violet', 1000],
  ['pink', 1600], ['teal', 2600], ['ice', 3800], ['ember', 6000], ['gold', 9500],
];

// ------------------------------------------------------------------ helpers
const pad = (n) => String(n).padStart(2, '0');
const isInt = (v) => Number.isInteger(v);
const nonNegInt = (v) =>
  Number.isFinite(v) ? Math.min(1e9, Math.max(0, Math.floor(v))) : 0;
const clamp = (v, lo, hi) => Math.min(hi, Math.max(lo, v));
const obj = (v) => (v && typeof v === 'object' && !Array.isArray(v) ? v : {});

// ------------------------------------------------------------- board keys
function weekKey(nowMs = Date.now()) {
  const ph = new Date(nowMs + 8 * 3600 * 1000);
  const day = Date.UTC(ph.getUTCFullYear(), ph.getUTCMonth(), ph.getUTCDate());
  const sinceMonday = (new Date(day).getUTCDay() + 6) % 7;
  const monday = new Date(day - sinceMonday * 86400000);
  return `${monday.getUTCFullYear()}-${pad(monday.getUTCMonth() + 1)}-${pad(monday.getUTCDate())}`;
}

function boardId(period, mode, difficulty, nowMs = Date.now()) {
  return period === 'weekly'
    ? `week_${weekKey(nowMs)}_${mode}_${difficulty}`
    : `all_${mode}_${difficulty}`;
}

// ------------------------------------------------------------- run checks
function maxRunScore(difficulty, rounds, correct) {
  const perCorrect = 72 + DIFFICULTY_BONUS[difficulty];
  return correct * perCorrect + (rounds - correct) * Math.floor(perCorrect / 2);
}

const reject = (reason) => ({ ok: false, reason });

function validateRun(run, claim) {
  const c = obj(claim);
  const { score, rounds, correct, bestStreak } = c;
  if (![score, rounds, correct, bestStreak].every(isInt)) return reject('Malformed run.');
  if (!DIFFICULTIES.includes(run.difficulty)) return reject('Unknown difficulty.');
  if (rounds < 1 || rounds > MAX_ROUNDS) return reject('Implausible number of rounds.');
  if (correct < 0 || correct > rounds) return reject('Correct answers exceed rounds.');
  if (bestStreak < 0 || bestStreak > correct) return reject('Streak exceeds correct answers.');
  if (score < 1) return reject('No score to submit.');
  if (score > maxRunScore(run.difficulty, rounds, correct)) {
    return reject('Score is higher than this run allows.');
  }
  if (run.elapsedMs < rounds * MIN_MS_PER_ROUND - GRACE_MS) {
    return reject('Run was completed too quickly.');
  }
  if (run.elapsedMs > MAX_RUN_MS) return reject('Run ticket expired.');
  return { ok: true };
}

// ----------------------------------------------------------- player profile
const unlockedIds = (table, xp) => table.filter(([, need]) => xp >= need).map(([id]) => id);
const levelFor = (xp) => Math.max(1, unlockedIds(RANKS, xp).length);

function pickEquipped(id, table, xp, fallback) {
  const row = table.find(([known]) => known === id);
  return row && xp >= row[1] ? id : fallback;
}

function sanitize(raw) {
  const p = obj(raw);
  const eq = obj(p.equipped);
  const fl = obj(p.flags);
  const st = obj(p.stats);
  const careerXp = nonNegInt(p.careerXp);
  const completedShifts = nonNegInt(p.completedShifts);
  const rounds = nonNegInt(st.rounds);
  const correct = Math.min(nonNegInt(st.correct), rounds);
  return {
    careerXp,
    completedShifts,
    unlockedShift: clamp(nonNegInt(p.unlockedShift) || 1, 1, Math.min(7, 1 + completedShifts)),
    safety: clamp(isInt(p.safety) ? p.safety : 80, 0, 100),
    fairness: clamp(isInt(p.fairness) ? p.fairness : 80, 0, 100),
    hintsUsed: nonNegInt(p.hintsUsed),
    equipped: {
      title: pickEquipped(eq.title, RANKS, careerXp, 'rookie'),
      badge: pickEquipped(eq.badge, BADGES, careerXp, 'chameleon'),
      frame: pickEquipped(eq.frame, FRAMES, careerXp, 'classic'),
      mascotName: pickEquipped(eq.mascotName, MASCOT_NAMES, careerXp, 'chameleo'),
      mascotColor: pickEquipped(eq.mascotColor, MASCOT_COLORS, careerXp, 'mint'),
    },
    flags: {
      tutorialFinished: fl.tutorialFinished === true,
      arcadeIntroFinished: fl.arcadeIntroFinished === true,
      mascotIntroduced: fl.mascotIntroduced === true,
    },
    stats: {
      runs: nonNegInt(st.runs),
      rounds,
      correct,
      bestStreak: Math.min(nonNegInt(st.bestStreak), correct),
      bestRunScore: nonNegInt(st.bestRunScore),
    },
  };
}

function withDerived(profile) {
  const xp = profile.careerXp;
  return {
    ...profile,
    level: levelFor(xp),
    unlocked: {
      ranks: unlockedIds(RANKS, xp),
      badges: unlockedIds(BADGES, xp),
      frames: unlockedIds(FRAMES, xp),
      mascotNames: unlockedIds(MASCOT_NAMES, xp),
      mascotColors: unlockedIds(MASCOT_COLORS, xp),
    },
  };
}

function mergeProfile(stored, incoming, { mode, now }) {
  const inc = sanitize(incoming);

  if (!stored) {
    // If another account previously used this device, start the new account fresh
    if (mode === 'adopt') {
      return { profile: withDerived(sanitize({})), write: true, flagged: false };
    }
    const xp = Math.min(inc.careerXp, MAX_FIRST_SYNC_XP);
    const first = sanitize({ ...inc, careerXp: xp });
    return { profile: withDerived(first), write: true, flagged: inc.careerXp > xp };
  }

  const cur = sanitize(stored);
  const lastSync = Number.isFinite(stored.lastSyncMs) ? stored.lastSyncMs : 0;
  const sinceMs = now - lastSync;
  if (mode === 'adopt' || sinceMs < MIN_SYNC_GAP_MS) {
    return { profile: withDerived(cur), write: false, flagged: false };
  }

  const seconds = Math.max(1, sinceMs / 1000);
  const xpBudget = Math.floor(MAX_XP_PER_SECOND * seconds) + XP_BURST;
  const wantedXp = Math.max(cur.careerXp, inc.careerXp);
  const careerXp = Math.min(wantedXp, cur.careerXp + xpBudget);

  const shiftBudget = Math.floor(seconds / SHIFT_SECONDS) + 2;
  const completedShifts = Math.min(
    Math.max(cur.completedShifts, inc.completedShifts),
    cur.completedShifts + shiftBudget,
  );

  const leader = inc.careerXp >= cur.careerXp ? inc : cur;
  const maxStat = (key) => Math.max(cur.stats[key], inc.stats[key]);

  const merged = sanitize({
    careerXp,
    completedShifts,
    unlockedShift: Math.max(cur.unlockedShift, inc.unlockedShift),
    safety: leader.safety,
    fairness: leader.fairness,
    hintsUsed: Math.max(cur.hintsUsed, inc.hintsUsed),
    equipped: leader.equipped,
    flags: {
      tutorialFinished: cur.flags.tutorialFinished || inc.flags.tutorialFinished,
      arcadeIntroFinished: cur.flags.arcadeIntroFinished || inc.flags.arcadeIntroFinished,
      mascotIntroduced: cur.flags.mascotIntroduced || inc.flags.mascotIntroduced,
    },
    stats: {
      runs: maxStat('runs'),
      rounds: maxStat('rounds'),
      correct: maxStat('correct'),
      bestStreak: maxStat('bestStreak'),
      bestRunScore: maxStat('bestRunScore'),
    },
  });
  return {
    profile: withDerived(merged),
    write: true,
    flagged: wantedXp > careerXp || inc.completedShifts > completedShifts,
  };
}

module.exports = {
  MODES, DIFFICULTIES, MAX_RUNS_PER_HOUR, MAX_FIRST_SYNC_XP,
  weekKey, boardId, maxRunScore, validateRun,
  sanitize, withDerived, levelFor, mergeProfile,
};