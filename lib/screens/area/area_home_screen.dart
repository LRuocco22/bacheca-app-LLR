import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/annuncio.dart';
import '../../providers/auth_provider.dart';
import '../../routes.dart';
import '../../services/api_client.dart';
import '../../utils/validators.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/error_view.dart';

/// Area riservata dell'azienda: elenco dei propri annunci (R7),
/// pubblicazione di un nuovo annuncio (R4) e logout (R3).
class AreaHomeScreen extends StatefulWidget {
  const AreaHomeScreen({super.key});

  @override
  State<AreaHomeScreen> createState() => _AreaHomeScreenState();
}

class _AreaHomeScreenState extends State<AreaHomeScreen> {
  List<Annuncio> _annunci = [];
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
      final data = await api.get('/api/azienda/annunci') as List;
      if (!mounted) return;
      setState(() {
        _annunci = data
            .map((e) => Annuncio.fromJson((e as Map).cast<String, dynamic>()))
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

  Future<void> _nuovoAnnuncio() async {
    final creato =
        await Navigator.of(context).pushNamed(Routes.nuovoAnnuncio);
    if (creato == true) _load();
  }

  Widget _scrollable(Widget child) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [SizedBox(height: 300, child: child)],
      );

  Widget _buildList() {
    if (_error != null) {
      return _scrollable(ErrorView(message: _error!, onRetry: _load));
    }
    if (_loading && _annunci.isEmpty) {
      return _scrollable(const Center(child: CircularProgressIndicator()));
    }
    if (_annunci.isEmpty) {
      return _scrollable(const Center(
          child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Non hai ancora pubblicato annunci.\nTocca "Nuovo annuncio" per iniziare.',
          textAlign: TextAlign.center,
        ),
      )));
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
      itemCount: _annunci.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final a = _annunci[i];
        final n = a.numCandidature ?? 0;
        return Card(
          child: ListTile(
            title: Text(a.titolo,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Pubblicato il ${Fmt.date(a.createdAt)}'),
            trailing: Chip(
              avatar: const Icon(Icons.people, size: 18),
              label: Text('$n'),
            ),
            onTap: () async {
              await Navigator.of(context)
                  .pushNamed(Routes.candidature, arguments: a);
              _load(); // il numero di candidature potrebbe essere cambiato
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final azienda = context.watch<AuthProvider>().azienda;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Area riservata'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => logoutAndGoHome(context),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: Routes.area),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuovoAnnuncio,
        icon: const Icon(Icons.add),
        label: const Text('Nuovo annuncio'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Ciao, ${azienda?.nome ?? ''}',
                style: theme.textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text('I tuoi annunci: tocca un annuncio per vedere le candidature ricevute.',
                style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: RefreshIndicator(onRefresh: _load, child: _buildList()),
          ),
        ],
      ),
    );
  }
}
