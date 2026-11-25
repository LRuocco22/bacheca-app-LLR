import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'routes.dart';
import 'services/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT');
  runApp(const BachecaApp());
}

ThemeData _buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0));
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    inputDecorationTheme:
        const InputDecorationTheme(border: OutlineInputBorder()),
    snackBarTheme:
        const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

class BachecaApp extends StatefulWidget {
  const BachecaApp({super.key});

  @override
  State<BachecaApp> createState() => _BachecaAppState();
}

class _BachecaAppState extends State<BachecaApp> {
  final _navKey = GlobalKey<NavigatorState>();
  late final ApiClient _api;
  late final AuthProvider _auth;

  @override
  void initState() {
    super.initState();
    _api = ApiClient();
    _auth = AuthProvider(_api);
    _auth.addListener(_onAuthChanged);
    _auth.restoreSession();
  }

  /// Su 401 con azienda loggata (sessione scaduta): ritorno al login.
  void _onAuthChanged() {
    if (_auth.sessionExpired) {
      _auth.sessionExpired = false;
      _navKey.currentState?.pushNamedAndRemoveUntil(
          Routes.login, (r) => false,
          arguments: 'Sessione scaduta: accedi di nuovo.');
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: _api),
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
      ],
      child: Selector<AuthProvider, bool>(
        selector: (_, a) => a.initializing,
        builder: (context, initializing, _) {
          if (initializing) {
            // Splash durante il ripristino della sessione
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: _buildTheme(),
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          return MaterialApp(
            title: 'Bacheca Lavoro',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(),
            navigatorKey: _navKey,
            initialRoute: Routes.bacheca,
            onGenerateRoute: (s) => Routes.generate(s, _auth),
          );
        },
      ),
    );
  }
}
