import 'package:intl/intl.dart';

/// Validatori con le stesse regole del server (contratto condiviso).
class Validators {
  static final _password = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,64}$');
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? email(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Inserisci l\'email';
    if (!_email.hasMatch(s)) return 'Email non valida';
    return null;
  }

  static String? password(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Inserisci la password';
    if (!_password.hasMatch(s)) {
      return 'Da 8 a 64 caratteri, con almeno una lettera e un numero';
    }
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if ((v ?? '').isEmpty) return 'Conferma la password';
    if (v != original) return 'Le password non coincidono';
    return null;
  }

  /// Campo di testo obbligatorio con lunghezza minima e massima.
  static String? required(String? v, String label, int max, {int min = 1}) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Inserisci $label';
    if (s.length < min) return '$label: almeno $min caratteri';
    if (s.length > max) return '$label: massimo $max caratteri';
    return null;
  }
}

/// Formattazione delle date.
class Fmt {
  static String date(DateTime? d) =>
      d == null ? '-' : DateFormat('dd/MM/yyyy', 'it_IT').format(d);

  static String dateTime(DateTime? d) =>
      d == null ? '-' : DateFormat('dd/MM/yyyy HH:mm', 'it_IT').format(d);
}
