// lib/screens/auth/LoginRegister.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
// import '../homepage/homepage.dart'; // plus utilisé ici
import '../categories/categories_page.dart';

/// ---------- Thème Noir & Blanc (local à l’écran) ----------
ThemeData _bwTheme(BuildContext context) {
  final base = Theme.of(context);
  final onBlack = Colors.white;
  final black = const Color(0xFF0B0B0B);
  final surface = const Color(0xFF121212);
  final outline = Colors.white.withOpacity(.18);

  return base.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: onBlack,
      onPrimary: Colors.black,
      surface: surface,
      onSurface: onBlack,
      secondary: Colors.grey.shade300,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: onBlack,
      displayColor: onBlack,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: black,
      labelStyle: TextStyle(color: onBlack.withOpacity(.7)),
      hintStyle: TextStyle(color: onBlack.withOpacity(.5)),
      prefixIconColor: onBlack.withOpacity(.7),
      suffixIconColor: onBlack.withOpacity(.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: .2),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white,
      contentTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
    ),
    dividerTheme: DividerThemeData(
      color: onBlack.withOpacity(.14),
      thickness: 1,
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(color: outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? Colors.white : Colors.transparent),
      checkColor: WidgetStateProperty.all(Colors.black),
    ),
  );
}

/// ---------- LOGIN ----------
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
        MaterialPageRoute(builder: (_) => const CategoriesPage()),
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
    return Theme(
      data: _bwTheme(context),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // Wordmark / Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _WeMark(), // petit mot-symbole noir & blanc
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Connexion",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 28),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.username, AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextFormField(
                        controller: _pwdCtrl,
                        obscureText: _obscure,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: "Mot de passe",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                        validator: _pwdValidator,
                        onFieldSubmitted: (_) => _submit(),
                      ),

                      const SizedBox(height: 10),

                      // ---- Mot de passe oublié ? centré ----
                      // Center(
                      //   child: TextButton(
                      //     onPressed: () {
                      //       // TODO: implémenter la réinitialisation du mot de passe
                      //       // Ex: Navigator.push(... ResetPasswordPage());
                      //     },
                      //     child: const Text("Mot de passe oublié ?"),
                      //   ),
                      // ),

                      const SizedBox(height: 14),

                      // CTA
                      FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : const Text("SE CONNECTER"),
                      ),

                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Link Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Pas de compte ? "),
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
      ),
    );
  }
}

/// ---------- REGISTER ----------
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _pwd2Ctrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  final _auth = AuthService();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _pwd2Ctrl.dispose();
    super.dispose();
  }

  String? _nameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "Prénom requis";
    if (v.trim().length < 2) return "Prénom trop court";
    return null;
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
        name: _nameCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CategoriesPage()),
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
    return Theme(
      data: _bwTheme(context),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [ _WeMark() ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Créer un compte",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 28),

                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: "Prénom",
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: _nameValidator,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _pwdCtrl,
                        obscureText: _obscure,
                        decoration: const InputDecoration(
                          labelText: "Mot de passe",
                          prefixIcon: Icon(Icons.lock_outline),
                          helperText: "8+ caractères, 1 maj, 1 min, 1 chiffre",
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
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Confirmation requise" : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 18),

                      FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : const Text("S'INSCRIRE"),
                      ),

                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Déjà un compte ? "),
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
      ),
    );
  }
}

/// Petit “wordmark” minimaliste noir & blanc
class _WeMark extends StatelessWidget {
  const _WeMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // carré blanc + point noir → vibe minimaliste
        Container(
          height: 32,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: const Text("todo", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 8),
        Text(
          "work",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
        ),
      ],
    );
  }
}