import 'arcade_models.dart';

/// What happened in one answered round. Immutable.
class RoundRecord {
  final ArcadeMode mode;
  final String scenario;
  final List<Concept> concepts;
  final bool correct;
  final ErrorKind error;
  const RoundRecord({
    required this.mode,
    required this.scenario,
    required this.concepts,
    required this.correct,
    required this.error,
  });
}
