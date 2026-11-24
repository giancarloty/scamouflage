import 'cloud_save_service.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'backend_client.dart';

/// A message that is safe to show directly to the player.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

/// Optional online accounts. The game never requires this: if Firebase is
/// missing or the player is offline, [available] / [signedIn] are simply
/// false and everything keeps working from local storage.
class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// 3-16 characters: letters, numbers, underscore.
  static final RegExp usernamePattern = RegExp(r'^[A-Za-z0-9_]{3,16}$');

  bool available = false; // Firebase initialised successfully
  bool busy = false; // a sign-in / register call is running
  bool profileLoaded = false; // users/{uid} has been read (or created)
  bool profileError = false; // reading users/{uid} failed (offline, etc.)
  User? user;
  String? username;
  bool justRegistered = false; // Tells CloudSaveService to merge guest progress

  bool _registering = false;
  StreamSubscription<User?>? _sub;

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  bool get signedIn => user != null;
  bool get needsUsername => user != null && profileLoaded && username == null;

  /// Call once from main() right after Firebase.initializeApp succeeds.
  void init() {
    if (Firebase.apps.isEmpty) return;
    available = true;
    _sub?.cancel();
    _sub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? next) async {
    user = next;
    username = null;
    profileLoaded = false;
    profileError = false;
    notifyListeners();
    if (next != null && !_registering) await reloadProfile();
  }

  Future<void> reloadProfile() async {
    final current = user;
    if (current == null) return;
    profileError = false;
    notifyListeners();
    try {
      final snap = await _db.collection('users').doc(current.uid).get();
      if (user?.uid != current.uid) return; // signed out meanwhile
      username = snap.data()?['username'] as String?;
      profileLoaded = true;
    } catch (e) {
      debugPrint('Could not load profile: $e');
      profileError = true;
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------- usernames

  String _checkedUsername(String raw) {
    final name = raw.trim();
    if (!usernamePattern.hasMatch(name)) {
      throw const AuthException(
          'Username must be 3–16 characters: letters, numbers or underscore.');
    }
    return name;
  }

  /// Case-insensitive: "Ollie" and "ollie" are the same username.
  Future<bool> isUsernameAvailable(String name) async {
    final trimmed = name.trim();
    if (!usernamePattern.hasMatch(trimmed)) return false;
    final snap =
        await _db.collection('usernames').doc(trimmed.toLowerCase()).get();
    return !snap.exists;
  }

  /// Reserves the username and creates the player record in ONE transaction,
  /// so two players can never end up with the same name.
  Future<void> _claim(User u, String name) async {
    final lower = name.toLowerCase();
    final nameRef = _db.collection('usernames').doc(lower);
    final userRef = _db.collection('users').doc(u.uid);
    await _db.runTransaction((tx) async {
      final existing = await tx.get(nameRef);
      if (existing.exists) {
        throw const AuthException('That username is already taken.');
      }
      tx.set(nameRef, {
        'uid': u.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.set(userRef, {
        'uid': u.uid,
        'username': name,
        'usernameLower': lower,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
    username = name;
    profileLoaded = true;
    profileError = false;
  }

  // ------------------------------------------------------------------ actions

  /// E-mail + password account with a unique username.
  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final name = _checkedUsername(username);
    await _run(() async {
      if (!await isUsernameAvailable(name)) {
        throw const AuthException('That username is already taken.');
      }
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      try {
        await _claim(cred.user!, name);
        justRegistered = true;
      } catch (_) {
        await cred.user?.delete();
        rethrow;
      }
    }, registering: true);
  }

  /// Accepts either an email address or a username, plus password.
  Future<void> signIn({
    required String identifier,
    required String password,
  }) =>
      _run(() async {
        justRegistered = false;
        var email = identifier.trim();
        if (!email.contains('@')) {
          try {
            final res = await BackendClient.instance
                .postPublic('/api/resolveLogin', {'identifier': email});
            email = (res['email'] ?? '').toString().trim();
            if (email.isEmpty) {
              throw const AuthException('Wrong username or password.');
            }
          } on BackendException catch (e) {
            throw AuthException(e.message);
          }
        }
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      });

  /// For players who signed in with Google and have no username yet.
  Future<void> chooseUsername(String raw) async {
    final name = _checkedUsername(raw);
    final current = user;
    if (current == null) throw const AuthException('Please sign in first.');
    await _run(() async {
      if (!await isUsernameAvailable(name)) {
        throw const AuthException('That username is already taken.');
      }
      await _claim(current, name);
    });
  }

  /// Changes the current user's username while keeping all XP and cosmetics.
  Future<void> changeUsername(String raw) async {
    final name = _checkedUsername(raw);
    if (user == null) throw const AuthException('Please sign in first.');
    await _run(() async {
      try {
        final res = await BackendClient.instance
            .post('/api/changeUsername', {'newUsername': name});
        username = (res['username'] ?? name).toString();
      } on BackendException catch (e) {
        throw AuthException(e.message);
      }
    });
  }

  /// Permanently deletes the account and signs out.
  Future<void> deleteAccount() async {
    if (user == null) throw const AuthException('Please sign in first.');
    await _run(() async {
      try {
        await BackendClient.instance.post('/api/deleteAccount', {});
      } on BackendException catch (e) {
        throw AuthException(e.message);
      }
      justRegistered = false;
      await _auth.signOut();
    });
  }

  Future<void> signOut() async {
    if (!available) return;
    await CloudSaveService.instance.flushBeforeSignOut();
    justRegistered = false;
    await _auth.signOut();
  }

  // ----------------------------------------------------------------- plumbing

  Future<void> _run(Future<void> Function() action,
      {bool registering = false}) async {
    if (!available) {
      throw const AuthException('Online features are not available right now.');
    }
    busy = true;
    _registering = registering;
    notifyListeners();
    try {
      await action();
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_authMessage(e.code));
    } on FirebaseException catch (e) {
      debugPrint('Firebase error: ${e.code} ${e.message}');
      throw AuthException(e.code == 'unavailable'
          ? 'No connection. Check your internet and try again.'
          : 'Something went wrong (${e.code}). Please try again.');
    } finally {
      busy = false;
      _registering = false;
      notifyListeners();
    }
  }

  String _authMessage(String code) => switch (code) {
        'invalid-email' => 'That email address does not look right.',
        'user-disabled' => 'This account has been disabled.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'Wrong email or password.',
        'email-already-in-use' =>
          'An account with that email already exists. Try signing in.',
        'weak-password' => 'Password is too weak. Use at least 6 characters.',
        'network-request-failed' =>
          'No connection. Check your internet and try again.',
        'too-many-requests' =>
          'Too many attempts. Please wait a moment and try again.',
        'operation-not-allowed' =>
          'This sign-in method is not enabled in the Firebase console.',
        'popup-closed-by-user' ||
        'cancelled-popup-request' ||
        'canceled' ||
        'web-context-canceled' =>
          'Sign-in was cancelled.',
        _ => 'Sign-in failed ($code). Please try again.',
      };
}