import 'arcade_models.dart';
import 'round_record.dart';

/// How one concept went during a run.
class ConceptStat {
  final Concept concept;
  final int seen, missed;
  const ConceptStat(this.concept, this.seen, this.missed);
  double get missRate => seen == 0 ? 0 : missed / seen;
}

/// Pure summary of a finished run.
class RunStats {
  final List<RoundRecord> log;
  const RunStats(this.log);

  int get answered => log.length;
  int get correct => log.where((r) => r.correct).length;

  int count(ErrorKind kind) => log.where((r) => r.error == kind).length;

  /// Every concept that appeared at least once, with its seen/missed counts.
  List<ConceptStat> get conceptStats {
    final seen = <Concept, int>{};
    final missed = <Concept, int>{};
    for (final r in log) {
      for (final c in r.concepts) {
        seen[c] = (seen[c] ?? 0) + 1;
        if (!r.correct) missed[c] = (missed[c] ?? 0) + 1;
      }
    }
    return [
      for (final e in seen.entries)
        ConceptStat(e.key, e.value, missed[e.key] ?? 0),
    ];
  }

  /// Up to [limit] concepts the player missed, worst first.
  List<ConceptStat> weakest({int limit = 3}) {
    final list = conceptStats.where((s) => s.missed > 0).toList()
      ..sort((a, b) {
        final byMissed = b.missed.compareTo(a.missed);
        return byMissed != 0 ? byMissed : b.missRate.compareTo(a.missRate);
      });
    return list.take(limit).toList();
  }

  /// Rounds the player got wrong, in the order they happened.
  List<RoundRecord> get misses => log.where((r) => !r.correct).toList();

  /// Actionable feedback for the most common mistake pattern, or null if clean.
  String? get errorPattern {
    final mistakes = misses;
    if (mistakes.isEmpty) return null;

    final patterns = [
      ErrorKind.trustedBad,
      ErrorKind.flaggedGood,
      ErrorKind.timeout,
      ErrorKind.other,
    ];
    final highestCount = patterns.map(count).reduce((a, b) => a > b ? a : b);
    final leadingPatterns = patterns
        .where((kind) => count(kind) == highestCount)
        .toList();

    if (leadingPatterns.length == 1) {
      final kind = leadingPatterns.single;
      switch (kind) {
        case ErrorKind.trustedBad:
          final total = count(kind);
          return 'You trusted deceptive content $total time${total == 1 ? '' : 's'}. '
              'Check the decisive evidence before trusting a claim.';
        case ErrorKind.flaggedGood:
          final total = count(kind);
          return 'You rejected legitimate content $total time${total == 1 ? '' : 's'}. '
              'Check for satire, honest opinions and missing context before rejecting it.';
        case ErrorKind.timeout:
          final total = count(kind);
          return 'You timed out on an inbox item in $total round${total == 1 ? '' : 's'}. '
              'Check the sender and request first, then decide.';
        case ErrorKind.other:
          return _modeFeedback(mistakes);
        case ErrorKind.none:
          break;
      }
    }

    if (leadingPatterns.contains(ErrorKind.trustedBad) &&
        leadingPatterns.contains(ErrorKind.flaggedGood)) {
      return 'You made mistakes in both directions: trusting deceptive content '
          'and removing legitimate ones. Check the evidence before deciding.';
    }
    return 'Your mistakes are spread across a few patterns. '
        '${_modeFeedback(mistakes)}';
  }

  String _modeFeedback(List<RoundRecord> mistakes) {
    final missesByMode = <ArcadeMode, int>{};
    for (final record in mistakes) {
      missesByMode.update(record.mode, (count) => count + 1, ifAbsent: () => 1);
    }
    final toughestMode = missesByMode.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final mode = toughestMode.key;
    final total = toughestMode.value;
    final guidance = switch (mode) {
      ArcadeMode.trust =>
        'Check the decisive evidence before choosing to keep or remove a post.',
      ArcadeMode.impostor =>
        'Compare both handles with the directory instead of relying on profile names.',
      ArcadeMode.scamSlam =>
        'Choose a reply that protects the account and verifies through an official channel.',
      ArcadeMode.rumor =>
        'Check the original source, timeline and wording before solving the puzzle.',
      ArcadeMode.inbox => 'Check each sender, link and request before swiping.',
      ArcadeMode.comments =>
        'Flag rule-breaking behavior, not disagreement or honest criticism.',
      ArcadeMode.clip =>
        'Compare the full context with the viral cut before deciding.',
    };
    return 'Most misses were in ${mode.title} ($total). $guidance';
  }
}
