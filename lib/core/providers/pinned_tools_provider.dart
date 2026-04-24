import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PinnedTool {
  final String id;
  final String toolName;
  final String url;
  final String whyItFits;

  PinnedTool({
    required this.id,
    required this.toolName,
    required this.url,
    required this.whyItFits,
  });

  factory PinnedTool.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PinnedTool(
      id: doc.id,
      toolName: data['toolName'] ?? 'Unknown',
      url: data['url'] ?? '',
      whyItFits: data['why_it_fits'] ?? data['best_for'] ?? '',
    );
  }
}

class PinnedToolsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<PinnedTool> _pinnedTools = [];
  StreamSubscription? _subscription;
  String? _lastUserId;

  PinnedToolsProvider() {
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

  List<PinnedTool> get pinnedTools => _pinnedTools;
  int get count => _pinnedTools.length;

  void _startSync(String userId) {
    _subscription?.cancel();
    _subscription = _firestore
        .collection('ai_history')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('pinnedAt', descending: true)
        .snapshots()
        .listen((snapshot) {


      _pinnedTools = snapshot.docs.map((doc) => PinnedTool.fromFirestore(doc)).toList();
      notifyListeners();
    }, onError: (e) {
      debugPrint('Pinned tools sync error: $e');
    });
  }

  void _stopSync() {
    _subscription?.cancel();
    _subscription = null;
    _lastUserId = null;
    _pinnedTools = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
