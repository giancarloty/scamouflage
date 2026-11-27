import 'dart:math';
import 'arcade_common.dart';
import 'arcade_chat_generator.dart';
import 'arcade_clip_generator.dart';
import 'arcade_impostor_generator.dart';
import 'arcade_inbox_generator.dart';
import 'arcade_rumor_generator.dart';
import 'arcade_thread_generator.dart';
import 'arcade_trust_generator.dart';
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

  /// Keep verdicts balanced without making the next answer depend on the last.
  double _badShareFor(ArcadeMode mode) =>
      mode == ArcadeMode.impostor ? .55 : .5;

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

  static String _identifiedSignature(ArcadeCase c) {
    final pairedClip =
        c.mode == ArcadeMode.clip &&
        (c.scenario.endsWith('__keep') || c.scenario.endsWith('__remove'));
    final parts = pairedClip
        ? <String>[c.mode.name, c.scenario]
        : <String>[
            c.mode.name,
            c.scenario,
            c.title,
            c.author,
            if (c.mode != ArcadeMode.clip) c.handle,
            c.text,
            c.subtext,
            c.lesson,
            c.hint,
            c.visual,
            c.imageTopic,
            c.imageCaption,
            c.reactions,
            c.deceptive.toString(),
            c.rumorTask?.name ?? '',
            ...c.correct.map((value) => 'answer:$value'),
            ...c.tools.map(
              (item) =>
                  '${item.id}:${item.label}:${item.text}:${item.relevance.name}',
            ),
            ...c.directory,
            ...c.chatIn,
            ...c.activity,
            c.linkDomain,
            ...c.choices.map((item) => item.text),
            ...c.followUps.entries.expand(
              (entry) => ['follow:${entry.key}', ...entry.value],
            ),
            ...c.cards.expand((item) => [item.title, item.body, item.meta]),
            ...c.tokens,
            ...c.emails.expand(
              (item) => [
                item.fromName,
                item.fromAddress,
                item.replyTo,
                item.subject,
                item.body,
                item.linkLabel,
                item.linkTarget,
                item.attachment,
                item.spam.toString(),
                item.why,
              ],
            ),
            ...c.comments.expand(
              (item) => [
                item.handle,
                item.body,
                item.context,
                item.reason,
                item.violates.toString(),
              ],
            ),
            ...c.beats.expand(
              (item) => [
                item.second.toString(),
                item.scene,
                item.viralLine,
                item.fullLine,
                item.inViral.toString(),
              ],
            ),
            if (c.leftProfile case final profile?)
              '${profile.name}:${profile.handle}:${profile.bio}:${profile.link}:'
                  '${profile.label}:${profile.ageDays}:${profile.followers}:'
                  '${profile.badge}:${profile.recent.join('|')}',
            if (c.rightProfile case final profile?)
              '${profile.name}:${profile.handle}:${profile.bio}:${profile.link}:'
                  '${profile.label}:${profile.ageDays}:${profile.followers}:'
                  '${profile.badge}:${profile.recent.join('|')}',
          ];
    var hashA = 0x811c9dc5;
    var hashB = 0x9e3779b9;
    for (final codeUnit in parts.join('\u0000').codeUnits) {
      hashA = ((hashA ^ codeUnit) * 0x01000193) & 0xffffffff;
      hashB = ((hashB + codeUnit) * 0x045d9f3b) & 0xffffffff;
    }
    return '${c.signature}:${hashA.toRadixString(16).padLeft(8, '0')}'
        '${hashB.toRadixString(16).padLeft(8, '0')}';
  }

  static String _familyAt(ArcadeMode mode, int i) => switch (mode) {
    ArcadeMode.trust => 'trust:${trustScenarioId(i)}',
    ArcadeMode.impostor => 'impostor:${impostorScenarioId(i)}',
    ArcadeMode.scamSlam => 'chat:${chatScenarioId(i)}',
    ArcadeMode.rumor =>
      'rumor:${switch (RumorTask.values[i]) {
        RumorTask.spotDiff => 'spot',
        RumorTask.wordEdit => 'words',
        final task => task.name,
      }}',
    ArcadeMode.inbox => 'inbox:batch',
    ArcadeMode.comments => 'thread:${threadScenarioId(i)}',
    ArcadeMode.clip => 'clip:${clipScenarioId(i)}',
  };

  int _chooseScenario(
    ArcadeMode mode,
    ArcadeDifficulty difficulty,
    double badShare, {
    Set<String> excludeFamilies = const {},
    Set<int> triedIndices = const {},
  }) {
    final count = scenarioCount(mode);
    final all = [
      for (var i = 0; i < count; i++)
        if (mode != ArcadeMode.clip || clipScenarioAllowed(i, difficulty)) i,
    ];
    // Inbox generates whole batches rather than selecting a single template,
    // so it is intentionally not subject to family exclusion.
    final unseen = mode == ArcadeMode.inbox
        ? all
        : all
              .where((i) => !excludeFamilies.contains(_familyAt(mode, i)))
              .toList();
    final candidates = unseen.where((i) => !triedIndices.contains(i)).toList();
    final pool = candidates.isEmpty ? all : candidates;
    if (scenarioIsBad(mode, 0) == null) return pick(pool);
    final wantBad = random.nextDouble() < badShare;
    final matched = pool
        .where((i) => scenarioIsBad(mode, i) == wantBad)
        .toList();
    return pick(matched.isEmpty ? pool : matched);
  }

  ArcadeCase _build(
    ArcadeMode mode,
    ArcadeDifficulty d,
    int i, {
    bool tutorial = false,
    Set<String> excludeThreadChoices = const {},
    Set<String> excludeThreadParts = const {},
  }) => switch (mode) {
    ArcadeMode.trust => buildTrust(gen, d, i),
    ArcadeMode.impostor => buildImpostor(gen, d, i),
    ArcadeMode.scamSlam => buildChat(gen, d, i),
    ArcadeMode.rumor => buildRumor(gen, d, i),
    ArcadeMode.inbox => buildInbox(gen, d, i, count: tutorial ? 3 : null),
    ArcadeMode.comments => buildThread(
      gen,
      d,
      i,
      forceBad: tutorial ? 1 : null,
      excludeChoices: excludeThreadChoices,
      excludeParts: excludeThreadParts,
    ),
    ArcadeMode.clip => buildClip(gen, d, i),
  };

  ArcadeCase generate(
    ArcadeMode mode,
    ArcadeDifficulty difficulty, {
    Set<String> exclude = const {},
    Set<String> excludeFamilies = const {},
    Set<String> excludeThreadChoices = const {},
    Set<String> excludeThreadParts = const {},
    bool tutorial = false,
  }) {
    return _generateCase(
      mode,
      difficulty,
      exclude: exclude,
      excludeFamilies: excludeFamilies,
      excludeThreadChoices: excludeThreadChoices,
      excludeThreadParts: excludeThreadParts,
      tutorial: tutorial,
    );
  }

  /// Avoid recent scenario families first, then exact generated cases.
  /// Exact repeats are never returned, even after every family has appeared.
  ArcadeCase _generateCase(
    ArcadeMode mode,
    ArcadeDifficulty difficulty, {
    Set<String> exclude = const {},
    Set<String> excludeFamilies = const {},
    Set<String> excludeThreadChoices = const {},
    Set<String> excludeThreadParts = const {},
    bool tutorial = false,
  }) {
    if (tutorial) {
      return _build(
        mode,
        ArcadeDifficulty.easy,
        _tutorialIndex(mode),
        tutorial: true,
        excludeThreadChoices: excludeThreadChoices,
        excludeThreadParts: excludeThreadParts,
      );
    }
    final badShare = _badShareFor(mode);

    // A fixed-template mode can exhaust its entire available pool. Try
    // alternate templates rather than randomly rolling the same one 16 times.
    final tried = <int>{};
    final dynamicBatch = mode == ArcadeMode.inbox;
    ArcadeCase? fallback;
    final limit = dynamicBatch ? 64 : scenarioCount(mode);
    for (var attempt = 0; attempt < limit; attempt++) {
      final index = _chooseScenario(
        mode,
        difficulty,
        badShare,
        excludeFamilies: excludeFamilies,
        triedIndices: tried,
      );
      if (!dynamicBatch) tried.add(index);
      final built = _build(
        mode,
        difficulty,
        index,
        excludeThreadChoices: excludeThreadChoices,
        excludeThreadParts: excludeThreadParts,
      );
      final caseData = built.copyWith(signature: _identifiedSignature(built));
      fallback ??= caseData;
      final family = familyOfSignature(caseData.signature);
      if (!excludeFamilies.contains(family) &&
          !exclude.contains(caseData.signature)) {
        return caseData;
      }
      // In a fixed-template mode, once every template is considered, it is
      // better to fall back than to keep requesting another random roll.
    }
    // Once all scenario families are exhausted, relax family exclusion. Keep
    // this bounded so a difficult/randomized mode can never stall the session.
    // Try a small randomized pass, then a deterministic template pass.
    for (var attempt = 0; attempt < 64; attempt++) {
      final built = _build(
        mode,
        difficulty,
        _chooseScenario(mode, difficulty, badShare),
        excludeThreadChoices: excludeThreadChoices,
        excludeThreadParts: excludeThreadParts,
      );
      final candidate = built.copyWith(signature: _identifiedSignature(built));
      if (!exclude.contains(candidate.signature)) return candidate;
    }
    for (var index = 0; index < scenarioCount(mode); index++) {
      if (mode == ArcadeMode.clip && !clipScenarioAllowed(index, difficulty)) {
        continue;
      }
      final built = _build(
        mode,
        difficulty,
        index,
        excludeThreadChoices: excludeThreadChoices,
        excludeThreadParts: excludeThreadParts,
      );
      final candidate = built.copyWith(signature: _identifiedSignature(built));
      if (!exclude.contains(candidate.signature)) return candidate;
    }
    // Last-resort fallback: finish dealing instead of throwing and leaving the
    // game UI stuck in a generation/retry loop. Fixed-template content can be
    // repeated only after the pool and exact signatures are exhausted.
    if (fallback != null) return fallback;
    final built = _build(
      mode,
      difficulty,
      mode == ArcadeMode.clip ? _chooseScenario(mode, difficulty, badShare) : 0,
      excludeThreadChoices: excludeThreadChoices,
      excludeThreadParts: excludeThreadParts,
    );
    return built.copyWith(signature: _identifiedSignature(built));
  }
}
