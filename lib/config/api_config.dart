import 'package:flutter/foundation.dart';

/// Configurazione di rete.
///
/// - App web servita dal nostro server (http://localhost:8080 oppure il link
///   del tunnel https://....trycloudflare.com): le API sono allo STESSO
///   indirizzo della pagina, quindi non serve scrivere niente.
/// - Anteprima di FlutLab (gira su un altro sito): scrivere in [manualBaseUrl]
///   l'indirizzo del tunnel, es. 'https://parole-a-caso.trycloudflare.com'
///   (senza "/" finale), oppure usare --dart-define=API_BASE_URL=...
class ApiConfig {
  static const String manualBaseUrl = '';

  static const String _fromEnv = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_fromEnv.isNotEmpty) return _fromEnv;
    if (manualBaseUrl.isNotEmpty) return manualBaseUrl;
    if (kIsWeb) return Uri.base.origin; // stesso server della pagina
    return 'http://10.0.2.2:8080'; // emulatore Android
  }

  static const Duration timeout = Duration(seconds: 20);

  /// L'invio del curriculum può richiedere più tempo.
  static const Duration uploadTimeout = Duration(seconds: 60);
}
