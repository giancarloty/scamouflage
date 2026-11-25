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

  /// One sentence about the kind of mistake made most, or null if none.
  String? get errorPattern {
    final trusted = count(ErrorKind.trustedBad);
    final flagged = count(ErrorKind.flaggedGood);
    final timeouts = count(ErrorKind.timeout);
    if (trusted == 0 && flagged == 0 && timeouts == 0) return null;
    if (timeouts > trusted && timeouts > flagged) {
      return 'You ran out of time on $timeouts email${timeouts == 1 ? '' : 's'}. '
          'Look for the one decisive clue first.';
    }
    if (trusted > flagged) {
      return 'You kept $trusted deceptive post${trusted == 1 ? '' : 's'}. '
          'Check the decisive evidence before you keep something.';
    }
    if (flagged > trusted) {
      return 'You removed $flagged legitimate post${flagged == 1 ? '' : 's'}. '
          'Criticism, satire and honest opinions can be allowed.';
    }
    return 'You made mistakes in both directions: keeping deceptive posts and '
        'removing legitimate ones. Slow down and check the source.';
  }
}