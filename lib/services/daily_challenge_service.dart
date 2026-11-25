import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_challenge.dart';

class DailyChallengeService {
  static const _storageKey = 'daily_challenges_v1';
  static const _dateKey = 'daily_challenges_date_v1';
  static const _streakKey = 'daily_challenges_streak_v1';

  static String dateStamp([DateTime? date]) {
    final now = date ?? DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  /// Deterministic mission selection: same local date produces same missions.
  List<DailyChallenge> generateForDate([DateTime? date]) {
    final stamp = dateStamp(date);
    final seed = stamp.codeUnits.fold<int>(0, (value, unit) => value * 31 + unit);
    final random = Random(seed);

    final pool = <DailyChallenge Function()>[
      () => DailyChallenge(
        id: 'phishing_hunter',
        title: 'Phishing Hunter',
        description: 'Correctly identify 5 scam attempts.',
        type: DailyChallengeType.correctlyIdentifyScams,
        target: 5,
        rewardXp: 100,
      ),
      () => DailyChallenge(
        id: 'sharp_detective',
        title: 'Sharp Detective',
        description: 'Get 3 correct answers in a row.',
        type: DailyChallengeType.correctStreak,
        target: 3,
        rewardXp: 75,
      ),
      () => DailyChallenge(
        id: 'clean_investigation',
        title: 'Clean Investigation',
        description: 'Complete 3 rounds without a mistake.',
        type: DailyChallengeType.perfectRounds,
        target: 3,
        rewardXp: 150,
      ),
      () => DailyChallenge(
        id: 'quick_learner',
        title: 'Quick Learner',
        description: 'Answer 8 questions correctly.',
        type: DailyChallengeType.correctAnswers,
        target: 8,
        rewardXp: 100,
      ),
      () => DailyChallenge(
        id: 'arcade_regular',
        title: 'Arcade Regular',
        description: 'Complete 5 rounds.',
        type: DailyChallengeType.completedRounds,
        target: 5,
        rewardXp: 125,
      ),
      () => DailyChallenge(
        id: 'truth_streak',
        title: 'Truth Streak',
        description: 'Get 5 answers correct in a row.',
        type: DailyChallengeType.correctStreak,
        target: 5,
        rewardXp: 175,
      ),
    ];

    // Select three distinct challenges with deterministic daily ordering.
    final shuffled = List<DailyChallenge Function()>.from(pool)..shuffle(random);
    return shuffled.take(3).map((make) => make()).toList();
  }

  Future<List<DailyChallenge>> loadOrCreateToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = dateStamp();
    final savedDate = prefs.getString(_dateKey);
    if (savedDate == today) {
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        try {
          final decoded = jsonDecode(raw) as List<dynamic>;
          return decoded
              .map((entry) => DailyChallenge.fromJson(
                    Map<String, dynamic>.from(entry as Map),
                  ))
              .toList();
        } catch (_) {
          // Corrupt or incompatible save: create today's clean set.
        }
      }
    }

    final challenges = generateForDate();
    await save(challenges, date: today);
    return challenges;
  }

  Future<int> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> save(List<DailyChallenge> challenges, {String? date, int streak = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dateKey, date ?? dateStamp());
    await prefs.setInt(_streakKey, streak);
    await prefs.setString(
      _storageKey,
      jsonEncode(challenges.map((challenge) => challenge.toJson()).toList()),
    );
  }
}
