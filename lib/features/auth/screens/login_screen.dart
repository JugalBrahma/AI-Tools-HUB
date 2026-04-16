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
  String? _error;

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
                                  'Welcome to Icon Hub',
                                  style: GoogleFonts.inter(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sign in to access your bookmarks\nand personalised AI tool recommendations.',
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

                                // Google Sign-In button
                                _loading
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: CircularProgressIndicator(color: Color(0xFF4A89FF), strokeWidth: 2),
                                      )
                                    : _GoogleButton(onTap: _signInWithGoogle),

                                const SizedBox(height: 24),

                                // Footer note
                                Text(
                                  'By signing in you agree to our Terms of Service\nand Privacy Policy.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF444455), height: 1.6),
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

// ── Google Sign-In Button ─────────────────────────────────────────────────────

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
                width: 22,
                height: 22,
                errorBuilder: (_, __, ___) => const Text('G', style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 14),
              Text(
                'Continue with Google',
                style: GoogleFonts.inter(
                  fontSize: 15,
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
