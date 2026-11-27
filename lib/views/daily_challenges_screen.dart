import 'package:flutter/material.dart';

import '../controllers/daily_challenge_controller.dart';
import '../models/daily_challenge.dart';

/// A standalone Daily Challenges screen.
/// Pass an initialized controller; the screen refreshes its display via
/// ChangeNotifier and does not own/dispose the controller.
class DailyChallengesScreen extends StatelessWidget {
  final DailyChallengeController controller;
  final VoidCallback? onBack;

  const DailyChallengesScreen({
    super.key,
    required this.controller,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.ready) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF071B2C),
          appBar: AppBar(
            backgroundColor: const Color(0xFF071B2C),
            foregroundColor: Colors.white,
            title: const Text('DAILY CHALLENGES'),
            leading: onBack == null
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _summaryCard(),
                const SizedBox(height: 14),
                ...controller.challenges.map(_challengeCard),
                const SizedBox(height: 12),
                if (controller.challenges.any((c) => c.canClaim))
                  FilledButton.icon(
                    onPressed: () async {
                      final xp = await controller.claimAll();
                      if (!context.mounted || xp == 0) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Claimed $xp XP!')),
                      );
                    },
                    icon: const Icon(Icons.redeem),
                    label: const Text('CLAIM ALL AVAILABLE REWARDS'),
                  ),
                const SizedBox(height: 8),
                const Text(
                  'Missions refresh when the local calendar date changes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryCard() {
    final count = controller.completedCount;
    final total = controller.challenges.length;
    return Card(
      color: const Color(0xFF12344A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "TODAY'S MISSIONS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$count / $total completed',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: total == 0 ? 0 : count / total,
              minHeight: 8,
              backgroundColor: Colors.white12,
              color: const Color(0xFF57D6B5),
            ),
            const SizedBox(height: 8),
            Text(
              'Up to ${controller.totalRewardXp} bonus XP',
              style: const TextStyle(color: Color(0xFFFFD166)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _challengeCard(DailyChallenge challenge) {
    final fraction = challenge.target == 0
        ? 0.0
        : challenge.progress / challenge.target;
    final status = challenge.claimed
        ? 'REWARD CLAIMED'
        : challenge.completed
        ? 'COMPLETED — CLAIM XP'
        : '${challenge.progress} / ${challenge.target}';

    return Card(
      color: const Color(0xFF102B40),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    challenge.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '+${challenge.rewardXp} XP',
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              challenge.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0).toDouble(),
              backgroundColor: Colors.white12,
              color: challenge.completed
                  ? const Color(0xFF57D6B5)
                  : const Color(0xFF56A9E0),
              minHeight: 7,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    status,
                    style: TextStyle(
                      color: challenge.completed
                          ? const Color(0xFF57D6B5)
                          : Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (challenge.canClaim)
                  TextButton(
                    onPressed: () async {
                      await controller.claimReward(challenge.id);
                    },
                    child: const Text('CLAIM'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
