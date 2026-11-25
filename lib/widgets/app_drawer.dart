import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../routes.dart';

/// Menu laterale: cambia in base a chi usa l'app (candidato ospite o azienda).
class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  void _go(BuildContext context, String route) {
    Navigator.of(context).pop(); // chiude il drawer
    if (route == currentRoute) return;
    if (route == Routes.bacheca) {
      Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
    } else {
      Navigator.of(context).pushNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final azienda = auth.azienda;
    final scheme = Theme.of(context).colorScheme;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: scheme.primary),
            accountName: Text(azienda?.nome ?? 'Candidato'),
            accountEmail: Text(azienda?.email ?? 'Consulta gli annunci e candidati'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: scheme.onPrimary,
              child: Icon(azienda == null ? Icons.person : Icons.business,
                  color: scheme.primary),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Bacheca annunci'),
            onTap: () => _go(context, Routes.bacheca),
          ),
          const Divider(),
          if (!auth.isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login azienda'),
              onTap: () => _go(context, Routes.login),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Registra la tua azienda'),
              onTap: () => _go(context, Routes.register),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Area riservata'),
              onTap: () => _go(context, Routes.area),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => logoutAndGoHome(context),
            ),
          ],
        ],
      ),
    );
  }
}

/// R3 – Logout: invalida la sessione e torna alla schermata pubblica,
/// eliminando tutte le schermate dell'area riservata dallo stack.
Future<void> logoutAndGoHome(BuildContext context) async {
  final nav = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final auth = context.read<AuthProvider>();
  if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) nav.pop();
  await auth.logout();
  nav.pushNamedAndRemoveUntil(Routes.bacheca, (r) => false);
  messenger.showSnackBar(const SnackBar(content: Text('Logout effettuato')));
}
