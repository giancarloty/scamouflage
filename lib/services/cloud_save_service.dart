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
  DateTime? _lastSyncAt;

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
      final wasSignedIn = _signInSyncedUid != null;
      _signInSyncedUid = null;
      _debounce?.cancel();
      if (wasSignedIn) {
        SharedPreferences.getInstance()
            .then((prefs) => prefs.remove(_linkedUidKey));
        _engine?.resetLocalProgress();
      }
      return;
    }
    if (auth.username != null && _signInSyncedUid != uid) {
      _signInSyncedUid = uid;
      // New account -> merge guest progress; existing account -> adopt cloud save.
      final mode = auth.justRegistered ? 'merge' : 'adopt';
      auth.justRegistered = false;
      sync(modeOverride: mode);
    }
  }

  /// Called after every local save; waits 6 seconds (above server's 5s gap), then syncs.
  void _scheduleSync() {
    if (AuthService.instance.username == null) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 6), () => sync(modeOverride: 'merge'));
  }

  /// Pushes any unsaved XP or cosmetics to the cloud right before signing out.
  Future<void> flushBeforeSignOut() async {
    _debounce?.cancel();
    while (_syncing) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (_lastSyncAt != null) {
      final elapsed = DateTime.now().difference(_lastSyncAt!);
      const minGap = Duration(milliseconds: 5200);
      if (elapsed < minGap) {
        await Future<void>.delayed(minGap - elapsed);
      }
    }
    await sync(modeOverride: 'merge');
  }

  /// Safe to call any time; does nothing when signed out or offline.
  Future<void> sync({String? modeOverride}) async {
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
      final mode = modeOverride ??
          ((linked != null && linked != user.uid) ? 'adopt' : 'merge');
      final sentXp = engine.careerXp;

      final data = await BackendClient.instance.post('/api/syncProfile', {
        'mode': mode,
        'profile': engine.toCloud(),
      });
      _lastSyncAt = DateTime.now();

      final profile = data['profile'];
      if (profile is! Map) return;

      if (mode == 'merge' && engine.careerXp != sentXp) {
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