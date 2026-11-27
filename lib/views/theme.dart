import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const midnight = Color(0xFF131B2D);
const deskBlue = Color(0xFF21324A);
const deskLight = Color(0xFF304965);
const parchment = Color(0xFFFFF4DA);
const paperWhite = Color(0xFFFFFCF3);
const coal = Color(0xFF263243);
const mutedInk = Color(0xFF677286);
const coral = Color(0xFFFB7D71);
const mustard = Color(0xFFFFC55D);
const mint = Color(0xFF9EEDC6);
const blue = Color(0xFF84C8F0);
const pink = Color(0xFFFFC1DD);
const stroke = Color(0xFF17253A);

TextStyle titleText(double size, {Color color = parchment}) =>
    GoogleFonts.fredoka(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -.7,
      height: 1.05,
    );
TextStyle captionText(
  double size, {
  Color color = parchment,
  FontWeight weight = FontWeight.w600,
}) => GoogleFonts.spaceGrotesk(
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: 1.32,
);
TextStyle typewriter(double size, {Color color = coal}) =>
    GoogleFonts.spaceMono(
      fontSize: size < 11 ? 11 : size,
      color: color,
      fontWeight: FontWeight.w700,
      letterSpacing: .5,
    );

class InkTag extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const InkTag(this.text, {super.key, this.color = mustard, this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: stroke, width: 1.6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: stroke),
          const SizedBox(width: 5),
        ],
        Text(text, style: typewriter(10, color: stroke)),
      ],
    ),
  );
}

class GameButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData icon;
  final Color color;
  final bool outlined;
  final bool compact;
  const GameButton(
    this.label, {
    super.key,
    required this.onTap,
    this.icon = Icons.arrow_forward_rounded,
    this.color = mustard,
    this.outlined = false,
    this.compact = false,
  });
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onTap == null ? .45 : 1,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 18,
            vertical: compact ? 11 : 15,
          ),
          decoration: BoxDecoration(
            color: outlined ? midnight : color,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: outlined ? color : stroke, width: 2.2),
            boxShadow: const [BoxShadow(color: stroke, offset: Offset(2, 3))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: captionText(
                    compact ? 12 : 14,
                    color: outlined ? color : stroke,
                    weight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 7),
              Icon(
                icon,
                size: compact ? 18 : 20,
                color: outlined ? color : stroke,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class Stamp extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const Stamp({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: text,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: stroke, width: 2.2),
            boxShadow: const [BoxShadow(color: stroke, offset: Offset(2, 3))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: paperWhite, size: 24),
              const SizedBox(height: 3),
              Text(
                text,
                style: typewriter(11, color: paperWhite),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class DeskBackdrop extends StatelessWidget {
  final Widget child;
  const DeskBackdrop({super.key, required this.child});
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: midnight),
    child: Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: DeskGridPainter())),
        child,
      ],
    ),
  );
}

class DeskGridPainter extends CustomPainter {
  const DeskGridPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = deskBlue.withValues(alpha: .5)
      ..strokeWidth = .8;
    for (double x = 0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ParchmentSheet extends StatelessWidget {
  final Widget child;
  final Color fill;
  final EdgeInsets padding;
  const ParchmentSheet({
    super.key,
    required this.child,
    this.fill = parchment,
    this.padding = const EdgeInsets.all(17),
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: stroke, width: 2),
      boxShadow: const [
        BoxShadow(color: stroke, blurRadius: 0, offset: Offset(4, 5)),
      ],
    ),
    child: child,
  );
}

// Responsive UI utilities grouped with presentation styling.

/// Screen dimensions are logical pixels, not the device's physical pixels.
/// A 320px iPhone SE-sized viewport is the smallest supported portrait target.
class PhoneLayout {
  const PhoneLayout._();

  static bool compact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 390;
  static bool narrow(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 355;
  static bool short(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 700;

  static double footerLimit(
    BuildContext context, {
    bool multipleChoices = false,
  }) {
    final height = MediaQuery.sizeOf(context).height;
    return (height * (multipleChoices ? .36 : .27))
        .clamp(116.0, multipleChoices ? 250.0 : 180.0)
        .toDouble();
  }
}

/// Modal content remains visible on short phone screens and when text scaling
/// is increased. The dialog scrolls internally rather than overflowing.
class PhoneDialog extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final ShapeBorder? shape;

  const PhoneDialog({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final availableHeight = math.max(180.0, size.height - keyboard - 46);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: backgroundColor,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 440, maxHeight: availableHeight),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
