import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/generator.dart';
import '../models/models.dart';
import '../models/player_progression.dart';

/// Game state is shared by Android, iOS and web. No networking is required.
class GameEngine extends ChangeNotifier {
  bool ready = false;
  bool tutorialFinished = false;
  bool arcadeIntroFinished = false;
  bool haptics = true;
  int unlockedShift = 1;
  int careerXp = 0;
  String equippedTitleId = CareerProgression.ranks.first.id;
  String equippedBadgeId = CareerProgression.badges.first.id;
  String equippedFrameId = CareerProgression.frames.first.id;
  String equippedMascotNameId = CareerProgression.mascotNames.first.id;
  String equippedMascotColorId = CareerProgression.mascotColors.first.id;
  bool mascotIntroduced = false;
  final List<int> _pendingLevelUps = [];
  String get mascotName => CareerProgression.mascotNameById(equippedMascotNameId)?.name ?? 'ChameLeo';
  int? takeLevelUp() {
    _pendingLevelUps.removeWhere((level) => level > careerRank.level);
    if (_pendingLevelUps.isEmpty) return null;
    final highest = _pendingLevelUps.last;
    _pendingLevelUps.clear();
    return highest;
  }
  Future<void> introduceMascot() async {
    mascotIntroduced = true;
    notifyListeners();
    await _save();
  }
  bool equipMascotName(String id) {
    final choice = CareerProgression.mascotNameById(id);
    if (choice == null || choice.xp > careerXp) return false;
    equippedMascotNameId = id;
    notifyListeners();
    _save();
    return true;
  }
  bool equipMascotColor(String id) {
    final choice = CareerProgression.mascotColorById(id);
    if (choice == null || choice.xp > careerXp) return false;
    equippedMascotColorId = id;
    notifyListeners();
    _save();
    return true;
  }
  CareerRank get careerRank => CareerProgression.rankAt(careerXp);
  CareerRank? get nextCareerRank => CareerProgression.nextRank(careerXp);
  double get careerLevelProgress => CareerProgression.levelProgress(careerXp);
  String get equippedTitle =>
      CareerProgression.rankById(equippedTitleId)?.title ?? careerRank.title;

  bool equipCareerTitle(String id) {
    final choice = CareerProgression.rankById(id);
    if (choice == null || choice.xp > careerXp) return false;
    equippedTitleId = id;
    notifyListeners();
    _save();
    return true;
  }

  bool equipBadge(String id) {
    final choice = CareerProgression.badgeById(id);
    if (choice == null || choice.xp > careerXp) return false;
    equippedBadgeId = id;
    notifyListeners();
    _save();
    return true;
  }

  bool equipFrame(String id) {
    final choice = CareerProgression.frameById(id);
    if (choice == null || choice.xp > careerXp) return false;
    equippedFrameId = id;
    notifyListeners();
    _save();
    return true;
  }
  int hintsUsed = 0;
  /// One free starter hint, then one new hint for each 50 career XP earned.
  int get hintsAvailable => max<int>(0, 1 + careerXp ~/ 50 - hintsUsed);

  bool spendHint() {
    if (hintsAvailable == 0) return false;
    hintsUsed++;
    _save();
    notifyListeners();
    return true;
  }
  /// Maintain current earned rank automatically unless the player explicitly
  /// equipped an earlier title for style. Existing Career Shifts remain separate.
  void _earnCareerXp(int points) {
    if (points <= 0) return;
    final oldRankId = careerRank.id;
    final oldLevel = careerRank.level;
    careerXp += points;
    for (var level = oldLevel + 1; level <= careerRank.level; level++) {
      _pendingLevelUps.add(level);
    }
    if (equippedTitleId == oldRankId) {
      equippedTitleId = careerRank.id;
    }
  }

  int safety = 80;
  int fairness = 80;
  int completedShifts = 0;
  int shiftNumber = 1;
  int shiftXp = 0;
  int correctCount = 0;
  int mistakes = 0;
  int currentIndex = 0;
  int runSeed = 0;
  int credits = 6;
  int tutorialStep = 0;
  Mode mode = Mode.career;
  String modifier = 'SOURCE SWAP';
  List<PlayCase> queue = [];
  final Set<String> revealed = {};
  final Map<String,EvidenceTag> tags = {};
  final List<ReviewResult> results = [];
  Set<String> recent = {};
  final List<Map<String,dynamic>> callbacks = [];
  final Map<String,int> principlesSeen = {};
  final Map<String,int> principlesCorrect = {};
  /// Recent arcade archetypes, kept across sessions to reduce repetition.
  final List<String> arcadeHistory = [];
  bool verifiedSource = false;
  bool finished = false;
  ReviewResult? pendingResult;

  PlayCase get currentCase => queue[currentIndex];
  bool get inShift => queue.isNotEmpty && !finished;
  bool get canPlayEndless => unlockedShift >= 7;
  bool get isTraining => mode == Mode.training;
  double get accuracy => results.isEmpty ? 1 : correctCount / results.length;
  String get grade {
    if (accuracy >= .92 && safety >= 65 && fairness >= 65) return 'S';
    if (accuracy >= .78 && safety >= 55 && fairness >= 55) return 'A';
    if (accuracy >= .65 && safety >= 45 && fairness >= 45) return 'B';
    return 'C';
  }
  bool get promoted => grade != 'C';

  /// Hook attached by CloudSaveService to debounce background cloud syncs.
  VoidCallback? onSaved;

  /// Lifetime arcade stats synced with the player's cloud save.
  final Map<String, int> stats = {
    'runs': 0,
    'rounds': 0,
    'correct': 0,
    'bestStreak': 0,
    'bestRunScore': 0,
  };

  void recordRun({
    required int rounds,
    required int correct,
    required int bestStreak,
    required int score,
  }) {
    if (rounds <= 0) return;
    stats['runs'] = (stats['runs'] ?? 0) + 1;
    stats['rounds'] = (stats['rounds'] ?? 0) + rounds;
    stats['correct'] = (stats['correct'] ?? 0) + correct;
    stats['bestStreak'] = max(stats['bestStreak'] ?? 0, bestStreak);
    stats['bestRunScore'] = max(stats['bestRunScore'] ?? 0, score);
    notifyListeners();
    _save();
  }

  Map<String, dynamic> toCloud() => {
        'careerXp': careerXp,
        'completedShifts': completedShifts,
        'unlockedShift': unlockedShift,
        'safety': safety,
        'fairness': fairness,
        'hintsUsed': hintsUsed,
        'equipped': {
          'title': equippedTitleId,
          'badge': equippedBadgeId,
          'frame': equippedFrameId,
          'mascotName': equippedMascotNameId,
          'mascotColor': equippedMascotColorId,
        },
        'flags': {
          'tutorialFinished': tutorialFinished,
          'arcadeIntroFinished': arcadeIntroFinished,
          'mascotIntroduced': mascotIntroduced,
        },
        'stats': Map<String, int>.from(stats),
      };

  /// Cosmetics unlock by XP. When the account's XP is lower than what this
  /// device had (for example the server corrected an invalid value, or the
  /// device switched accounts), fall back to the default for any equipped
  /// item that is no longer unlocked.
  void _resetLockedCosmetics() {
    bool locked(int? unlockXp) => (unlockXp ?? 999999) > careerXp;
    if (locked(CareerProgression.rankById(equippedTitleId)?.xp)) {
      equippedTitleId = careerRank.id;
    }
    if (locked(CareerProgression.badgeById(equippedBadgeId)?.xp)) {
      equippedBadgeId = CareerProgression.badges.first.id;
    }
    if (locked(CareerProgression.frameById(equippedFrameId)?.xp)) {
      equippedFrameId = CareerProgression.frames.first.id;
    }
    if (locked(CareerProgression.mascotNameById(equippedMascotNameId)?.xp)) {
      equippedMascotNameId = CareerProgression.mascotNames.first.id;
    }
    if (locked(CareerProgression.mascotColorById(equippedMascotColorId)?.xp)) {
      equippedMascotColorId = CareerProgression.mascotColors.first.id;
    }
  }

  Future<void> applyCloud(Map<String, dynamic> data) async {
    int readInt(dynamic v, int fallback) => v is num ? v.toInt() : fallback;

    careerXp = max(0, readInt(data['careerXp'], careerXp));
    _pendingLevelUps.removeWhere((level) => level > careerRank.level);
    completedShifts = max(0, readInt(data['completedShifts'], completedShifts));
    unlockedShift = readInt(data['unlockedShift'], unlockedShift).clamp(1, 7).toInt();
    safety = readInt(data['safety'], safety).clamp(0, 100).toInt();
    fairness = readInt(data['fairness'], fairness).clamp(0, 100).toInt();
    hintsUsed = max(0, readInt(data['hintsUsed'], hintsUsed));

    final eq = data['equipped'];
    if (eq is Map) {
      final title = eq['title']?.toString();
      if (title != null && (CareerProgression.rankById(title)?.xp ?? 999999) <= careerXp) {
        equippedTitleId = title;
      }
      final badge = eq['badge']?.toString();
      if (badge != null && (CareerProgression.badgeById(badge)?.xp ?? 999999) <= careerXp) {
        equippedBadgeId = badge;
      }
      final frame = eq['frame']?.toString();
      if (frame != null && (CareerProgression.frameById(frame)?.xp ?? 999999) <= careerXp) {
        equippedFrameId = frame;
      }
      final mName = eq['mascotName']?.toString();
      if (mName != null && (CareerProgression.mascotNameById(mName)?.xp ?? 999999) <= careerXp) {
        equippedMascotNameId = mName;
      }
      final mColor = eq['mascotColor']?.toString();
      if (mColor != null && (CareerProgression.mascotColorById(mColor)?.xp ?? 999999) <= careerXp) {
        equippedMascotColorId = mColor;
      }
    }

    _resetLockedCosmetics();

    final fl = data['flags'];
    if (fl is Map) {
      if (fl['tutorialFinished'] is bool) {
        tutorialFinished = fl['tutorialFinished'] as bool;
      }
      if (fl['arcadeIntroFinished'] is bool) {
        arcadeIntroFinished = fl['arcadeIntroFinished'] as bool;
      }
      if (fl['mascotIntroduced'] is bool) {
        mascotIntroduced = fl['mascotIntroduced'] as bool;
      }
    }

    final st = data['stats'];
    if (st is Map) {
      for (final key in stats.keys.toList()) {
        final v = st[key];
        if (v is num) stats[key] = max(0, v.toInt());
      }
    }

    notifyListeners();
    await _save(notifyCloud: false);
  }

  /// Resets local progress on screen when signing out (does not touch cloud data).
  Future<void> resetLocalProgress() async {
    unlockedShift = 1;
    careerXp = 0;
    equippedTitleId = CareerProgression.ranks.first.id;
    equippedBadgeId = CareerProgression.badges.first.id;
    equippedFrameId = CareerProgression.frames.first.id;
    equippedMascotNameId = CareerProgression.mascotNames.first.id;
    equippedMascotColorId = CareerProgression.mascotColors.first.id;
    hintsUsed = 0;
    safety = 80;
    fairness = 80;
    completedShifts = 0;
    tutorialFinished = false;
    arcadeIntroFinished = false;
    recent.clear();
    arcadeHistory.clear();
    callbacks.clear();
    for (final key in stats.keys.toList()) {
      stats[key] = 0;
    }
    notifyListeners();
    await _save(notifyCloud: false);
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      unlockedShift = (prefs.getInt('level_v4') ?? prefs.getInt('level_v3') ?? 1).clamp(1,7).toInt();
      careerXp = prefs.getInt('xp_v4') ?? prefs.getInt('xp_v3') ?? 0;
      final savedTitle = prefs.getString('cosmetic_title_v1') ?? CareerProgression.ranks.first.id;
      final savedBadge = prefs.getString('cosmetic_badge_v1') ?? CareerProgression.badges.first.id;
      final savedFrame = prefs.getString('cosmetic_frame_v1') ?? CareerProgression.frames.first.id;
      final savedMascotName = prefs.getString('mascot_name_v12') ?? 'chameleo';
      final savedMascotColor = prefs.getString('mascot_color_v12') ?? 'mint';
      mascotIntroduced = prefs.getBool('mascot_intro_v12') ?? false;
      equippedTitleId = (CareerProgression.rankById(savedTitle)?.xp ?? 999999) <= careerXp
          ? savedTitle : CareerProgression.ranks.first.id;
      equippedBadgeId = (CareerProgression.badgeById(savedBadge)?.xp ?? 999999) <= careerXp
          ? savedBadge : CareerProgression.badges.first.id;
      equippedFrameId = (CareerProgression.frameById(savedFrame)?.xp ?? 999999) <= careerXp
          ? savedFrame : CareerProgression.frames.first.id;
      equippedMascotNameId = (CareerProgression.mascotNameById(savedMascotName)?.xp ?? 999999) <= careerXp ? savedMascotName : 'chameleo';
      equippedMascotColorId = (CareerProgression.mascotColorById(savedMascotColor)?.xp ?? 999999) <= careerXp ? savedMascotColor : 'mint';
      hintsUsed = prefs.getInt('hints_used_v8') ?? 0;
      safety = (prefs.getInt('safety_v4') ?? 80).clamp(0,100).toInt();
      fairness = (prefs.getInt('fairness_v4') ?? 80).clamp(0,100).toInt();
      completedShifts = prefs.getInt('shifts_v4') ?? 0;
      tutorialFinished = prefs.getBool('tutorial_v5') ?? false;
      arcadeIntroFinished = prefs.getBool('arcade_intro_v7') ?? false;
      haptics = prefs.getBool('haptics_v4') ?? true;
      recent = (prefs.getStringList('recent_v4') ?? []).toSet();
      arcadeHistory.addAll(prefs.getStringList('arcade_recent_v1') ?? []);
      final stored = prefs.getStringList('callbacks_v4') ?? [];
      callbacks.clear();
      for (final raw in stored) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String,dynamic>) callbacks.add(decoded);
      }
      final rawStats = prefs.getString('stats_v1');
      if (rawStats != null) {
        final decoded = jsonDecode(rawStats);
        if (decoded is Map) {
          for (final key in stats.keys.toList()) {
            final v = decoded[key];
            if (v is num) stats[key] = v.toInt();
          }
        }
      }
    } catch (_) { /* App works without storage on unsupported platforms. */ }
    ready = true;
    notifyListeners();
  }

  Future<void> _save({bool notifyCloud = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('level_v4',unlockedShift);
      await prefs.setInt('xp_v4',careerXp);
      await prefs.setString('cosmetic_title_v1', equippedTitleId);
      await prefs.setString('cosmetic_badge_v1', equippedBadgeId);
      await prefs.setString('cosmetic_frame_v1', equippedFrameId);
      await prefs.setString('mascot_name_v12', equippedMascotNameId);
      await prefs.setString('mascot_color_v12', equippedMascotColorId);
      await prefs.setBool('mascot_intro_v12', mascotIntroduced);
      await prefs.setInt('hints_used_v8',hintsUsed);
      await prefs.setInt('safety_v4',safety);
      await prefs.setInt('fairness_v4',fairness);
      await prefs.setInt('shifts_v4',completedShifts);
      await prefs.setBool('tutorial_v5',tutorialFinished);
      await prefs.setBool('arcade_intro_v7',arcadeIntroFinished);
      await prefs.setBool('haptics_v4',haptics);
      await prefs.setStringList('recent_v4',recent.take(80).toList());
      await prefs.setStringList('arcade_recent_v1',arcadeHistory);
      await prefs.setStringList('callbacks_v4',callbacks.map(jsonEncode).toList());
      await prefs.setString('stats_v1', jsonEncode(stats));
      if (notifyCloud) onSaved?.call();
    } catch (_) { }
  }
  void _haptic() { if (haptics) HapticFeedback.selectionClick(); }

  /// Two short interactive training cases: a fraudulent delivery message and
  /// an authentic bookshop payment receipt. No question-and-answer lecture.
  void startTutorial() {
    final spam = patterns.firstWhere((p) => p.kind == CaseKind.sms && p.verdict == Verdict.reject);
    final receipt = patterns.firstWhere((p) => p.kind == CaseKind.sms && p.verdict == Verdict.approve && p.body.contains('₱'));
    final generator = CaseGenerator(42);
    queue = [generator.build(spam,'training-spam'),generator.build(receipt,'training-receipt')];
    mode = Mode.training;
    shiftNumber = 0;
    modifier = 'FIRST DAY';
    _resetShift();
    credits = 3;
    tutorialStep = 0;
    notifyListeners();
  }

  void startShift(int requested, {bool endless = false}) {
    if (endless && !canPlayEndless) return;
    if (!endless && (requested < 1 || requested > 6 || requested > unlockedShift)) return;
    _haptic();
    mode = endless ? Mode.endless : Mode.career;
    shiftNumber = endless ? 7 : requested;
    runSeed = DateTime.now().microsecondsSinceEpoch ^ Random().nextInt(0x7fffffff);
    final followups = <PlayCase>[];
    if (callbacks.isNotEmpty) {
      final prior = callbacks.removeAt(0);
      final id = (prior['archetype'] ?? '').toString();
      final index = int.tryParse(id.split(':').last) ?? 0;
      if (index >= 0 && index < patterns.length) {
        final former = patterns[index];
        final original = CaseGenerator(runSeed + 1).build(former,'followup:$runSeed');
        final wasAppeal = prior['type'] == 'appeal';
        followups.add(PlayCase(
          id: 'callback:$runSeed', archetypeId: 'callback:$runSeed',
          kind: CaseKind.report,
          correct: wasAppeal ? Verdict.approve : Verdict.reject,
          topic: original.topic,
          author: 'Tambayan Appeals Desk',
          handle: '@tambayanappeals',
          headline: wasAppeal ? 'A previous removal was appealed' : 'A user reported a prior approval',
          body: wasAppeal
              ? 'The creator of a previously removed ${original.topic.toLowerCase()} post requests a review.'
              : 'A community member reports harm after an earlier ${original.topic.toLowerCase()} post stayed online.',
          artifact: '📁 LINKED CASE', secondary: 'Earlier decision is on record',
          timestamp: 'today', accountAge: '3 years ago', ageDays: 1095,
          followers: 12500, likes: 0, reports: 1, verified: true,
          rationale: wasAppeal
              ? 'The earlier content was legitimate. Reverse the wrongful removal.'
              : 'The earlier content was deceptive. Remove it to prevent further harm.',
          variant: 'followup:$runSeed', tier: 2,
          clues: [
            const Hotspot('identity','PREVIOUS CASE','A reviewer has documented the previous decision.',Icons.history_rounded),
            const Hotspot('context','NEW REPORT','New information prompted the appeal.',Icons.flag_outlined),
            Hotspot('source','REVIEW THE SOURCE',
              wasAppeal ? 'The full original post was legitimate and complied with the rules.' : 'Independent evidence confirms deceptive conduct.',
              Icons.fact_check_outlined, verification:true, strength:3,
              signal:wasAppeal?EvidenceSignal.supporting:EvidenceSignal.suspicious),
          ],
        ));
      }
    }
    final bundle = CaseGenerator(runSeed).generate(
      shiftNumber, seed:runSeed, endless:endless,
      count:7, recent:recent, callbacks:followups,
      safety:safety, fairness:fairness,
    );
    queue = bundle.cases;
    recent.addAll(bundle.signatures);
    if (recent.length > 80) recent = recent.skip(recent.length - 80).toSet();
    modifier = bundle.modifier;
    _resetShift();
    notifyListeners();
    _save();
  }

  void _resetShift() {
    shiftXp = 0;
    correctCount = 0;
    mistakes = 0;
    currentIndex = 0;
    pendingResult = null;
    finished = false;
    credits = 6;
    results.clear();
    revealed.clear();
    tags.clear();
    verifiedSource = false;
  }

  Hotspot? inspect(String key) {
    if (!inShift || pendingResult != null) return null;
    final clues = currentCase.clues.where((h) => h.id == key && !h.verification);
    if (clues.isEmpty) return null;
    revealed.add(key);
    if (isTraining && currentIndex == 0 && tutorialStep == 0) tutorialStep = 1;
    _haptic();
    notifyListeners();
    return clues.first;
  }

  void tagEvidence(String key) {
    if (!revealed.contains(key) || pendingResult != null) return;
    tags[key] = (tags[key] ?? EvidenceTag.unset).next;
    // Evidence classification is optional: beginners first learn to inspect and verify.
    _haptic();
    notifyListeners();
  }

  Hotspot? verify() {
    if (!inShift || pendingResult != null || verifiedSource) return null;
    final candidate = currentCase.clues.where((h) => h.verification);
    if (candidate.isEmpty) return null;
    verifiedSource = true;
    revealed.add(candidate.first.id);
    if (isTraining && currentIndex == 0 && tutorialStep <= 1) tutorialStep = 2;
    _haptic();
    notifyListeners();
    return candidate.first;
  }

  ReviewResult? decide(Verdict decision) {
    if (!inShift || pendingResult != null) return null;
    // Training demonstrates a decision after evidence, without forcing a
    // particular verdict or showing its answer beforehand.
    if (isTraining && currentIndex == 0 && tutorialStep < 2) return null;
    final item = currentCase;
    final right = decision == item.correct;
    int matching = 0;
    for (final clue in item.clues) {
      final tag = tags[clue.id];
      if (tag == null || tag == EvidenceTag.unset) continue;
      final correctTag = switch (clue.signal) {
        EvidenceSignal.suspicious => EvidenceTag.suspicious,
        EvidenceSignal.supporting => EvidenceTag.supporting,
        EvidenceSignal.ambiguous => EvidenceTag.unsure,
        EvidenceSignal.neutral => EvidenceTag.unsure,
      };
      if (tag == correctTag) matching++;
      principlesSeen.update(clue.principle,(value)=>value+1,ifAbsent:()=>1);
      if (tag == correctTag) {
        principlesCorrect.update(clue.principle,(value)=>value+1,ifAbsent:()=>1);
      }
    }
    final int points = right
        ? (item.tier == 1 ? 20 : item.tier == 2 ? 30 : 45) +
            min<int>(9, matching * 3)
        : item.correct == Verdict.reject ? -40 : -25;
    shiftXp += points;
    if (right) {
      correctCount++;
      _earnCareerXp(points);
      safety = min(100,safety+1);
      fairness = min(100,fairness+1);
    } else {
      mistakes++;
      if (item.correct == Verdict.reject) {
        safety = max(0,safety-10);
      } else {
        fairness = max(0,fairness-8);
      }
      if (!isTraining && !item.id.startsWith('callback')) {
        callbacks.add({
          'type': item.correct == Verdict.approve ? 'appeal' : 'victim',
          'archetype': item.archetypeId,
        });
        if (callbacks.length > 8) callbacks.removeAt(0);
      }
    }
    final result = ReviewResult(item,decision,points,right,matching,
      verifiedSource, Map<String,EvidenceTag>.from(tags), Set<String>.from(revealed));
    results.add(result);
    pendingResult = result;
    _haptic();
    notifyListeners();
    _save();
    return result;
  }

  void next() {
    if (pendingResult == null) return;
    pendingResult = null;
    if (currentIndex >= queue.length - 1) {
      finished = true;
      if (isTraining) {
        tutorialFinished = true;
        tutorialStep = 5;
      } else {
        completedShifts++;
        // Completing a numbered career shift always unlocks the next in order.
        // The grade affects the report, not the player's ability to continue.
        if (mode == Mode.career && shiftNumber == unlockedShift && unlockedShift <= 6) {
          unlockedShift++;
        }
      }
      _save();
    } else {
      currentIndex++;
      revealed.clear();
      tags.clear();
      verifiedSource = false;
      if (isTraining) tutorialStep = 3;
    }
    _haptic();
    notifyListeners();
  }

  /// Arcade onboarding is separate from the classic moderator training.
  /// First-day training unlocks the Arcade Hub; XP unlocks advanced modes.
  bool get arcadeUnlocked => arcadeIntroFinished;

  bool arcadeModeUnlocked(int threshold) => arcadeIntroFinished && careerXp >= threshold;

  Future<void> finishArcadeIntro() async {
    arcadeIntroFinished = true;
    notifyListeners();
    await _save();
  }

  Future<void> replayArcadeIntro() async {
    arcadeIntroFinished = false;
    notifyListeners();
    await _save();
  }


  void recordArcadeCase(String signature) {
    arcadeHistory.remove(signature);
    arcadeHistory.add(signature);
    if (arcadeHistory.length > 15) arcadeHistory.removeAt(0);
    _save();
  }

  void awardArcadeXp(int amount) {
    if (amount <= 0) return;
    _earnCareerXp(amount);
    notifyListeners();
    _save();
  }

  Future<void> skipTutorial() async {
    tutorialFinished = true;
    tutorialStep = 5;
    notifyListeners();
    await _save();
  }
  Future<void> resetTutorial() async {
    tutorialFinished = false;
    tutorialStep = 0;
    notifyListeners();
    await _save();
  }
  Future<void> setHaptics(bool value) async {
    haptics = value;
    notifyListeners();
    await _save();
  }
}