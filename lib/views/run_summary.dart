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
    if (weakest.isEmpty && pattern == null) {
      return Text('Clean run: no mistakes to review. Nice work!',
          style: captionText(14, color: coal, weight: FontWeight.w800));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('RUN SUMMARY', style: typewriter(11, color: coal)),
      const SizedBox(height: 4),
      Text('${stats.correct} of ${stats.answered} rounds correct',
          style: captionText(14.5, color: coal, weight: FontWeight.w700)),
      if (pattern != null) ...[
        const SizedBox(height: 8),
        Text('YOUR PATTERN', style: typewriter(11, color: coal)),
        const SizedBox(height: 4),
        Text(pattern, style: captionText(14.5, color: coal)),
      ],
      if (weakest.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text('PRACTICE THESE', style: typewriter(11, color: coal)),
        const SizedBox(height: 4),
        for (final s in weakest)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• ${s.concept.label} (missed ${s.missed} of ${s.seen})',
              style: captionText(14, color: coal, weight: FontWeight.w700)),
          ),
      ],
    ]);
  }
}