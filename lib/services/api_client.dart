import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  final int statusCode; // 0 = errore di rete
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

const String _networkMessage =
    'Impossibile contattare il server. Controlla che sia avviato e raggiungibile.';

class ApiClient {
  final http.Client _client = http.Client();

  /// Token Bearer corrente (null = ospite, cioè un candidato).
  String? token;

  /// Chiamato su 401 quando c'è un'azienda loggata (logout locale).
  void Function()? onUnauthorized;

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  /// Indirizzo completo di una risorsa del server.
  /// Con [withToken] aggiunge "?token=...": serve per aprire il CV nel browser,
  /// perché un link non può inviare l'header Authorization.
  String url(String path, {bool withToken = false}) {
    final full = '${ApiConfig.baseUrl}$path';
    final t = token;
    if (!withToken || t == null) return full;
    return '$full?token=${Uri.encodeQueryComponent(t)}';
  }

  Future<dynamic> _send(String method, String path, {Object? body}) {
    final req = http.Request(method, Uri.parse('${ApiConfig.baseUrl}$path'));
    req.headers['Accept'] = 'application/json';
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      req.headers['Content-Type'] = 'application/json; charset=utf-8';
      req.body = jsonEncode(body);
    }
    return _execute(req, ApiConfig.timeout);
  }

  /// Invio di un form con un file (multipart/form-data): campi di testo + file.
  /// Usato per la candidatura (nome, cognome, email + curriculum PDF).
  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required Uint8List fileBytes,
    required String fileName,
  }) {
    final req =
        http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}$path'));
    req.headers['Accept'] = 'application/json';
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    req.fields.addAll(fields);
    req.files.add(
        http.MultipartFile.fromBytes(fileField, fileBytes, filename: fileName));
    return _execute(req, ApiConfig.uploadTimeout);
  }

  Future<dynamic> _execute(http.BaseRequest req, Duration timeout) async {
    http.Response res;
    try {
      final streamed = await _client.send(req).timeout(timeout);
      res = await http.Response.fromStream(streamed).timeout(timeout);
    } on TimeoutException {
      throw const ApiException(0, _networkMessage);
    } on http.ClientException {
      throw const ApiException(0, _networkMessage);
    }

    dynamic data;
    final text = utf8.decode(res.bodyBytes, allowMalformed: true);
    if (text.isNotEmpty) {
      try {
        data = jsonDecode(text);
      } catch (_) {
        data = null;
      }
    }

    if (res.statusCode >= 400) {
      var msg = 'Errore del server (${res.statusCode})';
      if (data is Map && data['error'] is String) {
        msg = data['error'] as String;
      }
      if (res.statusCode == 401 && token != null) onUnauthorized?.call();
      throw ApiException(res.statusCode, msg);
    }
    return data;
  }
}
