import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/models/arcade_models.dart';
import 'package:scamouflage/services/arcade_generator.dart';

void main() {
  test('Trust verdicts never repeat more than three times in a row', () {
    for (var seed = 0; seed < 50; seed++) {
      final g = ArcadeGenerator(seed);
      var run = 0;
      bool? last;
      for (var i = 0; i < 60; i++) {
        final c = g.generate(ArcadeMode.trust, ArcadeDifficulty.medium);
        run = c.deceptive == last ? run + 1 : 1;
        last = c.deceptive;
        expect(run, lessThanOrEqualTo(3), reason: 'seed $seed, round $i');
      }
    }
  });
}