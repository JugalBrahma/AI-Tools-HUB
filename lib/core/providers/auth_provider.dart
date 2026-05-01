import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool _isPro = false;
  String _status = 'free';
  DateTime? _expiryDate;
  String? _plan;

  bool get isPro => _isPro;
  String get status => _status;
  DateTime? get expiryDate => _expiryDate;
  String? get plan => _plan;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;
  Timer? _expiryTimer;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _userDocSubscription?.cancel();
      _expiryTimer?.cancel();
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

                _plan = data?['plan'];

                if (data?['expiry_date'] != null) {
                  final dynamic expiryVal = data!['expiry_date'];
                  try {
                    if (expiryVal is Timestamp) {
                      _expiryDate = expiryVal.toDate();
                    } else if (expiryVal is String) {
                      _expiryDate = DateTime.tryParse(expiryVal);
                    } else if (expiryVal is int) {
                      _expiryDate = DateTime.fromMillisecondsSinceEpoch(
                        expiryVal,
                      );
                    } else if (expiryVal is Map) {
                      // Sometimes REST APIs / n8n save Timestamps as maps
                      final seconds =
                          expiryVal['_seconds'] ?? expiryVal['seconds'];
                      if (seconds != null) {
                        _expiryDate = DateTime.fromMillisecondsSinceEpoch(
                          (seconds as int) * 1000,
                        );
                      }
                    } else {
                      // Fallback dynamic dispatch
                      _expiryDate = expiryVal.toDate();
                    }
                  } catch (e) {
                    print('⚠️ Error parsing expiry_date: $e');
                    _expiryDate = null;
                  }
                } else {
                  _expiryDate = null;
                }

                // Expiry Check
                if (_isPro && _expiryDate != null) {
                  if (DateTime.now().isAfter(_expiryDate!)) {
                    _isPro = false;
                    _status = 'expired';
                    // Update Firestore to reflect expiration
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({'is_pro': false, 'status': 'expired'});
                  } else {
                    _startExpiryTimer(user.uid);
                  }
                }

                notifyListeners();
              }
            });
      } else {
        _isPro = false;
        _expiryDate = null;
        _plan = null;
        _expiryTimer?.cancel();
        notifyListeners();
      }
    });
  }

  void _startExpiryTimer(String uid) {
    _expiryTimer?.cancel();
    _expiryTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_expiryDate != null && DateTime.now().isAfter(_expiryDate!)) {
        _isPro = false;
        _status = 'expired';
        FirebaseFirestore.instance.collection('users').doc(uid).update({
          'is_pro': false,
          'status': 'expired',
        });
        notifyListeners();
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _userDocSubscription?.cancel();
    super.dispose();
  }

  // ── Google Sign In (Web-compatible) ─────────────────────────────────────
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      
      final currentOrigin = Uri.base.origin;
      final expectedRedirectUri = '$currentOrigin/__/auth/handler';
      
      debugPrint('=== Google Sign-In Debug ===');
      debugPrint('Current Origin: $currentOrigin');
      debugPrint('Expected Redirect URI: $expectedRedirectUri');
      debugPrint('Firebase Auth Domain: www.aiworkx.space');
      
      // Support both localhost and production domains
      final isLocalhost = currentOrigin.contains('localhost') || currentOrigin.contains('127.0.0.1');
      final isProduction = currentOrigin.contains('aiworkx.space');
      
      if (!isLocalhost && !isProduction) {
        return 'Please test on localhost or https://www.aiworkx.space';
      }
      
      // Explicitly set the redirect URI for debugging
      googleProvider.setCustomParameters({
        'redirect_uri': expectedRedirectUri,
      });
      
      final result = await _auth.signInWithPopup(googleProvider);
      if (result.user != null) await _syncUserToFirestore(result.user!);
      notifyListeners();
      return null; // success
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      debugPrint('Current Origin: ${Uri.base.origin}');
      return 'Google Sign-In failed: ${e.toString()}';
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
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
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
          'ai_usage_count': 0,
          'created_at': FieldValue.serverTimestamp(),
          'last_login': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
        debugPrint('🆕 New user initialized: ${user.uid}');
      } else {
        // Ensure last_login is refreshed on every login (never touches is_pro / status)
        await userRef.update({
          'uid': user.uid,
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
