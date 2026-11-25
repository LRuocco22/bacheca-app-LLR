import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_client.dart';
import '../../utils/validators.dart';
import '../../widgets/error_view.dart';

/// R4 – Pubblicazione di un nuovo annuncio.
class NuovoAnnuncioScreen extends StatefulWidget {
  const NuovoAnnuncioScreen({super.key});

  @override
  State<NuovoAnnuncioScreen> createState() => _NuovoAnnuncioScreenState();
}

class _NuovoAnnuncioScreenState extends State<NuovoAnnuncioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titolo = TextEditingController();
  final _descrizione = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titolo.dispose();
    _descrizione.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final api = context.read<ApiClient>();
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await api.post('/api/annunci', body: {
        'titolo': _titolo.text.trim(),
        'descrizione': _descrizione.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Annuncio pubblicato: ora è visibile in bacheca')));
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Risposta non valida dal server.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const mode = AutovalidateMode.onUserInteraction;
    return Scaffold(
      appBar: AppBar(title: const Text('Nuovo annuncio')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null) InlineErrorBanner(message: _error!),
            TextFormField(
              controller: _titolo,
              autovalidateMode: mode,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => Validators.required(v, 'il titolo', 100, min: 3),
              decoration: const InputDecoration(
                labelText: 'Titolo',
                hintText: 'es. Sviluppatore Flutter junior',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descrizione,
              autovalidateMode: mode,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 10,
              validator: (v) =>
                  Validators.required(v, 'la descrizione', 2000, min: 10),
              decoration: const InputDecoration(
                labelText: 'Descrizione',
                hintText: 'Mansioni, requisiti, sede, tipo di contratto…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.publish),
              label: const Text('Pubblica annuncio'),
            ),
          ],
        ),
      ),
    );
  }
}
