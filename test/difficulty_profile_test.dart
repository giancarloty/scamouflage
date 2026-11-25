import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/models/arcade_models.dart';

void main() {
  group('Difficulty profiles', () {
    test('Easy is beginner-focused', () {
      final p = ArcadeDifficulty.easy.profile;
      expect(p.reasoningLevel, 1);
      expect(p.decoyClues, 0);
      expect(p.conflictingEvidence, 0);
      expect(p.requiresCrossChecking, false);
      expect(p.startingHearts, 5);
      expect(p.scanBudget, 5);
      expect(p.emailSeconds, isNull);
    });

    test('Medium adds a layer of reasoning', () {
      final p = ArcadeDifficulty.medium.profile;
      expect(p.reasoningLevel, 2);
      expect(p.decoyClues, 1);
      expect(p.conflictingEvidence, 1);
      expect(p.requiresCrossChecking, false);
      expect(p.startingHearts, 4);
      expect(p.scanBudget, 4);
      expect(p.emailSeconds, 14);
    });

    test('Hard prioritizes evidence cross-checking over time pressure', () {
      final p = ArcadeDifficulty.hard.profile;
      expect(p.reasoningLevel, 3);
      expect(p.decoyClues, 2);
      expect(p.conflictingEvidence, 2);
      expect(p.requiresCrossChecking, true);
      expect(p.startingHearts, 3);
      expect(p.scanBudget, 4);
      expect(p.emailSeconds, isNull);
    });
  });
}
