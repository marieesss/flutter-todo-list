// lib/screens/auth/LoginRegister.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../homepage/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  final _auth = AuthService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "Email requis";
    final r = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    if (!r.hasMatch(v.trim())) return "Email invalide";
    return null;
  }

  String? _pwdValidator(String? v) {
    if (v == null || v.isEmpty) return "Mot de passe requis";
    if (v.length < 6) return "6 caractères minimum";
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _auth.signIn(
        email: _emailCtrl.text.trim(),
        password: _pwdCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomepagePage()),
        (_) => false,
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(height: 24),
                    Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      "Connexion",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username, AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pwdCtrl,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                      validator: _pwdValidator,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v ?? false),
                        ),
                        const Text("Se souvenir de moi"),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // TODO (plus tard) : reset password Firebase
                            _showError("Mot de passe oublié — à brancher.");
                          },
                          child: const Text("Mot de passe oublié ?"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.0),
                              child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : const Text("Se connecter"),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Pas de compte ?"),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterPage()),
                            );
                          },
                          child: const Text("Créer un compte"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -------- Register --------

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _pwd2Ctrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  final _auth = AuthService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _pwd2Ctrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "Email requis";
    final r = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    if (!r.hasMatch(v.trim())) return "Email invalide";
    return null;
  }

  String? _pwdValidator(String? v) {
    if (v == null || v.isEmpty) return "Mot de passe requis";
    if (v.length < 8) return "8 caractères minimum";
    final hasUpper = v.contains(RegExp(r'[A-Z]'));
    final hasLower = v.contains(RegExp(r'[a-z]'));
    final hasDigit = v.contains(RegExp(r'\d'));
    if (!(hasUpper && hasLower && hasDigit)) {
      return "Doit contenir majuscule, minuscule et chiffre";
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pwdCtrl.text != _pwd2Ctrl.text) {
      _showError("Les mots de passe ne correspondent pas");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _pwdCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomepagePage()),
        (_) => false,
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(height: 24),
                    Icon(Icons.person_add_alt_1, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      "Créer un compte",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pwdCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        helperText: "Au moins 8 caractères, 1 maj, 1 min, 1 chiffre",
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                      validator: _pwdValidator,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pwd2Ctrl,
                      obscureText: _obscure,
                      decoration: const InputDecoration(
                        labelText: "Confirmer le mot de passe",
                        prefixIcon: Icon(Icons.lock_person_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Confirmation requise" : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.0),
                              child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : const Text("S'inscrire"),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Déjà un compte ?"),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Se connecter"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}