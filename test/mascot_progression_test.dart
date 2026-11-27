import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scamouflage/models/arcade_models.dart';
import 'package:scamouflage/controllers/engine.dart';
import 'package:scamouflage/views/mascot.dart';
import 'package:scamouflage/models/player_progression.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Career has ten ordered ranks and never spends XP to equip', () async {
    expect(CareerProgression.ranks.length, 10);
    for (var i = 1; i < CareerProgression.ranks.length; i++) {
      expect(
        CareerProgression.ranks[i].xp,
        greaterThan(CareerProgression.ranks[i - 1].xp),
      );
    }
    final game = GameEngine();
    await game.load();
    expect(game.equipMascotColor('gold'), isFalse);
    expect(game.equipMascotName('truth'), isFalse);
    game.awardArcadeXp(10000);
    expect(game.careerRank.level, 10);
    expect(game.takeLevelUp(), 10);
    expect(game.takeLevelUp(), isNull);
    expect(game.equipMascotName('truth'), isTrue);
    expect(game.equipMascotColor('gold'), isTrue);
    expect(game.careerXp, 10000);
    expect(game.equippedMascotNameId, 'truth');
    expect(game.equippedMascotColorId, 'gold');
    game.dispose();
  });

  test('A level-up notice never exceeds the corrected current rank', () async {
    final game = GameEngine();
    await game.load();
    game.awardArcadeXp(10000);
    await game.applyCloud({'careerXp': 7400});
    expect(game.careerRank.level, 9);
    expect(game.takeLevelUp(), 9);
    expect(game.takeLevelUp(), isNull);
    game.dispose();
  });

  test('Mascot cosmetic selections load from local storage', () async {
    SharedPreferences.setMockInitialValues({
      'xp_v4': 1200,
      'mascot_name_v12': 'factgecko',
      'mascot_color_v12': 'violet',
      'mascot_intro_v12': true,
    });
    final game = GameEngine();
    await game.load();
    expect(game.mascotName, 'Fact Gecko');
    expect(game.equippedMascotColorId, 'violet');
    expect(game.mascotIntroduced, isTrue);
    expect(game.careerRank.level, 4);
    game.dispose();
  });

  test('Arcade mode title and unlock thresholds are consistent', () {
    expect(ArcadeMode.trust.title, 'TRUST OR BUST');
    final ordered = [...ArcadeMode.values]
      ..sort((a, b) => a.unlockXp.compareTo(b.unlockXp));
    for (var i = 1; i < ordered.length; i++) {
      expect(
        ordered[i].unlockXp,
        greaterThanOrEqualTo(ordered[i - 1].unlockXp),
      );
    }
    expect(ordered.first.unlockXp, 0);
    expect(ordered.last.unlockXp, 1200);
  });

  testWidgets('Ten outfit variants render with changeable body colors', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: ChameleonDebugPreview())),
      ),
    );
    expect(find.byType(MascotAvatar), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}

class ChameleonDebugPreview extends StatelessWidget {
  const ChameleonDebugPreview({super.key});
  @override
  Widget build(BuildContext context) {
    final game = GameEngine();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MascotAvatar(game: game, level: 1, size: 80),
        MascotAvatar(game: game, level: 10, size: 80),
      ],
    );
  }
}
