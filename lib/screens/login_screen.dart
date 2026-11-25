import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../routes.dart';
import '../services/api_client.dart';
import '../utils/validators.dart';
import '../widgets/error_view.dart';

/// R2 – Login dell'azienda con email e password.
class LoginScreen extends StatefulWidget {
  /// Messaggio informativo (es. "Account creato, ora accedi").
  final String? messaggio;

  const LoginScreen({super.key, this.messaggio});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await auth.login(_email.text.trim(), _password.text);
      if (!mounted) return;
      // Area riservata; "indietro" riporta alla bacheca
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.area, (r) => r.isFirst);
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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Login azienda')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.business, size: 64, color: scheme.primary),
                  const SizedBox(height: 24),
                  if (widget.messaggio != null && _error == null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(widget.messaggio!,
                          style: TextStyle(color: scheme.onPrimaryContainer)),
                    ),
                  if (_error != null) InlineErrorBanner(message: _error!),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                        labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (v) =>
                        (v ?? '').isEmpty ? 'Inserisci la password' : null,
                    onFieldSubmitted: (_) => _submitting ? null : _submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Accedi'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(Routes.register),
                    child: const Text('Non hai un account? Registra la tua azienda'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
