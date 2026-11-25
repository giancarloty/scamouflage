import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/models/arcade_models.dart';
import 'package:scamouflage/models/round_record.dart';
import 'package:scamouflage/models/run_stats.dart';

RoundRecord _record({
  ArcadeMode mode = ArcadeMode.trust,
  bool correct = false,
  ErrorKind error = ErrorKind.other,
}) => RoundRecord(
  mode: mode,
  scenario: 'Test scenario',
  concepts: const [],
  correct: correct,
  error: error,
);

void main() {
  group('RunStats error feedback', () {
    test('clean runs have no mistake pattern', () {
      expect(const RunStats([]).errorPattern, isNull);
      expect(
        RunStats([_record(correct: true, error: ErrorKind.none)]).errorPattern,
        isNull,
      );
    });

    test('other mistakes get guidance for the mode with most misses', () {
      final stats = RunStats([
        _record(mode: ArcadeMode.impostor),
        _record(mode: ArcadeMode.impostor),
        _record(mode: ArcadeMode.rumor),
      ]);

      expect(stats.errorPattern, contains('IMPOSTOR HUNT'));
      expect(stats.errorPattern, contains('Compare both handles'));
    });

    test('trust mistakes in both directions get balanced feedback', () {
      final stats = RunStats([
        _record(error: ErrorKind.trustedBad),
        _record(correct: false, error: ErrorKind.flaggedGood),
      ]);

      expect(stats.errorPattern, contains('both directions'));
      expect(stats.errorPattern, contains('legitimate ones'));
    });

    test('inbox timeouts are described as timed-out items in a round', () {
      final stats = RunStats([
        _record(mode: ArcadeMode.inbox, error: ErrorKind.timeout),
      ]);

      expect(stats.errorPattern, contains('inbox item in 1 round'));
      expect(stats.errorPattern, contains('Check the sender'));
    });
  });
}
