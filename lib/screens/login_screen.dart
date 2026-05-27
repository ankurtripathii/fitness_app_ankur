import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false, _googleLoading = false, _obscure = true;
  String? _error;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() { _googleLoading = true; _error = null; });
    try {
      await _auth.signInWithGoogle();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _googleLoading = false);
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
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF6EE7B7), Color(0xFF3B82F6)]),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.fitness_center,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 24),
                  const Text('Welcome back,\nChampion! 💪',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2)),
                  const SizedBox(height: 8),
                  const Text('Sign in to track your fitness journey',
                      style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      _buildField(_emailCtrl, 'Email', Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter email' : null),
                      const SizedBox(height: 14),
                      _buildField(_passCtrl, 'Password', Icons.lock_outline,
                          obscure: _obscure,
                          onToggle: () =>
                              setState(() => _obscure = !_obscure),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter password' : null),
                    ]),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.red.withOpacity(0.3))),
                      child: Row(children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_error!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 13))),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _signIn,
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
                          : const Text('Sign In',
                              style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or',
                          style: TextStyle(color: Colors.white38)),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ]),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _googleLoading ? null : _googleSignIn,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: Colors.white24),
                        foregroundColor: Colors.white,
                      ),
                      child: _googleLoading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.g_mobiledata,
                                    color: Colors.red, size: 24),
                                const SizedBox(width: 8),
                                const Text('Continue with Google'),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen())),
                      child: RichText(
                        text: const TextSpan(children: [
                          TextSpan(text: "New here? ",
                              style: TextStyle(color: Colors.white54)),
                          TextSpan(text: "Create account",
                              style: TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
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
                icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
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
            borderSide:
                const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
                color: Color(0xFF6EE7B7), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red)),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}
