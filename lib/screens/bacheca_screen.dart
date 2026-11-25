import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/annuncio.dart';
import '../routes.dart';
import '../services/api_client.dart';
import '../utils/validators.dart';
import '../widgets/app_drawer.dart';
import '../widgets/error_view.dart';

/// R5 – Bacheca pubblica: elenco degli annunci (schermata iniziale).
class BachecaScreen extends StatefulWidget {
  const BachecaScreen({super.key});

  @override
  State<BachecaScreen> createState() => _BachecaScreenState();
}

class _BachecaScreenState extends State<BachecaScreen> {
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
      final data = await api.get('/api/annunci') as List;
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

  Widget _scrollable(Widget child) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [SizedBox(height: 400, child: child)],
      );

  Widget _buildBody() {
    if (_error != null) {
      return _scrollable(ErrorView(message: _error!, onRetry: _load));
    }
    if (_loading && _annunci.isEmpty) {
      return _scrollable(const Center(child: CircularProgressIndicator()));
    }
    if (_annunci.isEmpty) {
      return _scrollable(
          const Center(child: Text('Nessun annuncio pubblicato.')));
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _annunci.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _AnnuncioCard(
        annuncio: _annunci[i],
        onTap: () => Navigator.of(context)
            .pushNamed(Routes.annuncio, arguments: _annunci[i]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacheca lavoro'),
        actions: [
          IconButton(
            tooltip: 'Aggiorna',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: Routes.bacheca),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: RefreshIndicator(onRefresh: _load, child: _buildBody()),
          ),
        ],
      ),
    );
  }
}

class _AnnuncioCard extends StatelessWidget {
  final Annuncio annuncio;
  final VoidCallback onTap;

  const _AnnuncioCard({required this.annuncio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(annuncio.titolo,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(annuncio.aziendaNome,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.primary)),
                  ),
                  Text(Fmt.date(annuncio.createdAt),
                      style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(annuncio.descrizione,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
