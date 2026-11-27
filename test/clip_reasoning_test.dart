import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/models/arcade_models.dart';
import 'package:scamouflage/services/arcade_generator.dart';

void main() {
  test('Hard Clip Check has both outcomes with and without visible edits', () {
    final combinations = <String>{};
    final outcomesByFamily = <String, Set<bool>>{};
    for (var seed = 0; seed < 2000; seed++) {
      final c = ArcadeGenerator(
        seed,
      ).generate(ArcadeMode.clip, ArcadeDifficulty.hard);
      final edited = c.beats.any(
        (b) => !b.inViral || b.viralLine != b.fullLine,
      );
      combinations.add('$edited:${c.deceptive}');
      final family = ArcadeGenerator.familyOfSignature(c.signature);
      outcomesByFamily.putIfAbsent(family, () => <bool>{}).add(c.deceptive);
      expect(c.correct, [c.deceptive ? 1 : 0]);
      expect(c.tools.length, 5);
      expect(c.decisiveIds, isNotEmpty);
    }
    expect(
      combinations,
      containsAll(['true:true', 'true:false', 'false:true', 'false:false']),
    );
    expect(outcomesByFamily.length, 12);
    for (final outcomes in outcomesByFamily.values) {
      expect(outcomes, {true, false});
    }
  });
}
