import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/models/daily_challenge.dart';

void main() {
  group('DailyChallenge', () {
    test('progress completes at target and clamps', () {
      final challenge = DailyChallenge(
        id: 'test',
        title: 'Test',
        description: 'Test challenge',
        type: DailyChallengeType.correctAnswers,
        target: 3,
        rewardXp: 50,
      );

      challenge.addProgress(2);
      expect(challenge.completed, isFalse);
      challenge.addProgress(4);
      expect(challenge.progress, 3);
      expect(challenge.completed, isTrue);
      challenge.addProgress(1);
      expect(challenge.progress, 3);
    });

    test('json round trip preserves state', () {
      final original = DailyChallenge(
        id: 'test',
        title: 'Test',
        description: 'Test challenge',
        type: DailyChallengeType.perfectRounds,
        target: 2,
        rewardXp: 100,
        progress: 1,
      );

      final copy = DailyChallenge.fromJson(original.toJson());
      expect(copy.id, original.id);
      expect(copy.progress, original.progress);
      expect(copy.completed, original.completed);
    });
  });
}
