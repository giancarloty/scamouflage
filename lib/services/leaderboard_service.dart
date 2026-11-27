import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/arcade_models.dart';
import 'auth_service.dart';
import 'backend_client.dart';

enum BoardPeriod { weekly, allTime }

class LeaderboardEntry {
  final int rank;
  final String uid;
  final String username;
  final int score;
  const LeaderboardEntry({
    required this.rank,
    required this.uid,
    required this.username,
    required this.score,
  });
}

class MyStanding {
  final int rank;
  final int score;
  const MyStanding({required this.rank, required this.score});
}

/// Global rankings. One board per period x game mode x difficulty:
///
///   leaderboards/{boardId}/entries/{uid} -> { uid, username, score, mode,
///                                             difficulty, period, updatedAt }
///
/// READS come straight from Firestore (public, read-only for clients).
/// WRITES never happen on the device: a ranked run first asks the backend for a
/// one-time ticket ([startRun]); when the run ends, [finishRun] sends the
/// result and the backend validates it against the ticket before touching the
/// leaderboard. Firestore rules must deny all client writes to /leaderboards.
class LeaderboardService {
  LeaderboardService._();
  static final LeaderboardService instance = LeaderboardService._();

  static const int topN = 50;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String modeKey(ArcadeMode? mode) => mode?.name ?? 'mix';

  static String weekKey([DateTime? now]) {
    final ph = (now ?? DateTime.now()).toUtc().add(const Duration(hours: 8));
    final day = DateTime.utc(ph.year, ph.month, ph.day);
    final monday = day.subtract(Duration(days: day.weekday - 1));
    return '${monday.year}-${_two(monday.month)}-${_two(monday.day)}';
  }

  static String boardId(
    BoardPeriod period,
    String mode,
    ArcadeDifficulty difficulty,
  ) {
    if (mode == 'overall') return 'overall_xp';
    return period == BoardPeriod.weekly
        ? 'week_${weekKey()}_${mode}_${difficulty.name}'
        : 'all_${mode}_${difficulty.name}';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  CollectionReference<Map<String, dynamic>> _entries(String id) =>
      _db.collection('leaderboards').doc(id).collection('entries');

  /// Requests a one-time run ticket when a ranked arcade run starts.
  Future<String?> startRun({
    required ArcadeMode? mode,
    required ArcadeDifficulty difficulty,
  }) async {
    final auth = AuthService.instance;
    if (!auth.available || auth.username == null) return null;
    try {
      final data = await BackendClient.instance.post('/api/startRun', {
        'mode': modeKey(mode),
        'difficulty': difficulty.name,
      });
      return data['runId'] as String?;
    } catch (e) {
      debugPrint('Run will not be ranked (no ticket): $e');
      return null;
    }
  }

  /// Reports a finished run. Safe to fire-and-forget: it never throws, and it
  /// does nothing when the run has no ticket (signed out, offline, rate
  /// limited) or the score is zero. The backend decides whether the score is
  /// plausible; the client cannot choose the board or the player name.
  Future<void> finishRun({
    required Future<String?> ticket,
    required int score,
    required int rounds,
    required int correct,
    required int bestStreak,
  }) async {
    if (score <= 0) return;
    try {
      final runId = await ticket;
      if (runId == null) return;
      await BackendClient.instance.post('/api/submitRun', {
        'runId': runId,
        'score': score,
        'rounds': rounds,
        'correct': correct,
        'bestStreak': bestStreak,
      });
    } catch (e) {
      debugPrint('Run was not ranked: $e');
    }
  }

  Future<List<LeaderboardEntry>> fetchTop(
    BoardPeriod period,
    String mode,
    ArcadeDifficulty difficulty,
  ) async {
    final snap = await _entries(
      boardId(period, mode, difficulty),
    ).orderBy('score', descending: true).limit(topN).get();
    final result = <LeaderboardEntry>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      result.add(
        LeaderboardEntry(
          rank: result.length + 1,
          uid: doc.id,
          username: (data['username'] ?? 'Player').toString(),
          score: (data['score'] as num?)?.toInt() ?? 0,
        ),
      );
    }
    return result;
  }

  Future<MyStanding?> fetchStanding(
    BoardPeriod period,
    String mode,
    ArcadeDifficulty difficulty,
  ) async {
    final user = AuthService.instance.user;
    if (user == null) return null;
    final col = _entries(boardId(period, mode, difficulty));
    final mine = await col.doc(user.uid).get();
    final score = (mine.data()?['score'] as num?)?.toInt();
    if (score == null) return null;
    final higher = await col.where('score', isGreaterThan: score).count().get();
    return MyStanding(rank: (higher.count ?? 0) + 1, score: score);
  }
}
