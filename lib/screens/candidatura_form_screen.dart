import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/annuncio.dart';
import '../services/api_client.dart';
import '../utils/validators.dart';
import '../widgets/error_view.dart';

/// R6 – Form di candidatura: dati del candidato + curriculum PDF.
class CandidaturaFormScreen extends StatefulWidget {
  final Annuncio annuncio;

  const CandidaturaFormScreen({super.key, required this.annuncio});

  @override
  State<CandidaturaFormScreen> createState() => _CandidaturaFormScreenState();
}

class _CandidaturaFormScreenState extends State<CandidaturaFormScreen> {
  static const int _maxCvBytes = 5 * 1024 * 1024; // come sul server

  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _cognome = TextEditingController();
  final _email = TextEditingController();
  Uint8List? _cvBytes;
  String? _cvNome;
  String? _cvError;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nome.dispose();
    _cognome.dispose();
    _email.dispose();
    super.dispose();
  }

  /// Apre la scelta del file e ne legge i byte
  /// (sul web non esiste un percorso del file: si lavora con i byte).
  Future<void> _scegliCv() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (file == null) return; // annullato
    Uint8List? bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      bytes = null;
    }
    if (!mounted) return;
    String? errore;
    if (bytes == null) {
      errore = 'Impossibile leggere il file selezionato';
    } else if (bytes.length > _maxCvBytes) {
      errore = 'Il curriculum supera la dimensione massima di 5 MB';
    } else if (!file.name.toLowerCase().endsWith('.pdf')) {
      errore = 'Il curriculum deve essere un file PDF';
    }
    setState(() {
      _cvError = errore;
      _cvBytes = errore == null ? bytes : null;
      _cvNome = errore == null ? file.name : null;
    });
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    if (_cvBytes == null) {
      setState(() => _cvError ??= 'Allega il curriculum (PDF)');
    }
    if (!formOk || _cvBytes == null) return;

    final api = context.read<ApiClient>();
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await api.postMultipart(
        '/api/annunci/${widget.annuncio.id}/candidature',
        fields: {
          'nome': _nome.text.trim(),
          'cognome': _cognome.text.trim(),
          'email': _email.text.trim(),
        },
        fileField: 'cv',
        fileBytes: _cvBytes!,
        fileName: _cvNome ?? 'curriculum.pdf',
      );
      if (!mounted) return;
      await _mostraConferma();
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

  /// Messaggio di conferma (scenario S2), poi ritorno alla bacheca.
  Future<void> _mostraConferma() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Candidatura inviata'),
        content: Text(
            'Grazie ${_nome.text.trim()}! La tua candidatura per '
            '"${widget.annuncio.titolo}" è stata registrata.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Torna alla bacheca'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    const mode = AutovalidateMode.onUserInteraction;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Candidatura')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Ti stai candidando per:', style: theme.textTheme.bodyMedium),
            Text(widget.annuncio.titolo,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(widget.annuncio.aziendaNome,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 20),
            if (_error != null) InlineErrorBanner(message: _error!),
            TextFormField(
              controller: _nome,
              autovalidateMode: mode,
              textCapitalization: TextCapitalization.words,
              validator: (v) => Validators.required(v, 'il nome', 50),
              decoration: const InputDecoration(
                  labelText: 'Nome', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cognome,
              autovalidateMode: mode,
              textCapitalization: TextCapitalization.words,
              validator: (v) => Validators.required(v, 'il cognome', 50),
              decoration: const InputDecoration(
                  labelText: 'Cognome', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              autovalidateMode: mode,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              decoration: const InputDecoration(
                  labelText: 'Email', prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 20),
            Text('Curriculum (PDF, max 5 MB)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _submitting ? null : _scegliCv,
              icon: Icon(_cvNome == null ? Icons.attach_file : Icons.picture_as_pdf),
              label: Text(_cvNome ?? 'Allega curriculum'),
            ),
            if (_cvError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(_cvError!,
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send),
              label: const Text('Invia candidatura'),
            ),
          ],
        ),
      ),
    );
  }
}
