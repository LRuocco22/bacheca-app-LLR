import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/annuncio.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import '../services/api_client.dart';
import '../utils/validators.dart';

/// R5 – Dettaglio di un annuncio, con il pulsante per candidarsi.
class AnnuncioDetailScreen extends StatefulWidget {
  final Annuncio annuncio;

  const AnnuncioDetailScreen({super.key, required this.annuncio});

  @override
  State<AnnuncioDetailScreen> createState() => _AnnuncioDetailScreenState();
}

class _AnnuncioDetailScreenState extends State<AnnuncioDetailScreen> {
  late Annuncio _annuncio;

  @override
  void initState() {
    super.initState();
    _annuncio = widget.annuncio;
    _refresh();
  }

  /// Ricarica il dettaglio dal server (GET /api/annunci/<id>).
  Future<void> _refresh() async {
    try {
      final api = context.read<ApiClient>();
      final json = await api.get('/api/annunci/${widget.annuncio.id}');
      if (!mounted) return;
      setState(() =>
          _annuncio = Annuncio.fromJson((json as Map).cast<String, dynamic>()));
    } catch (_) {
      // si continua a mostrare i dati già ricevuti dalla bacheca
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = _annuncio;
    final theme = Theme.of(context);
    final isAzienda = context.watch<AuthProvider>().isLoggedIn;
    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio annuncio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(a.titolo,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.business),
            title: Text(a.aziendaNome),
            subtitle: Text('Pubblicato il ${Fmt.date(a.createdAt)}'),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Text('Descrizione', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(a.descrizione, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 32),
          if (isAzienda)
            // Le aziende non si candidano (vedi traccia)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                    'Sei collegato come azienda: le candidature sono riservate ai candidati.'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context)
                    .pushNamed(Routes.candidatura, arguments: a),
                icon: const Icon(Icons.send),
                label: const Text('Candidati'),
              ),
            ),
        ],
      ),
    );
  }
}
