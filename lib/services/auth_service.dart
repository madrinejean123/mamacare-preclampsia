import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class AuthApiException implements Exception {
  final String message;
  AuthApiException(this.message);

  @override
  String toString() => message;
}

/// App-wide auth state. A single instance backs both the route guard
/// (as a Listenable for go_router's refreshListenable) and every service
/// that needs to attach the current token to its requests.
class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _tokenKey = 'auth_token';
  static const _roleKey = 'auth_role';
  static const _patientIdKey = 'auth_patient_id';

  String? _token;
  String? _userName;
  String? _role;
  String? _patientId;
  bool _ready = false;

  String? get token => _token;
  String? get userName => _userName;
  String? get role => _role;
  String? get patientId => _patientId;
  bool get isLoggedIn => _token != null;
  bool get isAdmin => _role == 'admin';
  bool get isClinician => _role == 'clinician';
  bool get isPatient => _role == 'patient';
  bool get isStaff => isAdmin || isClinician;
  bool get ready => _ready;

  /// Restores a persisted session, if any. Call once before the app renders.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _role = prefs.getString(_roleKey);
    _patientId = prefs.getString(_patientIdKey);
    _ready = true;
    notifyListeners();
  }

  Future<void> register({required String name, required String email, required String password}) async {
    await _authRequest('/auth/register', {'name': name, 'email': email, 'password': password});
  }

  Future<void> login({required String email, required String password}) async {
    await _authRequest('/auth/login', {'email': email, 'password': password});
  }

  Future<void> _authRequest(String path, Map<String, String> body) async {
    late final http.Response response;
    try {
      response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (_) {
      throw AuthApiException('Could not reach the server at ${ApiConfig.baseUrl}. Is it running?');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthApiException('Server returned an invalid response.');
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AuthApiException(data['error']?.toString() ?? 'Request failed.');
    }

    final user = data['user'] as Map<String, dynamic>;
    _token = data['token'] as String;
    _userName = user['name'] as String?;
    _role = user['role'] as String? ?? 'clinician';
    _patientId = user['patient_id']?.toString();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token!);
    await prefs.setString(_roleKey, _role!);
    if (_patientId != null) {
      await prefs.setString(_patientIdKey, _patientId!);
    } else {
      await prefs.remove(_patientIdKey);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userName = null;
    _role = null;
    _patientId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_patientIdKey);
    notifyListeners();
  }
}
