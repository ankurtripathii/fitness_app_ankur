import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false, _obscure = true, _obscureC = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.signUpWithEmail(
          _emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context)),
                const SizedBox(height: 16),
                const Text('Start your\nfitness journey! 🏆',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2)),
                const SizedBox(height: 8),
                const Text('Create an account to get started',
                    style: TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 36),
                Form(
                  key: _formKey,
                  child: Column(children: [
                    _field(_emailCtrl, 'Email', Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v == null || !v.contains('@') ? 'Invalid email' : null),
                    const SizedBox(height: 14),
                    _field(_passCtrl, 'Password', Icons.lock_outline,
                        obscure: _obscure,
                        onToggle: () => setState(() => _obscure = !_obscure),
                        validator: (v) => v == null || v.length < 6
                            ? 'Min 6 characters' : null),
                    const SizedBox(height: 14),
                    _field(_confirmCtrl, 'Confirm password',
                        Icons.lock_outline,
                        obscure: _obscureC,
                        onToggle: () =>
                            setState(() => _obscureC = !_obscureC),
                        validator: (v) =>
                            v != _passCtrl.text ? 'Passwords do not match' : null),
                  ]),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.red.withOpacity(0.3))),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6EE7B7),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.black54, strokeWidth: 2))
                        : const Text('Create Account',
                            style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool obscure = false,
      VoidCallback? onToggle,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white38),
        suffixIcon: onToggle != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white38),
                onPressed: onToggle)
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFF6EE7B7), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red)),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}
