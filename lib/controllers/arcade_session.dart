import 'dart:math';
import '../services/arcade_thread_generator.dart';
import '../services/arcade_generator.dart';
import '../models/arcade_models.dart';
import '../models/round_record.dart';

/// One play session, independent of Flutter widgets. v5 GameEngine is the
/// only permanent career-XP store. Tests use deterministic seeds.
class ArcadeSession {
  final ArcadeDifficulty difficulty;
  final ArcadeMode? selectedMode;
  final bool firstDay;
  final int? roundLimit;
  final void Function(int) awardCareerXp;
  final int Function() careerXp;
  final void Function(String)? onCaseGenerated;
  final Set<String> history;
  final ArcadeGenerator generator;
  final Set<String> signatures = <String>{};
  final Set<String> _threadChoices = <String>{};
  final Set<String> _threadParts = <String>{};
  final List<ArcadeMode> recentModes = [];
  final List<RoundRecord> log = [];
  static const firstDayModes = [
    ArcadeMode.trust,
    ArcadeMode.impostor,
    ArcadeMode.scamSlam,
    ArcadeMode.inbox,
    ArcadeMode.comments,
  ];

  late ArcadeCase current;
  int hearts;
  int score = 0;
  int round = 0;
  int successful = 0;
  int streak = 0;
  int bestStreak = 0;
  int lastEarnedXp = 0;
  int lastParts = 0;
  bool lastUsedDecisive = false;
  bool finished = false;
  bool waitingForNext = false;
  bool? lastCorrect;
  List<int> lastAnswer = const [];
  List<String> lastOpened = const [];

  ArcadeSession({
    required this.difficulty,
    required this.selectedMode,
    required this.awardCareerXp,
    int Function()? careerXp,
    this.roundLimit,
    this.firstDay = false,
    this.onCaseGenerated,
    Set<String> recentHistory = const {},
    int? seed,
  }) : hearts = difficulty.startingHearts,
       careerXp = careerXp ?? (() => 0),
       generator = ArcadeGenerator(
         seed ?? DateTime.now().microsecondsSinceEpoch,
       ),
       history = Set<String>.from(recentHistory) {
    _deal();
  }

  ArcadeMode _chooseMode() {
    if (firstDay) return firstDayModes[round.clamp(0, 4).toInt()];
    if (selectedMode != null) return selectedMode!;
    final unlocked = ArcadeMode.values
        .where((mode) => careerXp() >= mode.unlockXp)
        .toList();
    final candidates = unlocked
        .where((mode) => recentModes.isEmpty || mode != recentModes.last)
        .toList();
    final pool = candidates.isEmpty ? unlocked : candidates;
    final fresh = pool.where((mode) => !recentModes.contains(mode)).toList();
    return generator.pick(fresh.isNotEmpty ? fresh : pool);
  }

  void _deal() {
    final kind = _chooseMode();
    final blockedFamilies = <String>{};
    if (kind != ArcadeMode.inbox) {
      // Avoid every template already dealt in this run while another exists.
      // Once a mode's templates are exhausted, the generator falls back to
      // fresh, content-distinct cases instead of repeating an answered case.
      blockedFamilies.addAll(signatures.map(ArcadeGenerator.familyOfSignature));
      final historyFamilies = <String>{};
      final familyPrefix = switch (kind) {
        ArcadeMode.trust => 'trust:',
        ArcadeMode.impostor => 'impostor:',
        ArcadeMode.scamSlam => 'chat:',
        ArcadeMode.rumor => 'rumor:',
        ArcadeMode.comments => 'thread:',
        ArcadeMode.clip => 'clip:',
        ArcadeMode.inbox => '',
      };
      for (final signature in history.toList().reversed) {
        if (signature.startsWith(familyPrefix)) {
          historyFamilies.add(ArcadeGenerator.familyOfSignature(signature));
          if (historyFamilies.length >=
              min(4, ArcadeGenerator.scenarioCount(kind) - 1)) {
            break;
          }
        }
      }
      blockedFamilies.addAll(historyFamilies);
    }
    current = generator.generate(
      kind,
      firstDay ? ArcadeDifficulty.easy : difficulty,
      exclude: {...history, ...signatures},
      excludeFamilies: blockedFamilies,
      excludeThreadChoices: _threadChoices,
      excludeThreadParts: _threadParts,
      tutorial: firstDay,
    );
    if (kind == ArcadeMode.comments) {
      for (final comment in current.comments) {
        if (!_threadChoices.add(comment.body)) {
          throw StateError('A thread comment was repeated in this run.');
        }
      }
      for (final part in threadChoiceParts(current)) {
        if (!_threadParts.add(part)) {
          throw StateError('A thread sentence was repeated in this run.');
        }
      }
    }
    signatures.add(current.signature);
    onCaseGenerated?.call(current.signature);
    recentModes.add(kind);
    if (recentModes.length > 4) recentModes.removeAt(0);
  }

  int get totalAnswered => round;
  int get totalCases => firstDay ? firstDayModes.length : roundLimit ?? 999;

  /// Single-choice convenience.
  bool answer(int optionIndex, {bool inspected = false}) {
    if (optionIndex < 0 ||
        optionIndex >= current.choices.length && current.choices.isNotEmpty) {
      throw RangeError.index(optionIndex, current.choices);
    }
    return submit([optionIndex], usedDecisive: inspected);
  }

  /// Scores an answer in the current mode's own format (see
  /// [ArcadeCase.correct]). One answer per case; XP never decreases, errors
  /// cost a heart. The first day is forgiving so a beginner is never locked
  /// out. Inbox Sprint earns partial XP but any wrong swipe costs a heart.
  bool submit(
    List<int> answer, {
    bool usedDecisive = false,
    List<String> opened = const [],
  }) {
    if (finished || waitingForNext) return lastCorrect ?? false;
    final c = current;
    final parts = c.totalParts;
    final right = c.matches(answer);
    final correct = c.isBatch ? right == parts : c.isCorrect(answer);
    lastAnswer = List.unmodifiable(answer);
    lastOpened = List.unmodifiable(opened);
    lastCorrect = correct;
    log.add(
      RoundRecord(
        mode: c.mode,
        scenario: c.scenario,
        concepts: c.concepts,
        correct: correct,
        error: c.errorKind(answer),
      ),
    );
    lastParts = right;
    lastUsedDecisive =
        usedDecisive &&
        (c.mode == ArcadeMode.trust || c.mode == ArcadeMode.clip);
    lastEarnedXp = 0;
    waitingForNext = true;
    round++;
    final full =
        35 +
        difficulty.bonusXp +
        (usedDecisive &&
                (c.mode == ArcadeMode.trust || c.mode == ArcadeMode.clip)
            ? 15
            : 0) +
        min(streak, 4) * 3;
    var gained = 0;
    if (correct) {
      gained = c.isBatch ? full + 10 : full;
      successful++;
      streak++;
      bestStreak = max(bestStreak, streak);
    } else {
      if (c.isBatch && right > 0) gained = (full * right / parts / 2).round();
      streak = 0;
      hearts = firstDay ? max(1, hearts - 1) : max(0, hearts - 1);
    }
    if (gained > 0) {
      score += gained;
      lastEarnedXp = gained;
      awardCareerXp(gained);
    }
    if ((firstDay && round >= firstDayModes.length) ||
        (!firstDay &&
            (hearts == 0 || (roundLimit != null && round >= roundLimit!)))) {
      finished = true;
    }
    return correct;
  }

  void next() {
    if (finished || !waitingForNext) return;
    waitingForNext = false;
    lastAnswer = const [];
    lastOpened = const [];
    lastCorrect = null;
    lastEarnedXp = 0;
    lastUsedDecisive = false;
    _deal();
  }

  void endEarly() => finished = true;
}
