import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarkProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Set<String> _bookmarkedIds = {};
  StreamSubscription? _subscription;
  String? _lastUserId;

  BookmarkProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        if (_lastUserId != user.uid) {
          _lastUserId = user.uid;
          _startSync(user.uid);
        }
      } else {
        _stopSync();
      }
    });
  }

  Set<String> get bookmarkedIds => _bookmarkedIds;
  int get count => _bookmarkedIds.length;
  bool isBookmarked(String toolId) => _bookmarkedIds.contains(toolId);

  void _startSync(String userId) {
    _subscription?.cancel();
    _subscription = _firestore
        .collection('bookmarks')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['toolIds'] is List) {
          _bookmarkedIds = Set<String>.from(data['toolIds']);
        }
      } else {
        _bookmarkedIds = {};
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint('Bookmark sync error: $e');
    });
  }

  void _stopSync() {
    _subscription?.cancel();
    _subscription = null;
    _lastUserId = null;
    _bookmarkedIds = {};
    notifyListeners();
  }

  Future<void> toggleBookmark(String toolId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('bookmarks').doc(user.uid);
    final wasBookmarked = _bookmarkedIds.contains(toolId);

    // Optimistic UI update
    if (wasBookmarked) {
      _bookmarkedIds.remove(toolId);
    } else {
      _bookmarkedIds.add(toolId);
    }
    notifyListeners();

    try {
      await docRef.set({
        'toolIds': wasBookmarked
            ? FieldValue.arrayRemove([toolId])
            : FieldValue.arrayUnion([toolId])
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
      // Revert on error
      if (wasBookmarked) {
        _bookmarkedIds.add(toolId);
      } else {
        _bookmarkedIds.remove(toolId);
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
