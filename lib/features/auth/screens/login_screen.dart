import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toolshub/core/providers/auth_provider.dart' as app_auth;

class LoginScreen extends StatefulWidget {
  final VoidCallback? onDismiss;
  const LoginScreen({super.key, this.onDismiss});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  bool _isLoginMode = true;
  String? _error;

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && mounted) _handleSuccess();
    });
  }

  void _handleSuccess() {
    _authSub?.cancel();
    _authSub = null;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _error = null; });
    final auth = context.read<app_auth.AuthProvider>();
    final error = await auth.signInWithGoogle();
    if (!mounted) return;
    if (error != null) {
      setState(() { _error = error; _loading = false; });
    } else {
      widget.onDismiss?.call();
    }
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLoginMode && name.isEmpty)) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    final auth = context.read<app_auth.AuthProvider>();
    
    String? error;
    if (_isLoginMode) {
      error = await auth.signInWithEmail(email, password);
    } else {
      error = await auth.signUpWithEmail(email, password, name);
    }

    if (!mounted) return;
    if (error != null) {
      setState(() { _error = error; _loading = false; });
    } else {
      widget.onDismiss?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: const Color(0xFF030303),
        body: Stack(
          children: [
            // Background glow — top left
            Positioned(
              top: -200, left: -200,
              child: Container(
                width: 600, height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00D4AA).withOpacity(0.04),
                ),
              ),
            ),
            // Background glow — bottom right
            Positioned(
              bottom: -200, right: -200,
              child: Container(
                width: 500, height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4A89FF).withOpacity(0.05),
                ),
              ),
            ),

            // Main content
            Center(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                      child: Column(
                        children: [
                          // ── Logo ─────────────────────────────────────────
                          Image.asset(
                            'assets/logo/AI HUB.png',
                            height: 52,
                            errorBuilder: (_, __, ___) => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFF00D4AA), Color(0xFF4A89FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Text('AI HUB', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // ── Card ─────────────────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0F),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF1C1C2E)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Heading
                                Text(
                                  _isLoginMode ? 'Welcome Back' : 'Create Account',
                                  style: GoogleFonts.inter(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isLoginMode 
                                    ? 'Sign in to access your dashboard'
                                    : 'Join AI Hub to start your journey',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFF666677),
                                    height: 1.6,
                                  ),
                                ),

                                const SizedBox(height: 36),

                                // Error message
                                if (_error != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 16),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(_error!, style: GoogleFonts.inter(fontSize: 13, color: Colors.redAccent)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // ── Text Fields ──────────────────────────────────
                                if (!_isLoginMode) ...[
                                  _CustomTextField(
                                    controller: _nameCtrl,
                                    hintText: 'Full Name',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                _CustomTextField(
                                  controller: _emailCtrl,
                                  hintText: 'Email Address',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),
                                _CustomTextField(
                                  controller: _passwordCtrl,
                                  hintText: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                ),

                                const SizedBox(height: 24),

                                // Main Action Button
                                _loading
                                    ? const CircularProgressIndicator(color: Color(0xFF4A89FF), strokeWidth: 2)
                                    : _PrimaryButton(
                                        text: _isLoginMode ? 'Sign In' : 'Create Account',
                                        onTap: _handleEmailAuth,
                                      ),

                                const SizedBox(height: 20),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: const Color(0xFF1C1C2E))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text('OR', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF444455), fontWeight: FontWeight.bold)),
                                    ),
                                    Expanded(child: Divider(color: const Color(0xFF1C1C2E))),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Google Sign-In button
                                _GoogleButton(onTap: _signInWithGoogle),

                                const SizedBox(height: 24),

                                // Toggle Mode
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _isLoginMode = !_isLoginMode;
                                    _error = null;
                                  }),
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF666677)),
                                      children: [
                                        TextSpan(text: _isLoginMode ? 'New here? ' : 'Already have an account? '),
                                        TextSpan(
                                          text: _isLoginMode ? 'Create account' : 'Sign in',
                                          style: const TextStyle(color: Color(0xFF4A89FF), fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Components ──────────────────────────────────────────────────────────────

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;

  const _CustomTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1C1C2C)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: const Color(0xFF444455), fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF444455), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _PrimaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A89FF), Color(0xFF00D4AA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A89FF).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatefulWidget {
  final VoidCallback onTap;
  const _GoogleButton({required this.onTap});

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _hovering ? const Color(0xFF141420) : const Color(0xFF0E0E18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovering ? const Color(0xFF2A2A3C) : const Color(0xFF1C1C2C),
              width: 1.5,
            ),
            boxShadow: _hovering
                ? [BoxShadow(color: const Color(0xFF4A89FF).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
                width: 18,
                height: 18,
                errorBuilder: (_, __, ___) => const Text('G', style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _hovering ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
