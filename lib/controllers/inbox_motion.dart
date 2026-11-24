import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pure, testable swipe rules for Inbox Sprint.
/// 0 = SPAM (left), 1 = KEEP (right), null = return to centre.
int? inboxSwipeVerdict({
  required double displacement,
  required double velocity,
  required double viewportWidth,
}) {
  final threshold = (viewportWidth * .23).clamp(72.0, 126.0);
  if (displacement.abs() >= threshold) {
    return displacement < 0 ? 0 : 1;
  }
  // A flick must already have moved the card in the flick's direction.
  // This prevents a vertical scroll or accidental touch from sorting mail.
  if (displacement.abs() >= 24 &&
      velocity.abs() >= 650 &&
      displacement * velocity > 0) {
    return displacement < 0 ? 0 : 1;
  }
  return null;
}

/// Gradual, pale whole-card colour feedback while following a finger.
/// Never colours the card when it is centred; avoids floating verdict stamps.
Color inboxSwipeTint({
  required Color base,
  required double displacement,
  required double viewportWidth,
}) {
  if (displacement == 0) return base;
  final distance = math.max(100.0, viewportWidth * .34);
  final fraction = (displacement.abs() / distance).clamp(0.0, 1.0);
  final eased = Curves.easeOutCubic.transform(fraction);
  final tint = displacement < 0
      ? const Color(0xFFFFCFD5)
      : const Color(0xFFC9F2DB);
  return Color.lerp(base, tint, eased * .84)!;
}

Color inboxSwipeBorder({
  required Color base,
  required double displacement,
  required double viewportWidth,
}) {
  if (displacement == 0) return base;
  final fraction = (displacement.abs() / math.max(100.0, viewportWidth * .34))
      .clamp(0.0, 1.0);
  final tint = displacement < 0
      ? const Color(0xFFC9495B)
      : const Color(0xFF278259);
  return Color.lerp(base, tint, fraction * .7)!;
}
