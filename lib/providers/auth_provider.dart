import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/azienda.dart';
import '../services/api_client.dart';

/// Stato di autenticazione dell'azienda (il candidato non fa login).
class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';

  final ApiClient _api;
  Azienda? _azienda;
  bool _initializing = true;
  bool _manualLogout = false;

  /// true quando il logout è forzato da un 401 (letto da main.dart).
  bool sessionExpired = false;

  AuthProvider(this._api) {
    _api.onUnauthorized = _handleUnauthorized;
  }

  Azienda? get azienda => _azienda;
  bool get isLoggedIn => _azienda != null;
  bool get initializing => _initializing;

  /// Ripristina la sessione salvata chiamando /api/auth/me.
  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        _api.token = token;
        try {
          final json = await _api.get('/api/auth/me');
          _azienda = Azienda.fromJson((json as Map).cast<String, dynamic>());
        } catch (_) {
          // token scaduto (es. server riavviato): si riparte da ospite
          await _clearLocal();
        }
      }
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  /// R2 – Login con email e password.
  Future<void> login(String email, String password) async {
    final json = await _api.post('/api/auth/login',
        body: {'email': email, 'password': password});
    final map = (json as Map).cast<String, dynamic>();
    final token = map['token'] as String;
    _api.token = token;
    _azienda = Azienda.fromJson((map['azienda'] as Map).cast<String, dynamic>());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    notifyListeners();
  }

  /// R1 – Registrazione. Crea l'account SENZA fare login:
  /// come da scenario S1, dopo la registrazione l'azienda esegue il login.
  Future<void> register(String nome, String email, String password) async {
    await _api.post('/api/auth/register',
        body: {'nome': nome, 'email': email, 'password': password});
  }

  /// R3 – Logout: il server invalida il token, l'app lo dimentica.
  Future<void> logout() async {
    _manualLogout = true;
    try {
      await _api.post('/api/auth/logout');
    } catch (_) {
      // anche se il server non risponde si esce in locale
    }
    await _clearLocal();
    _manualLogout = false;
  }

  void _handleUnauthorized() {
    if (_azienda == null || _initializing || _manualLogout) return;
    sessionExpired = true;
    _clearLocal();
  }

  Future<void> _clearLocal() async {
    _api.token = null;
    _azienda = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
