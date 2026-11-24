import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scamouflage/controllers/engine.dart';
import 'package:scamouflage/models/arcade_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Cumulative career XP persists and unlocks modes without spending XP', () async {
    final engine = GameEngine();
    await engine.load();
    expect(engine.arcadeUnlocked, false);
    await engine.finishArcadeIntro();
    expect(engine.arcadeUnlocked, true);
    expect(engine.arcadeModeUnlocked(300), false);
    engine.awardArcadeXp(300);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(engine.arcadeModeUnlocked(300), true);
    expect(engine.careerXp, 300);
    engine.dispose();
    final again = GameEngine();
    await again.load();
    expect(again.arcadeUnlocked, true);
    expect(again.careerXp, 300);
    again.dispose();
  });

  test('Every mode threshold is reachable from the engine XP', () async {
    final engine = GameEngine();
    await engine.load();
    await engine.finishArcadeIntro();
    engine.awardArcadeXp(1200);
    for (final mode in ArcadeMode.values) {
      expect(engine.arcadeModeUnlocked(mode.unlockXp), true);
    }
    engine.dispose();
  });

  test('One starting hint, and another every 50 cumulative Career XP', () async {
    final engine = GameEngine();
    await engine.load();
    expect(engine.hintsAvailable, 1);
    expect(engine.spendHint(), true);
    expect(engine.hintsAvailable, 0);
    expect(engine.spendHint(), false);
    engine.awardArcadeXp(49);
    expect(engine.hintsAvailable, 0);
    engine.awardArcadeXp(1);
    expect(engine.hintsAvailable, 1);
    expect(engine.spendHint(), true);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    engine.dispose();
    final restored = GameEngine();
    await restored.load();
    expect(restored.careerXp, 50);
    expect(restored.hintsAvailable, 0);
    restored.dispose();
  });

  test('Recent arcade signatures are remembered across sessions, capped at 15', () async {
    final engine = GameEngine();
    await engine.load();
    for (var i = 0; i < 20; i++) {
      engine.recordArcadeCase('case-$i');
    }
    expect(engine.arcadeHistory.length, 15);
    expect(engine.arcadeHistory.last, 'case-19');
    engine.dispose();
  });
}
