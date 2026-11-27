import 'package:flutter/foundation.dart';

import '../models/daily_challenge.dart';
import '../services/daily_challenge_service.dart';

/// Gameplay should call these methods when the corresponding event occurs.
/// This controller is independent from widgets and game-mode implementations.
class DailyChallengeController extends ChangeNotifier {
  final DailyChallengeService service;
  final void Function(int xp) awardXp;

  DailyChallengeController({
    DailyChallengeService? service,
    required this.awardXp,
  }) : service = service ?? DailyChallengeService();

  List<DailyChallenge> challenges = [];
  bool ready = false;
  int currentCorrectStreak = 0;

  int get completedCount => challenges.where((c) => c.completed).length;
  int get claimedCount => challenges.where((c) => c.claimed).length;
  int get totalRewardXp =>
      challenges.fold<int>(0, (sum, c) => sum + c.rewardXp);
  bool get allCompleted =>
      challenges.isNotEmpty && completedCount == challenges.length;

  Future<void> initialize() async {
    challenges = await service.loadOrCreateToday();
    currentCorrectStreak = await service.loadStreak();
    ready = true;
    notifyListeners();
  }

  Future<void> _persistAndNotify() async {
    await service.save(challenges, streak: currentCorrectStreak);
    notifyListeners();
  }

  void _add(DailyChallengeType type, [int amount = 1]) {
    for (final challenge in challenges) {
      if (challenge.type == type) challenge.addProgress(amount);
    }
  }

  /// Call for each submitted answer, with whether it was correct and whether
  /// the answer correctly identified a scam (not merely any correct answer).
  Future<void> onAnswer({
    required bool correct,
    bool correctlyIdentifiedScam = false,
  }) async {
    if (!ready) return;
    if (correct) {
      currentCorrectStreak++;
      _add(DailyChallengeType.correctAnswers);
      if (correctlyIdentifiedScam) {
        _add(DailyChallengeType.correctlyIdentifyScams);
      }
      _add(DailyChallengeType.correctStreak);
    } else {
      currentCorrectStreak = 0;
      // Streak missions track the current streak, so reset their progress.
      for (final challenge in challenges.where(
        (c) => c.type == DailyChallengeType.correctStreak && !c.completed,
      )) {
        challenge.resetProgress();
      }
    }
    await _persistAndNotify();
  }

  /// Call once when a round/game session is completed.
  Future<void> onRoundCompleted({required bool perfect}) async {
    if (!ready) return;
    _add(DailyChallengeType.completedRounds);
    if (perfect) _add(DailyChallengeType.perfectRounds);
    await _persistAndNotify();
  }

  /// Claim completed mission reward. Prevents duplicate XP claims.
  Future<bool> claimReward(String challengeId) async {
    if (!ready) return false;
    DailyChallenge? challenge;
    for (final item in challenges) {
      if (item.id == challengeId) {
        challenge = item;
        break;
      }
    }
    if (challenge == null || !challenge.canClaim) return false;

    challenge.claimed = true;
    awardXp(challenge.rewardXp);
    await _persistAndNotify();
    return true;
  }

  /// Claim all currently claimable rewards. Returns total XP awarded.
  Future<int> claimAll() async {
    if (!ready) return 0;
    var total = 0;
    for (final challenge in challenges) {
      if (challenge.canClaim) {
        challenge.claimed = true;
        total += challenge.rewardXp;
      }
    }
    if (total > 0) {
      awardXp(total);
      await _persistAndNotify();
    }
    return total;
  }

  Future<void> refreshForDateChange() async {
    final fresh = await service.loadOrCreateToday();
    challenges = fresh;
    currentCorrectStreak = await service.loadStreak();
    notifyListeners();
  }
}
