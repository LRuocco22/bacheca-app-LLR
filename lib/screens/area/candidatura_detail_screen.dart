import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/candidatura.dart';
import '../../services/api_client.dart';
import '../../utils/validators.dart';

/// R7 – Dati del candidato e apertura del curriculum allegato.
class CandidaturaDetailScreen extends StatelessWidget {
  final Candidatura candidatura;

  const CandidaturaDetailScreen({super.key, required this.candidatura});

  /// Apre il PDF in una nuova scheda del browser (o nel visualizzatore
  /// del telefono). L'indirizzo contiene il token perché un link
  /// non può inviare l'header Authorization.
  Future<void> _apriCv(BuildContext context) async {
    final api = context.read<ApiClient>();
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(
        api.url('/api/candidature/${candidatura.id}/cv', withToken: true));
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
    if (!ok) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Impossibile aprire il curriculum')));
    }
  }

  Widget _riga(IconData icon, String label, String value) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(value),
        subtitle: Text(label),
      );

  @override
  Widget build(BuildContext context) {
    final c = candidatura;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Candidatura')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(c.nomeCompleto,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _riga(Icons.person, 'Nome', c.nome),
          _riga(Icons.person_outline, 'Cognome', c.cognome),
          _riga(Icons.email, 'Email', c.email),
          _riga(Icons.schedule, 'Ricevuta il', Fmt.dateTime(c.createdAt)),
          const Divider(height: 32),
          Text('Curriculum', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(c.cvNomeOriginale),
              subtitle: const Text('Tocca per aprire'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _apriCv(context),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _apriCv(context),
            icon: const Icon(Icons.description),
            label: const Text('Apri curriculum'),
          ),
        ],
      ),
    );
  }
}
