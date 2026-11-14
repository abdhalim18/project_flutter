import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Error dari server (server terjangkau tapi menolak request). Error jaringan
/// (offline, timeout) tetap dilempar apa adanya oleh package http, sehingga
/// pemanggil bisa membedakan "server menolak" dari "tidak ada koneksi".
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message, {this.code});

  final int statusCode;
  final String message;
  final String? code;

  @override
  String toString() => message;
}

class AppUser {
  const AppUser({required this.id, required this.email});

  final String id;
  final String email;

  Map<String, dynamic> toJson() => {'id': id, 'email': email};

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      AppUser(id: json['id'] as String, email: json['email'] as String);
}

/// Sesi login: token dari backend dan user pemiliknya.
class AppSession {
  const AppSession({required this.token, required this.user});

  final String token;
  final AppUser user;
}

/// Klien HTTP ke backend POS (Hono di Neon Functions).
///
/// Menyimpan sesi di secure storage agar tetap login setelah aplikasi ditutup
/// (termasuk saat offline), dan memancarkan perubahan sesi lewat [sessionChanges]
/// untuk router dan provider auth.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const _tokenKey = 'api_token';
  static const _userKey = 'api_user';
  static const _timeout = Duration(seconds: 20);

  final _storage = const FlutterSecureStorage();
  final _http = http.Client();
  final _sessionController = StreamController<AppSession?>.broadcast();

  AppSession? _session;

  AppSession? get session => _session;

  Stream<AppSession?> get sessionChanges => _sessionController.stream;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  /// Dipanggil sekali di main() sebelum runApp.
  Future<void> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    final user = await _storage.read(key: _userKey);
    if (token == null || user == null) return;
    _session = AppSession(
      token: token,
      user: AppUser.fromJson(jsonDecode(user) as Map<String, dynamic>),
    );
  }

  Future<void> setSession(AppSession? session) async {
    _session = session;
    if (session == null) {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
    } else {
      await _storage.write(key: _tokenKey, value: session.token);
      await _storage.write(key: _userKey, value: jsonEncode(session.user.toJson()));
    }
    _sessionController.add(session);
  }

  Map<String, String> _headers({String? contentType = 'application/json'}) => {
    'Content-Type': ?contentType,
    'Accept': 'application/json',
    if (_session != null) 'Authorization': 'Bearer ${_session!.token}',
  };

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send(() => _http.get(_uri(path, query), headers: _headers(contentType: null)));

  Future<dynamic> post(String path, Object body) =>
      _send(() => _http.post(_uri(path), headers: _headers(), body: jsonEncode(body)));

  Future<dynamic> patch(String path, Object body) =>
      _send(() => _http.patch(_uri(path), headers: _headers(), body: jsonEncode(body)));

  Future<dynamic> delete(String path) =>
      _send(() => _http.delete(_uri(path), headers: _headers(contentType: null)));

  /// Mengirim byte mentah (dipakai untuk upload foto).
  Future<dynamic> postBytes(String path, Uint8List bytes, String contentType) => _send(
    () => _http.post(
      _uri(path),
      headers: _headers(contentType: contentType),
      body: bytes,
    ),
  );

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final response = await request().timeout(_timeout);
    final body = response.body.isEmpty ? null : _tryDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) return body;

    final message = body is Map && body['error'] is String
        ? body['error'] as String
        : 'Server mengembalikan status ${response.statusCode}';
    final code = body is Map ? body['code'] as String? : null;

    // Token kedaluwarsa atau akun dihapus: keluarkan user ke layar login.
    if (response.statusCode == 401 && _session != null) {
      await setSession(null);
    }
    throw ApiException(response.statusCode, message, code: code);
  }

  static dynamic _tryDecode(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      return text;
    }
  }
}
