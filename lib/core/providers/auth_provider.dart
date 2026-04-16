import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthProvider() {
    _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  // ── Google Sign In (Web-compatible) ─────────────────────────────────────
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      await _auth.signInWithPopup(googleProvider);
      notifyListeners();
      return null; // success
    } catch (e) {
      return 'Google Sign-In failed. Please try again.';
    }
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e.code);
    }
  }

  // ── Email & Password Sign Up ─────────────────────────────────────────────
  Future<String?> signUpWithEmail(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e.code);
    }
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // ── Error Messages ───────────────────────────────────────────────────────
  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
