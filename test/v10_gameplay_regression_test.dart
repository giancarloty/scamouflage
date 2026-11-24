import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scamouflage/controllers/engine.dart';
import 'package:scamouflage/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Career shifts unlock in numbered order, even with grade C', () async {
    final game = GameEngine();
    await game.load();
    await game.skipTutorial();
    expect(game.unlockedShift, 1);
    game.startShift(2);
    expect(game.inShift, isFalse);

    game.startShift(1);
    expect(game.shiftNumber, 1);
    for (var i = 0; game.inShift && i < 20; i++) {
      final wrong = game.currentCase.correct == Verdict.approve
        ? Verdict.reject : Verdict.approve;
      game.decide(wrong);
      game.next();
    }
    expect(game.finished, isTrue);
    expect(game.grade, 'C');
    expect(game.unlockedShift, 2);

    game.startShift(2);
    expect(game.shiftNumber, 2);
    expect(game.inShift, isTrue);
    for (var i = 0; game.inShift && i < 20; i++) {
      game.decide(game.currentCase.correct);
      game.next();
    }
    expect(game.unlockedShift, 3);
    game.dispose();
  });

  test('Reading a source note cannot farm extra XP', () async {
    final game = GameEngine();
    await game.load();
    await game.skipTutorial();
    game.startShift(1);
    final caseFile = game.currentCase;
    final check = game.verify();
    expect(check, isNotNull);
    expect(game.shiftXp, 0);
    final result = game.decide(caseFile.correct);
    final base = caseFile.tier == 1 ? 20 : caseFile.tier == 2 ? 30 : 45;
    expect(result?.xp, base);
    expect(game.careerXp, base);
    game.dispose();
  });
}
