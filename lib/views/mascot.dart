import 'package:flutter/material.dart';
import '../controllers/engine.dart';
import '../models/player_progression.dart';
import 'theme.dart';

/// Palette of original mascot skins; players unlock them with Career XP.
class MascotPalette {
  static const Map<String, Color> colors = {
    'mint': mint,
    'sky': Color(0xFF89D7F4),
    'rose': Color(0xFFFFA7A7),
    'sunny': Color(0xFFFFD676),
    'violet': Color(0xFFC6AAFF),
    'pink': Color(0xFFFFB9DE),
    'teal': Color(0xFF72D7C8),
    'ice': Color(0xFFC0EDF4),
    'ember': Color(0xFFF7A178),
    'gold': Color(0xFFFFE398),
  };
  static Color forId(String id) => colors[id] ?? mint;
}

class MascotAvatar extends StatelessWidget {
  final GameEngine game;
  final double size;
  final int? level;
  const MascotAvatar({super.key, required this.game, this.size = 132, this.level});
  @override Widget build(BuildContext context) => Semantics(
    label: '${game.mascotName}, level ${level ?? game.careerRank.level} mascot',
    image: true,
    child: ChameleonDetective(
      size: size, level: level ?? game.careerRank.level,
      bodyColor: MascotPalette.forId(game.equippedMascotColorId)),
  );
}

/// A celebration shown after the game awards enough XP to cross a rank.
Future<void> showLevelUpCelebration(BuildContext context,
    GameEngine game, int level) async {
  final rank = CareerProgression.ranks[level - 1];
  await showDialog<void>(
    context: context, barrierDismissible: true,
    builder: (dialogContext) => Dialog(
      backgroundColor: deskBlue,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: mustard, width: 3)),
      child: SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.auto_awesome_rounded, size: 35, color: mustard),
          const SizedBox(height: 6),
          Text('LEVEL UP!', style: titleText(32, color: mustard)),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: .75, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.elasticOut,
            builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
            child: MascotAvatar(game: game, level: level, size: 150),
          ),
          const SizedBox(height: 9),
          Text('LEVEL $level — ${rank.title}',
            style: titleText(23, color: paperWhite), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(rank.description,
            style: captionText(14, color: parchment), textAlign: TextAlign.center),
          const SizedBox(height: 9),
          Text('New titles, colors and mascot names are waiting in Profile!',
            style: captionText(12, color: blue), textAlign: TextAlign.center),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: mustard, foregroundColor: coal),
            onPressed: () => Navigator.pop(dialogContext),
            icon: const Icon(Icons.celebration_rounded),
            label: const Text('AWESOME!'),
          )),
        ]),
      )),
    ),
  );
}

// Mascot illustrations live with the avatar rather than a separate tiny feature.

class ChameleonDetective extends StatelessWidget {
  final double size;
  final int level;
  final Color bodyColor;
  const ChameleonDetective({super.key, this.size = 186,
    this.level = 1, this.bodyColor = mint});
  @override Widget build(BuildContext context) => SizedBox(width: size, height: size,
    child: CustomPaint(painter: _ChameleonPainter(level: level, bodyColor: bodyColor)));

}
class _ChameleonPainter extends CustomPainter {
  final int level;
  final Color bodyColor;
  const _ChameleonPainter({required this.level, required this.bodyColor});
  @override void paint(Canvas canvas, Size s) {
    canvas.save();
    canvas.scale(s.width / 220, s.height / 220);
    final outline = Paint()..color = stroke..strokeWidth = 5..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round;
    final green = Paint()..color = bodyColor;
    final cream = Paint()..color = parchment;
    final hat = Paint()..color = switch (level) {
      2 => const Color(0xFF2D6683),
      3 => const Color(0xFF5E4772),
      4 => const Color(0xFF358271),
      5 => const Color(0xFF6A5A36),
      6 => const Color(0xFF8A3D5E),
      7 => const Color(0xFF3B657F),
      8 => const Color(0xFF29446A),
      9 => const Color(0xFF3D3D7A),
      10 => const Color(0xFF9F701C),
      _ => deskBlue,
    };
    // Comically curled tail.
    final tail = Path()..moveTo(147, 162)..cubicTo(218, 140, 217, 210, 178, 204)..cubicTo(150, 195, 173, 169, 191, 188);
    canvas.drawPath(tail, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 23..strokeCap = StrokeCap.round);
    canvas.drawPath(tail, Paint()..color = bodyColor..style = PaintingStyle.stroke..strokeWidth = 17..strokeCap = StrokeCap.round);
    for (final x in [64.0, 122.0]) {
      canvas.drawOval(Rect.fromLTWH(x, 171, 40, 26), green);
      canvas.drawOval(Rect.fromLTWH(x, 171, 40, 26), outline);
    }
    canvas.drawOval(const Rect.fromLTWH(58, 91, 109, 94), green);
    canvas.drawOval(const Rect.fromLTWH(58, 91, 109, 94), outline);
    canvas.drawOval(const Rect.fromLTWH(85, 139, 56, 37), cream);
    canvas.drawOval(const Rect.fromLTWH(37, 125, 47, 39), green);
    canvas.drawOval(const Rect.fromLTWH(37, 125, 47, 39), outline);
    canvas.drawOval(const Rect.fromLTWH(145, 127, 34, 34), green);
    canvas.drawOval(const Rect.fromLTWH(145, 127, 34, 34), outline);
    canvas.drawOval(const Rect.fromLTWH(43, 56, 130, 103), green);
    canvas.drawOval(const Rect.fromLTWH(43, 56, 130, 103), outline);
    for (final x in [67.0, 119.0]) {
      canvas.drawOval(Rect.fromLTWH(x, 67, 41, 43), cream);
      canvas.drawOval(Rect.fromLTWH(x, 67, 41, 43), outline);
      canvas.drawOval(Rect.fromLTWH(x + 17, 82, 14, 20), Paint()..color = stroke);
      canvas.drawCircle(Offset(x + 26, 88), 3, cream);
    }
    canvas.drawOval(const Rect.fromLTWH(66, 107, 28, 15), Paint()..color = coral.withValues(alpha: .65));
    canvas.drawOval(const Rect.fromLTWH(128, 107, 28, 15), Paint()..color = coral.withValues(alpha: .65));
    final smile = Path()..moveTo(100, 120)..quadraticBezierTo(113, 133, 128, 120);
    canvas.drawPath(smile, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round);
    // Detective cap.
    final brim = Path()..moveTo(53, 71)..lineTo(66, 34)..quadraticBezierTo(108, 12, 151, 38)..lineTo(165, 74)..close();
    canvas.drawPath(brim, hat); canvas.drawPath(brim, outline);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(51, 60, 116, 16), const Radius.circular(6)), Paint()..color = stroke);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(68, 48, 78, 9), const Radius.circular(5)), Paint()..color = mustard);
    // Magnifying glass.
    canvas.drawLine(const Offset(33, 131), const Offset(11, 166), Paint()..color = stroke..strokeWidth = 13..strokeCap = StrokeCap.round);
    canvas.drawLine(const Offset(33, 131), const Offset(11, 166), Paint()..color = coral..strokeWidth = 7..strokeCap = StrokeCap.round);
    canvas.drawCircle(const Offset(37, 111), 27, Paint()..color = blue.withValues(alpha: .7));
    canvas.drawCircle(const Offset(37, 111), 27, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 6);
    canvas.drawArc(const Rect.fromLTWH(25, 99, 22, 22), 3.7, 1.7, false, Paint()..color = paperWhite..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawCircle(const Offset(195, 73), 7, Paint()..color = mustard);
    _drawLevelGear(canvas);
    canvas.restore();
  }
  void _drawLevelGear(Canvas canvas) {
    final edge = Paint()..color = stroke..strokeWidth = 3
      ..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round;
    final gold = Paint()..color = mustard;
    final cyan = Paint()..color = blue;
    final rose = Paint()..color = pink;
    // Each rank has a different cap detail and investigator tool/costume.
    switch (level) {
      case 1: // Rookie: tiny rookie star on the cap
        canvas.drawCircle(const Offset(110, 55), 6, gold);
        break;
      case 2: // Link Sleuth: linked rings on the hat and wrist
        canvas.drawCircle(const Offset(99, 55), 8, edge);
        canvas.drawCircle(const Offset(116, 55), 8, edge);
        canvas.drawLine(const Offset(105, 55), const Offset(110, 55),
          Paint()..color = mustard..strokeWidth = 4);
        break;
      case 3: // Scam Detective: gold detective badge
        _shield(canvas, const Offset(113, 52), 17, mustard);
        break;
      case 4: // Fact Finder: pocket notebook and pencil
        canvas.drawRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(143, 131, 32, 42), const Radius.circular(4)),
          Paint()..color = blue);
        canvas.drawRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(143, 131, 32, 42), const Radius.circular(4)), edge);
        for (final y in [142.0, 150.0, 158.0]) {
          canvas.drawLine(Offset(150, y), Offset(169, y), Paint()..color = stroke..strokeWidth = 2);
        }
        break;
      case 5: // Source Scout: explorer compass on the cap
        canvas.drawCircle(const Offset(108, 54), 13, gold);
        canvas.drawCircle(const Offset(108, 54), 13, edge);
        final needle = Path()..moveTo(108, 42)..lineTo(115, 61)..lineTo(103, 57)..close();
        canvas.drawPath(needle, Paint()..color = coral);
        break;
      case 6: // Newsroom Analyst: press credential and ink feather
        canvas.drawRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(139, 135, 34, 29), const Radius.circular(5)),
          Paint()..color = paperWhite);
        canvas.drawRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(139, 135, 34, 29), const Radius.circular(5)), edge);
        canvas.drawRect(const Rect.fromLTWH(143, 141, 26, 6), Paint()..color = coral);
        canvas.drawLine(const Offset(145, 153), const Offset(166, 153), edge);
        break;
      case 7: // Verification Expert: digital visor
        canvas.drawRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(63, 79, 106, 28), const Radius.circular(12)),
          Paint()..color = cyan.color.withValues(alpha: .45));
        canvas.drawRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(63, 79, 106, 28), const Radius.circular(12)), edge);
        canvas.drawCircle(const Offset(157, 87), 4, Paint()..color = mint);
        break;
      case 8: // Digital Sentinel: defender shield on chest
        _shield(canvas, const Offset(118, 149), 33, blue);
        canvas.drawLine(const Offset(107, 148), const Offset(116, 157),
          Paint()..color = stroke..strokeWidth = 4);
        canvas.drawLine(const Offset(116, 157), const Offset(131, 140),
          Paint()..color = stroke..strokeWidth = 4);
        break;
      case 9: // Cyber Guardian: glowing circuit crown and armor
        canvas.drawLine(const Offset(72, 47), const Offset(86, 37),
          Paint()..color = blue..strokeWidth = 5..strokeCap = StrokeCap.round);
        canvas.drawLine(const Offset(86, 37), const Offset(124, 37),
          Paint()..color = blue..strokeWidth = 5);
        canvas.drawLine(const Offset(124, 37), const Offset(138, 47),
          Paint()..color = blue..strokeWidth = 5);
        for (final x in [86.0, 124.0]) {
          canvas.drawCircle(Offset(x, 37), 5, rose);
        }
        canvas.drawRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(86, 145, 49, 18), const Radius.circular(6)), cyan);
        break;
      case 10: // Truth Legend: crown, star and golden cape
        final cape = Path()..moveTo(165, 129)..quadraticBezierTo(209, 130, 198, 192)
          ..lineTo(160, 179)..close();
        canvas.drawPath(cape, Paint()..color = mustard);
        canvas.drawPath(cape, edge);
        final crown = Path()..moveTo(69, 48)..lineTo(72, 19)
          ..lineTo(88, 32)..lineTo(108, 9)..lineTo(128, 32)
          ..lineTo(149, 19)..lineTo(152, 48)..close();
        canvas.drawPath(crown, gold);
        canvas.drawPath(crown, edge);
        canvas.drawCircle(const Offset(108, 29), 6, rose);
        _shield(canvas, const Offset(115, 150), 31, mustard);
        break;
      default:
        break;
    }
  }

  void _shield(Canvas canvas, Offset at, double size, Color color) {
    final path = Path()..moveTo(at.dx, at.dy - size * .6)
      ..lineTo(at.dx + size * .48, at.dy - size * .37)
      ..lineTo(at.dx + size * .38, at.dy + size * .24)
      ..quadraticBezierTo(at.dx, at.dy + size * .78, at.dx - size * .38, at.dy + size * .24)
      ..lineTo(at.dx - size * .48, at.dy - size * .37)..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(path, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 3);
  }
  @override bool shouldRepaint(covariant _ChameleonPainter oldDelegate) =>
    oldDelegate.level != level || oldDelegate.bodyColor != bodyColor;
}

class CaseArtwork extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String label;
  final double height;
  const CaseArtwork({super.key, required this.icon, required this.tint, required this.label, this.height = 150});
  @override Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [tint, deskBlue]),
      ),
      child: Stack(children: [
        Positioned(top: -25, right: -30, child: Icon(icon, size: 176, color: parchment.withValues(alpha: .15))),
        Center(child: Icon(icon, size: 77, color: paperWhite)),
        Positioned(bottom: 12, left: 13, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: paperWhite, borderRadius: BorderRadius.circular(6)),
          child: Text(label, style: typewriter(9, color: inkColor)),
        )),
      ]),
    ),
  );
}
const inkColor = coal;
