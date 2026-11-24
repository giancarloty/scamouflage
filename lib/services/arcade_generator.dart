import 'dart:math';
import 'arcade_common.dart';
import 'arcade_gen_chat.dart';
import 'arcade_gen_clip.dart';
import 'arcade_gen_impostor.dart';
import 'arcade_gen_inbox.dart';
import 'arcade_gen_rumor.dart';
import 'arcade_gen_thread.dart';
import 'arcade_gen_trust.dart';
import '../models/arcade_models.dart';

/// Offline, truth-first case composer. For each mode the generator first picks
/// a scenario (and its true outcome), then writes visible wording and clues
/// from that truth. Difficulty changes evidence budget, noise and the number
/// of items, not just the hearts.
class ArcadeGenerator {
  final Random random;
  final Gen gen;
  ArcadeGenerator(int seed)
      : random = Random(seed),
        gen = Gen(Random(seed ^ 0x5bd1e995));

  T pick<T>(List<T> choices) => choices[random.nextInt(choices.length)];

  /// How many distinct scenarios a mode has (before per-case variation).
  static int scenarioCount(ArcadeMode mode) => switch (mode) {
    ArcadeMode.trust => trustScenarioCount(),
    ArcadeMode.impostor => impostorScenarioCount(),
    ArcadeMode.scamSlam => chatScenarioCount(),
    ArcadeMode.rumor => rumorScenarioCount(),
    ArcadeMode.inbox => inboxScenarioCount(),
    ArcadeMode.comments => threadScenarioCount(),
    ArcadeMode.clip => clipScenarioCount(),
  };

  /// Whether scenario [i] of [mode] is a "bad" (remove/flag/scam) outcome, or
  /// null when the mode does not have a simple good/bad split.
  static bool? scenarioIsBad(ArcadeMode mode, int i) => switch (mode) {
    ArcadeMode.trust => trustScenarioBad(i),
    ArcadeMode.impostor => impostorScenarioFlagged(i),
    ArcadeMode.scamSlam => chatScenarioScam(i),
    ArcadeMode.clip => clipScenarioBad(i),
    _ => null,
  };

  static int _tutorialIndex(ArcadeMode mode) {
    String idOf(int i) => switch (mode) {
      ArcadeMode.trust => trustScenarioId(i),
      ArcadeMode.impostor => impostorScenarioId(i),
      ArcadeMode.scamSlam => chatScenarioId(i),
      _ => '',
    };
    final wanted = switch (mode) {
      ArcadeMode.trust => 'recycled_flood',
      ArcadeMode.impostor => 'lookalike',
      ArcadeMode.scamSlam => 'parcel_fee',
      _ => '',
    };
    if (wanted.isEmpty) return 0;
    for (var i = 0; i < scenarioCount(mode); i++) {
      if (idOf(i) == wanted) return i;
    }
    return 0;
  }

  /// A family is the decision-making archetype, not a new handle or amount.
  /// A player should not see "parcel fee" again immediately just because
  /// the courier name changed.
  static String familyOfSignature(String signature) {
    final parts = signature.split(':');
    if (parts.length < 2) return signature;
    return '${parts[0]}:${parts[1]}';
  }

  static String _familyAt(ArcadeMode mode, int i) => switch (mode) {
    ArcadeMode.trust => 'trust:${trustScenarioId(i)}',
    ArcadeMode.impostor => 'impostor:${impostorScenarioId(i)}',
    ArcadeMode.scamSlam => 'chat:${chatScenarioId(i)}',
    ArcadeMode.rumor => 'rumor:${switch (RumorTask.values[i]) {
      RumorTask.spotDiff => 'spot',
      RumorTask.wordEdit => 'words',
      final task => task.name,
    }}',
    ArcadeMode.inbox => 'inbox:batch',
    ArcadeMode.comments => 'thread:${threadScenarioId(i)}',
    ArcadeMode.clip => 'clip:${clipScenarioId(i)}',
  };

  int _chooseScenario(ArcadeMode mode, double badShare,
      {Set<String> excludeFamilies = const {},
      Set<int> triedIndices = const {}}) {
    final count = scenarioCount(mode);
    final all = [for (var i = 0; i < count; i++) i];
    // Inbox generates whole batches rather than selecting a single template,
    // so it is intentionally not subject to family exclusion.
    final unseen = mode == ArcadeMode.inbox ? all : all.where((i) =>
        !excludeFamilies.contains(_familyAt(mode, i))).toList();
    final candidates = unseen.where((i) => !triedIndices.contains(i)).toList();
    final pool = candidates.isEmpty ? all : candidates;
    if (scenarioIsBad(mode, 0) == null) return pick(pool);
    final wantBad = random.nextDouble() < badShare;
    final matched = pool.where((i) => scenarioIsBad(mode, i) == wantBad).toList();
    return pick(matched.isEmpty ? pool : matched);
  }

  ArcadeCase _build(ArcadeMode mode, ArcadeDifficulty d, int i,
      {bool tutorial = false}) => switch (mode) {
    ArcadeMode.trust => buildTrust(gen, d, i),
    ArcadeMode.impostor => buildImpostor(gen, d, i),
    ArcadeMode.scamSlam => buildChat(gen, d, i),
    ArcadeMode.rumor => buildRumor(gen, d, i),
    ArcadeMode.inbox => buildInbox(gen, d, i, count: tutorial ? 3 : null),
    ArcadeMode.comments =>
        buildThread(gen, d, i, forceBad: tutorial ? 1 : null),
    ArcadeMode.clip => buildClip(gen, d, i),
  };

  /// Avoid recent *scenario families* first, then exact signatures.
  /// We only fall back to a repeat when the available pool is exhausted.
  ArcadeCase generate(ArcadeMode mode, ArcadeDifficulty difficulty,
      {Set<String> exclude = const {},
      Set<String> excludeFamilies = const {},
      bool tutorial = false}) {
    if (tutorial) {
      return _build(mode, ArcadeDifficulty.easy, _tutorialIndex(mode),
          tutorial: true);
    }
    final badShare = switch (mode) {
      ArcadeMode.scamSlam => .5,
      ArcadeMode.impostor => .55,
      _ => .5,
    };
    // A fixed-template mode can exhaust its entire available pool. Try
    // alternate templates rather than randomly rolling the same one 16 times.
    final tried = <int>{};
    final dynamicBatch = mode == ArcadeMode.inbox;
    ArcadeCase? fallback;
    final limit = dynamicBatch ? 64 : scenarioCount(mode);
    for (var attempt = 0; attempt < limit; attempt++) {
      final index = _chooseScenario(mode, badShare,
          excludeFamilies: excludeFamilies, triedIndices: tried);
      if (!dynamicBatch) tried.add(index);
      final caseData = _build(mode, difficulty, index);
      fallback ??= caseData;
      final family = familyOfSignature(caseData.signature);
      if (!excludeFamilies.contains(family) &&
          !exclude.contains(caseData.signature)) return caseData;
      // In a fixed-template mode, once every template is considered, it is
      // better to fall back than to keep requesting another random roll.
    }
    // When all families are blocked (e.g. all 5 Rumor puzzles have appeared),
    // relax the family rule before abandoning exact-repeat prevention.
    for (var attempt = 0; attempt < (dynamicBatch ? 24 : scenarioCount(mode)); attempt++) {
      final candidate = _build(mode, difficulty,
          _chooseScenario(mode, badShare));
      if (!exclude.contains(candidate.signature)) return candidate;
    }
    return fallback!;
  }
}
