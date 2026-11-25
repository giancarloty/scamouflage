import 'package:flutter/material.dart';
import '../models/run_stats.dart';
import 'theme.dart';

/// Shown on the run-over screen. Only renders; all numbers come from [stats].
class RunSummary extends StatelessWidget {
  final RunStats stats;
  const RunSummary({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final weakest = stats.weakest();
    final pattern = stats.errorPattern;
    final accuracy = stats.answered == 0
        ? 0
        : (stats.correct * 100 / stats.answered).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RUN SUMMARY', style: typewriter(11, color: coal)),
        const SizedBox(height: 4),
        Text(
          '${stats.correct} of ${stats.answered} rounds correct ($accuracy%)',
          style: captionText(14.5, color: coal, weight: FontWeight.w700),
        ),
        if (stats.answered == 0) ...[
          const SizedBox(height: 8),
          Text(
            'No rounds recorded yet.',
            style: captionText(14, color: coal, weight: FontWeight.w800),
          ),
        ] else if (stats.misses.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Clean run: no mistakes to review. Nice work!',
            style: captionText(14, color: coal, weight: FontWeight.w800),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text('MISTAKE PATTERN', style: typewriter(11, color: coal)),
          const SizedBox(height: 4),
          Text(
            pattern ?? 'Review the evidence and try a different approach.',
            style: captionText(14.5, color: coal),
          ),
        ],
        if (weakest.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('CONCEPTS TO REVIEW', style: typewriter(11, color: coal)),
          const SizedBox(height: 4),
          for (final s in weakest)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${s.concept.label} (missed ${s.missed} of ${s.seen})',
                style: captionText(14, color: coal, weight: FontWeight.w700),
              ),
            ),
        ],
      ],
    );
  }
}
