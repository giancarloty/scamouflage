import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scamouflage/controllers/engine.dart';
import 'package:scamouflage/models/player_progression.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'XP levels advance without spending or changing numbered shifts',
    () async {
      final g = GameEngine();
      await g.load();
      expect(g.careerRank.level, 1);
      expect(g.unlockedShift, 1);
      expect(g.equipCareerTitle('fact_finder'), isFalse);
      expect(g.equipBadge('newspaper'), isFalse);
      expect(g.equipFrame('violet'), isFalse);
      g.awardArcadeXp(400);
      expect(g.careerRank.level, 3);
      expect(g.equippedTitleId, 'scam_detective');
      expect(g.careerXp, 400);
      expect(g.unlockedShift, 1);
      expect(g.equipBadge('magnifier'), isTrue);
      expect(g.equipFrame('sunny'), isTrue);
      expect(g.careerXp, 400); // Equipping cosmetics does not spend XP.
      g.dispose();
    },
  );

  test(
    'Player may select an older earned title without auto-overwriting',
    () async {
      final g = GameEngine();
      await g.load();
      g.awardArcadeXp(400);
      expect(g.equipCareerTitle('rookie'), isTrue);
      g.awardArcadeXp(900);
      expect(g.careerRank.title, 'Fact Finder'); // 1300 XP
      expect(g.equippedTitleId, 'rookie');
      g.dispose();
    },
  );

  test(
    'Legacy saves migrate; invalid or locked cosmetics fall back safely',
    () async {
      SharedPreferences.setMockInitialValues({
        'level_v4': 4,
        'xp_v4': 400,
        'cosmetic_title_v1': 'digital_sentinel',
        'cosmetic_badge_v1': 'newspaper',
        'cosmetic_frame_v1': 'unknown_frame',
      });
      final g = GameEngine();
      await g.load();
      expect(g.unlockedShift, 4);
      expect(g.careerXp, 400);
      expect(g.equippedTitleId, 'rookie');
      expect(g.equippedBadgeId, 'chameleon');
      expect(g.equippedFrameId, 'classic');
      g.dispose();
    },
  );

  test('Progress to next level respects threshold boundaries', () {
    expect(CareerProgression.rankAt(0).title, 'Rookie Spotter');
    expect(CareerProgression.rankAt(150).title, 'Link Sleuth');
    expect(CareerProgression.rankAt(5200).level, 8);
    expect(CareerProgression.levelProgress(0), 0);
    expect(CareerProgression.levelProgress(150), 0);
    expect(CareerProgression.levelProgress(5200), 0);
    expect(CareerProgression.rankAt(10000).level, 10);
    expect(CareerProgression.levelProgress(10000), 1);
  });
}
