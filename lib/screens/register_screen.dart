import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../routes.dart';
import '../services/api_client.dart';
import '../utils/validators.dart';
import '../widgets/error_view.dart';

/// R1 – Registrazione dell'azienda.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
      await auth.register(
          _nome.text.trim(), _email.text.trim(), _password.text);
      if (!mounted) return;
      // Scenario S1: account creato -> ora l'azienda esegue il login
      Navigator.of(context).pushReplacementNamed(Routes.login,
          arguments: 'Account creato! Ora accedi con email e password.');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message; // es. 409 email già registrata, 422 dati non validi
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
      appBar: AppBar(title: const Text('Registrazione azienda')),
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
                  if (_error != null) InlineErrorBanner(message: _error!),
                  TextFormField(
                    controller: _nome,
                    autovalidateMode: mode,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        Validators.required(v, 'il nome dell\'azienda', 80, min: 2),
                    decoration: const InputDecoration(
                        labelText: 'Nome azienda',
                        prefixIcon: Icon(Icons.business)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: mode,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                        labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    autovalidateMode: mode,
                    validator: Validators.password,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      helperText: 'Almeno 8 caratteri, con lettere e numeri',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _obscure,
                    autovalidateMode: mode,
                    validator: (v) =>
                        Validators.confirmPassword(v, _password.text),
                    decoration: const InputDecoration(
                        labelText: 'Conferma password',
                        prefixIcon: Icon(Icons.lock_outline)),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Crea account'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed(Routes.login),
                    child: const Text('Hai già un account? Accedi'),
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
