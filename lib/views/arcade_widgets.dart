import 'package:flutter/material.dart';
import 'theme.dart';

/// Colour rules for every arcade decision.
///  green  = KEEP / ALLOW / BOTH OK      red = REMOVE / FLAG / SPAM
///  orange, pink and blue = all other (neutral) choices.
const keepColor = Color(0xFF7FE3A6);
const removeColor = Color(0xFFFF7D7D);
const choiceOrange = Color(0xFFFFB36D);
const choicePink = Color(0xFFFFB1D3);
const choiceBlue = Color(0xFFA3D6F6);
const chipFill = Color(0xFFE3ECF8);
const chipOpenFill = Color(0xFFC6D9F1);

typedef SubmitFn = void Function(List<int> answer, bool usedDecisive,
    {List<String> opened});

/// White "paper" card used for every case surface.
class Paper extends StatelessWidget {
  final Widget child;
  final Color fill;
  final EdgeInsets padding;
  const Paper({super.key, required this.child, this.fill = paperWhite,
    this.padding = const EdgeInsets.all(14)});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: padding,
    decoration: BoxDecoration(color: fill,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: stroke, width: 2)),
    child: child,
  );
}

Widget onPaper(String text, {double size = 15, FontWeight? weight}) => Text(
  text, style: captionText(size, color: coal,
    weight: weight ?? FontWeight.w600));

/// Draws a soft pulsing glow around [child] while [active].
class Pulse extends StatefulWidget {
  final bool active;
  final Widget child;
  final double radius;
  const Pulse({super.key, required this.active, required this.child,
    this.radius = 14});
  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 900));
  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat(reverse: true);
  }
  @override
  void didUpdateWidget(Pulse old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) _c.repeat(reverse: true);
    if (!widget.active && _c.isAnimating) { _c.stop(); _c.value = 0; }
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(animation: _c, child: widget.child,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius + 3),
          boxShadow: [BoxShadow(
            color: mustard.withValues(alpha: .35 + .45 * _c.value),
            blurRadius: 6 + 12 * _c.value, spreadRadius: 1 + 3 * _c.value)]),
        child: child));
  }
}

/// Chief's short coaching line for the first-day tutorial.
class CoachBanner extends StatelessWidget {
  final String text;
  const CoachBanner(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(color: const Color(0xFFFFF1CC),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: mustard, width: 2)),
    child: Row(children: [
      const Text('🦎', style: TextStyle(fontSize: 24)),
      const SizedBox(width: 10),
      Expanded(child: Text(text,
        style: captionText(15, color: coal, weight: FontWeight.w800))),
    ]),
  );
}

class ArcadeButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  final bool glow;
  const ArcadeButton(this.label, {super.key, required this.color,
    required this.onTap, this.icon = Icons.arrow_forward_rounded,
    this.glow = false});
  @override
  Widget build(BuildContext context) => Pulse(active: glow && onTap != null,
    child: Opacity(opacity: onTap == null ? .45 : 1,
      child: Material(color: Colors.transparent, child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(13),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(color: color,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: stroke, width: 2),
            boxShadow: const [BoxShadow(color: stroke, offset: Offset(0, 3))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(child: Text(label, textAlign: TextAlign.center,
              maxLines: 3, overflow: TextOverflow.ellipsis,
              style: captionText(14, color: coal, weight: FontWeight.w800))),
            const SizedBox(width: 6),
            Icon(icon, size: 20, color: coal),
          ]),
        ),
      ))));
}

/// Docked action area. Content above scrolls; this stays reachable.
class ActionBar extends StatelessWidget {
  final Widget child;
  const ActionBar({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
    decoration: const BoxDecoration(color: deskBlue,
      border: Border(top: BorderSide(color: deskLight, width: 2))),
    child: SafeArea(top: false, child: child),
  );
}

/// Scrolling body + docked action bar, the layout every mode shares.
class ModeFrame extends StatelessWidget {
  final List<Widget> body;
  final Widget actions;
  const ModeFrame({super.key, required this.body, required this.actions});
  @override
  Widget build(BuildContext context) => Column(children: [
    Expanded(child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: body)),
      ))),
    ActionBar(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 540), child: actions))),
  ]);
}

/// Neutral inspection button. Looks identical whatever the result is.
class ToolChip extends StatelessWidget {
  final String emoji, label;
  final bool opened, enabled, glow;
  final VoidCallback onTap;
  const ToolChip({super.key, required this.emoji, required this.label,
    required this.opened, required this.enabled, required this.onTap,
    this.glow = false});
  @override
  Widget build(BuildContext context) => Pulse(active: glow && !opened,
    radius: 12,
    child: Opacity(opacity: enabled || opened ? 1 : .4,
      child: Material(color: Colors.transparent, child: InkWell(
        onTap: enabled || opened ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
          decoration: BoxDecoration(
            color: opened ? chipOpenFill : chipFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: stroke, width: 1.8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(label, style: captionText(12.5, color: coal,
              weight: FontWeight.w800)),
            if (opened) ...[const SizedBox(width: 5),
              const Icon(Icons.check_rounded, size: 15, color: coal)],
          ]),
        ),
      ))));
}

/// One opened result in the notebook. Same look for every result.
class FindingCard extends StatelessWidget {
  final String emoji, label, text;
  const FindingCard({super.key, required this.emoji, required this.label,
    required this.text});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: chipFill,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: stroke, width: 1.6)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$emoji  $label', style: typewriter(11, color: coal)),
      const SizedBox(height: 5),
      Text(text, style: captionText(14.5, color: coal)),
    ]),
  );
}

Widget sectionLabel(String text, {Color color = blue, Widget? trailing}) =>
  Padding(padding: const EdgeInsets.only(top: 14, bottom: 8),
    child: Row(children: [
      Expanded(child: Text(text, style: typewriter(12, color: color))),
      if (trailing != null) trailing,
    ]));

Widget emptyNote(String text) => Container(
  width: double.infinity, padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(color: deskBlue,
    borderRadius: BorderRadius.circular(13),
    border: Border.all(color: deskLight, width: 1.6)),
  child: Text(text, textAlign: TextAlign.center,
    style: captionText(13.5, color: paperWhite)));

/// Readable bottom sheet for details that do not fit on a card.
Future<void> showDetailSheet(BuildContext context,
    {required String title, required List<Widget> children}) {
  return showModalBottomSheet<void>(
    context: context, isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final h = MediaQuery.sizeOf(ctx).height;
      return Container(
        constraints: BoxConstraints(maxHeight: h * .78),
        decoration: const BoxDecoration(color: paperWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: stroke, width: 3))),
        child: SafeArea(top: false, child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(child: Text(title,
                  style: titleText(22, color: coal))),
                IconButton(onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: coal)),
              ]),
              const SizedBox(height: 6),
              ...children,
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: ArcadeButton('GOT IT',
                color: mustard, icon: Icons.check_rounded,
                onTap: () => Navigator.pop(ctx))),
            ]),
        )),
      );
    });
}
