  import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/models/arcade_models.dart';
import 'package:scamouflage/services/auth_service.dart';
import 'package:scamouflage/services/leaderboard_service.dart';

void main() {
  group('weekKey (Monday 00:00 Philippine time)', () {
    test('midweek maps to that week\'s Monday', () {
      expect(LeaderboardService.weekKey(DateTime.utc(2026, 11, 24, 12)), '2026-11-23');
    });
    test('Sunday 23:59 PHT still belongs to the old week', () {
      expect(LeaderboardService.weekKey(DateTime.utc(2026, 11, 22, 15, 59)), '2026-11-16');
    });
    test('Monday 00:00 PHT starts the new week', () {
      expect(LeaderboardService.weekKey(DateTime.utc(2026, 11, 22, 16, 0)), '2026-11-23');
    });
  });

  test('board ids separate mode, difficulty and period', () {
    expect(
      LeaderboardService.boardId(BoardPeriod.allTime,
          LeaderboardService.modeKey(null), ArcadeDifficulty.easy),
      'all_mix_easy',
    );
    expect(
      LeaderboardService.boardId(BoardPeriod.allTime,
          LeaderboardService.modeKey(ArcadeMode.scamSlam), ArcadeDifficulty.hard),
      'all_scamSlam_hard',
    );
  });

  test('username pattern', () {
    expect(AuthService.usernamePattern.hasMatch('Ollie_01'), isTrue);
    expect(AuthService.usernamePattern.hasMatch('ab'), isFalse);
    expect(AuthService.usernamePattern.hasMatch('has space'), isFalse);
    expect(AuthService.usernamePattern.hasMatch('a' * 17), isFalse);
  });
}