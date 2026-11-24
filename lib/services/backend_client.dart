import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class BackendException implements Exception {
  final int statusCode;
  final String message;
  const BackendException(this.statusCode, this.message);
  @override
  String toString() => 'BackendException($statusCode): $message';
}

/// Authenticated JSON client for the Node.js/Express backend hosted on Vercel.
///
/// Every request carries the player's Firebase ID token. The backend verifies
/// it with the Firebase Admin SDK, so the uid is never taken from the body.
class BackendClient {
  BackendClient._();
  static final BackendClient instance = BackendClient._();

  /// Override at build time:
  ///   flutter run --dart-define=API_BASE_URL=https://your-project.vercel.app
  /// or edit the defaultValue below.
  static const String _rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://YOUR-PROJECT.vercel.app',
  );

  static String get baseUrl => _rawBaseUrl.endsWith('/')
      ? _rawBaseUrl.substring(0, _rawBaseUrl.length - 1)
      : _rawBaseUrl;

  /// False until a real backend URL has been configured.
  static bool get isConfigured => !baseUrl.contains('YOUR-PROJECT');

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    if (!isConfigured) {
      throw const BackendException(0, 'API_BASE_URL is not configured.');
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const BackendException(401, 'Sign in first.');
    }

    var res = await _send(user, path, body, timeout, forceRefresh: false);
    // An expired or revoked ID token: fetch a fresh one and retry exactly once.
    if (res.statusCode == 401) {
      res = await _send(user, path, body, timeout, forceRefresh: true);
    }

    final decoded = _decode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg =
          (decoded['error'] ?? 'Request failed (${res.statusCode})').toString();
      throw BackendException(res.statusCode, msg);
    }
    return decoded;
  }

  Future<http.Response> _send(
    User user,
    String path,
    Map<String, dynamic> body,
    Duration timeout, {
    required bool forceRefresh,
  }) async {
    final token = await user.getIdToken(forceRefresh);
    if (token == null || token.isEmpty) {
      throw const BackendException(401, 'Missing auth token.');
    }
    return http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(timeout);
  }

  /// Tolerates empty bodies and non-JSON error pages (for example an HTML 502
  /// from the host) instead of crashing with a FormatException.
  Map<String, dynamic> _decode(String raw) {
    if (raw.isEmpty) return <String, dynamic>{};
    try {
      final parsed = jsonDecode(raw);
      if (parsed is Map) {
        return parsed.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {
      // fall through
    }
    return <String, dynamic>{};
  }
}