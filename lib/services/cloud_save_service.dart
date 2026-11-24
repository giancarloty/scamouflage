import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/engine.dart';
import 'auth_service.dart';
import 'backend_client.dart';

/// Syncs the player's progress (XP, level, unlocked cosmetics, stats) with
/// the Express backend so it follows the account across devices.
class CloudSaveService {
  CloudSaveService._();
  static final CloudSaveService instance = CloudSaveService._();

  static const _linkedUidKey = 'cloud_uid_v1';

  GameEngine? _engine;
  Timer? _debounce;
  bool _syncing = false;
  String? _signInSyncedUid;

  /// Call once, after GameEngine.load() has finished.
  void attach(GameEngine engine) {
    _engine = engine;
    engine.onSaved = _scheduleSync;
    AuthService.instance.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  void _onAuthChanged() {
    final auth = AuthService.instance;
    final uid = auth.user?.uid;
    if (uid == null) {
      _signInSyncedUid = null;
      _debounce?.cancel();
      return;
    }
    if (auth.username != null && _signInSyncedUid != uid) {
      _signInSyncedUid = uid;
      sync();
    }
  }

  /// Called after every local save; waits for 20 quiet seconds, then syncs.
  void _scheduleSync() {
    if (AuthService.instance.username == null) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 20), sync);
  }

  /// Safe to call any time; does nothing when signed out or offline.
  Future<void> sync() async {
    final engine = _engine;
    final auth = AuthService.instance;
    final user = auth.user;
    if (engine == null ||
        user == null ||
        auth.username == null ||
        !auth.available ||
        _syncing) {
      return;
    }
    _syncing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final linked = prefs.getString(_linkedUidKey);
      // Different account on the same device: adopt the server profile instead
      // of pushing the previous player's local progress into the new account.
      final mode = (linked != null && linked != user.uid) ? 'adopt' : 'merge';
      final sentXp = engine.careerXp;

      final data = await BackendClient.instance.post('/api/syncProfile', {
        'mode': mode,
        'profile': engine.toCloud(),
      });

      final profile = data['profile'];
      if (profile is! Map) return;

      if (engine.careerXp != sentXp) {
        _scheduleSync();
        return;
      }
      await engine.applyCloud(
        profile.map((k, v) => MapEntry(k.toString(), v)),
      );
      await prefs.setString(_linkedUidKey, user.uid);
    } catch (e) {
      debugPrint('Cloud save skipped: $e');
    } finally {
      _syncing = false;
    }
  }
}