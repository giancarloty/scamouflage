import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scamouflage/controllers/engine.dart';
import 'package:scamouflage/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('First-time training is interactive and saved', () async {
    final engine = GameEngine();
    await engine.load();
    expect(engine.tutorialFinished, isFalse);
    engine.startTutorial();
    expect(engine.isTraining, isTrue);
    expect(engine.queue.length, 2);
    expect(engine.currentCase.correct, Verdict.reject);
    expect(engine.inspect('context'), isNotNull);
    expect(engine.tutorialStep, 1);
    // Tagging is optional for young beginners.
    expect(engine.credits, 3);
    expect(engine.verify(), isNotNull);
    expect(engine.credits, 3); // Checking a source is now unlimited.
    expect(engine.tutorialStep, 2);
    expect(engine.decide(Verdict.reject), isNotNull);
    engine.next();
    expect(engine.currentCase.correct, Verdict.approve);
    engine.decide(Verdict.approve);
    engine.next();
    expect(engine.finished, isTrue);
    expect(engine.tutorialFinished, isTrue);
    engine.dispose();
  });

  test('Updated walkthrough runs once for users upgrading from v4', () async {
    SharedPreferences.setMockInitialValues({
      'tutorial_v4': true,
      'level_v4': 3,
    });
    final engine = GameEngine();
    await engine.load();
    expect(engine.tutorialFinished, isFalse);
    expect(engine.unlockedShift, 3);
    await engine.skipTutorial();
    expect(engine.tutorialFinished, isTrue);
    engine.dispose();
  });

  test('Verification is free, but clicking alone gains no XP', () async {
    final engine = GameEngine();
    await engine.load();
    await engine.skipTutorial();
    engine.startShift(1);
    final caseFile = engine.currentCase;
    engine.inspect('context');
    engine.inspect('identity');
    expect(engine.shiftXp, 0);
    expect(engine.credits, 6);
    engine.verify();
    expect(engine.credits, 6);
    expect(engine.verify(), isNull);
    final result = engine.decide(caseFile.correct);
    expect(result, isNotNull);
    expect(result!.xp, greaterThanOrEqualTo(20));
    engine.dispose();
  });

  test('Wrongful decisions reduce Safety or Fairness, not career XP', () async {
    final engine = GameEngine();
    await engine.load();
    await engine.skipTutorial();
    engine.startShift(1);
    final oldCareerXp = engine.careerXp;
    final caseFile = engine.currentCase;
    engine.decide(
      caseFile.correct == Verdict.approve ? Verdict.reject : Verdict.approve,
    );
    expect(engine.careerXp, oldCareerXp);
    expect(engine.shiftXp, lessThan(0));
    expect(engine.safety < 80 || engine.fairness < 80, isTrue);
    expect(engine.callbacks, isNotEmpty);
    engine.dispose();
  });
}

// Keep the guided first shift visible to returning v4 playtesters when they
// install v5. Career XP and unlocked shifts still use the existing keys.
// The v5 tutorial should remain replayable from Settings.
