import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool _isPro = false;
  String _status = 'free';
  bool get isPro => _isPro;
  String get status => _status;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _userDocSubscription?.cancel();
      if (user != null) {
        _userDocSubscription = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
              if (snapshot.exists) {
                final data = snapshot.data() as Map<String, dynamic>?;
                _isPro = data?['is_pro'] ?? false;
                _status = data?['status'] ?? 'free';
                notifyListeners();
              }
            });
      } else {
        _isPro = false;
        notifyListeners();
      }
    });
  }

  // ── Google Sign In (Web-compatible) ─────────────────────────────────────
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      final result = await _auth.signInWithPopup(googleProvider);
      if (result.user != null) await _syncUserToFirestore(result.user!);
      notifyListeners();
      return null; // success
    } catch (e) {
      return 'Google Sign-In failed. Please try again.';
    }
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) await _syncUserToFirestore(result.user!);
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e.code);
    }
  }

  // ── Email & Password Sign Up ─────────────────────────────────────────────
  Future<String?> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      if (credential.user != null) await _syncUserToFirestore(credential.user!);
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e.code);
    }
  }

  // ── Sync / Create User Document in Firestore ─────────────────────────────
  Future<void> _syncUserToFirestore(User user) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await userRef.get();

      if (!doc.exists) {
        // ONLY Create fresh for new users. 
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'is_pro': false,         
          'status': 'free',        
          'payment_id': null,
          'amount': 0.0,
          'last_ai_usage': null,
          'created_at': FieldValue.serverTimestamp(),
          'last_login': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
        debugPrint('🆕 New user initialized: ${user.uid}');
      } else {
        // Ensure existing users also have the 'user_id' field without overwriting pro status
        await userRef.update({
          'user_id': user.uid,
          'last_login': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
        debugPrint('🔄 Existing user synced: ${user.uid}');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to sync user to Firestore: $e');
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
