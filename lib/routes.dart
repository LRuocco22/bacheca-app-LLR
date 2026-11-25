import 'package:flutter/material.dart';

import 'models/annuncio.dart';
import 'models/candidatura.dart';
import 'providers/auth_provider.dart';
import 'screens/annuncio_detail_screen.dart';
import 'screens/area/area_home_screen.dart';
import 'screens/area/candidatura_detail_screen.dart';
import 'screens/area/candidature_screen.dart';
import 'screens/area/nuovo_annuncio_screen.dart';
import 'screens/bacheca_screen.dart';
import 'screens/candidatura_form_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

class Routes {
  // Pubbliche (candidato, senza login)
  static const bacheca = '/';
  static const annuncio = '/annuncio';
  static const candidatura = '/candidatura';
  static const login = '/login';
  static const register = '/register';

  // Area riservata (solo azienda autenticata)
  static const area = '/area';
  static const nuovoAnnuncio = '/area/nuovo';
  static const candidature = '/area/candidature';
  static const dettaglioCandidatura = '/area/candidatura';

  // Guard solo UX: il server controlla davvero (401).
  static const _riservate = {area, nuovoAnnuncio, candidature, dettaglioCandidatura};

  static MaterialPageRoute<dynamic> _page(RouteSettings s, Widget w) =>
      MaterialPageRoute(settings: s, builder: (_) => w);

  static Route<dynamic> generate(RouteSettings s, AuthProvider auth) {
    final name = s.name ?? bacheca;
    final args = s.arguments;

    // Area riservata senza login -> schermata di login
    if (_riservate.contains(name) && !auth.isLoggedIn) {
      return _page(const RouteSettings(name: login), const LoginScreen());
    }

    switch (name) {
      case annuncio:
        if (args is Annuncio) {
          return _page(s, AnnuncioDetailScreen(annuncio: args));
        }
        break;
      case candidatura:
        if (args is Annuncio) {
          return _page(s, CandidaturaFormScreen(annuncio: args));
        }
        break;
      case login:
        return _page(s, LoginScreen(messaggio: args is String ? args : null));
      case register:
        return _page(s, const RegisterScreen());
      case area:
        return _page(s, const AreaHomeScreen());
      case nuovoAnnuncio:
        return _page(s, const NuovoAnnuncioScreen());
      case candidature:
        if (args is Annuncio) {
          return _page(s, CandidatureScreen(annuncio: args));
        }
        break;
      case dettaglioCandidatura:
        if (args is Candidatura) {
          return _page(s, CandidaturaDetailScreen(candidatura: args));
        }
        break;
    }
    // Rotta sconosciuta o argomenti mancanti (es. pagina ricaricata): bacheca
    return _page(const RouteSettings(name: bacheca), const BachecaScreen());
  }
}
