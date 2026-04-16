import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<String> _recentToolIds = [];
  StreamSubscription? _subscription;
  String? _lastUserId;

  HistoryProvider() {
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

  List<String> get recentToolIds => _recentToolIds;
  int get usageCount => _recentToolIds.length;

  void _startSync(String userId) {
    _subscription?.cancel();
    _subscription = _firestore
        .collection('usage_history')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['tools'] is List) {
          _recentToolIds = List<String>.from(data['tools']);
        }
      } else {
        _recentToolIds = [];
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint('History sync error: $e');
    });
  }

  void _stopSync() {
    _subscription?.cancel();
    _subscription = null;
    _lastUserId = null;
    _recentToolIds = [];
    notifyListeners();
  }

  Future<void> recordUsage(String toolId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('usage_history').doc(user.uid);
    
    List<String> newList = List.from(_recentToolIds);
    newList.remove(toolId);
    newList.insert(0, toolId);
    if (newList.length > 10) newList = newList.sublist(0, 10);
    
    _recentToolIds = newList;
    notifyListeners();

    try {
      await docRef.set({
        'tools': newList,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error recording usage: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
