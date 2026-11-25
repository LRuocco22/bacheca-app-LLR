import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/annuncio.dart';
import '../../models/candidatura.dart';
import '../../routes.dart';
import '../../services/api_client.dart';
import '../../utils/validators.dart';
import '../../widgets/error_view.dart';

/// R7 – Candidature ricevute per uno dei propri annunci.
class CandidatureScreen extends StatefulWidget {
  final Annuncio annuncio;

  const CandidatureScreen({super.key, required this.annuncio});

  @override
  State<CandidatureScreen> createState() => _CandidatureScreenState();
}

class _CandidatureScreenState extends State<CandidatureScreen> {
  List<Candidatura> _candidature = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiClient>();
      final data = await api
          .get('/api/azienda/annunci/${widget.annuncio.id}/candidature') as List;
      if (!mounted) return;
      setState(() {
        _candidature = data
            .map((e) =>
                Candidatura.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Risposta non valida dal server.';
        _loading = false;
      });
    }
  }

  Widget _scrollable(Widget child) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [SizedBox(height: 300, child: child)],
      );

  Widget _buildList() {
    if (_error != null) {
      return _scrollable(ErrorView(message: _error!, onRetry: _load));
    }
    if (_loading && _candidature.isEmpty) {
      return _scrollable(const Center(child: CircularProgressIndicator()));
    }
    if (_candidature.isEmpty) {
      return _scrollable(const Center(
          child: Text('Nessuna candidatura ricevuta per questo annuncio.')));
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: _candidature.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final c = _candidature[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(c.nome.isEmpty ? '?' : c.nome[0].toUpperCase()),
            ),
            title: Text(c.nomeCompleto),
            subtitle: Text('${c.email}\nRicevuta il ${Fmt.dateTime(c.createdAt)}'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context)
                .pushNamed(Routes.dettaglioCandidatura, arguments: c),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Candidature ricevute')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(widget.annuncio.titolo,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: RefreshIndicator(onRefresh: _load, child: _buildList()),
          ),
        ],
      ),
    );
  }
}
