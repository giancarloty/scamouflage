import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/models/arcade_models.dart';
import 'package:scamouflage/services/arcade_generator.dart';

void main() {
  test('Trust outcomes are not forced to flip after a streak', () {
    var bad = 0;
    var fourInARow = 0;
    for (var seed = 0; seed < 50; seed++) {
      final g = ArcadeGenerator(seed);
      var run = 0;
      bool? last;
      for (var i = 0; i < 60; i++) {
        final c = g.generate(ArcadeMode.trust, ArcadeDifficulty.medium);
        if (c.deceptive) bad++;
        run = c.deceptive == last ? run + 1 : 1;
        if (run == 4) fourInARow++;
        last = c.deceptive;
      }
    }
    expect(bad / 3000, closeTo(.5, .04));
    expect(fourInARow, greaterThan(0));
  });
  test('the source check is not the decisive clue in most Trust cases', () {
    var sourceDecisive = 0;
    const total = 300;
    for (var seed = 0; seed < total; seed++) {
      final c = ArcadeGenerator(
        seed,
      ).generate(ArcadeMode.trust, ArcadeDifficulty.medium);
      if (c.decisiveIds.contains('source')) sourceDecisive++;
    }
    expect(sourceDecisive / total, lessThan(.6));
  });
}
