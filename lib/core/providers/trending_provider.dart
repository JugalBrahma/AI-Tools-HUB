import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:toolshub/core/models/trending_model.dart';

class TrendingProvider with ChangeNotifier {
  Map<String, List<TrendingEntry>> _grouped = {};
  bool _isLoading = true;
  String? _error;

  /// All entries grouped by prefix (e.g. 'overall', 'image', 'video', etc.)
  Map<String, List<TrendingEntry>> get grouped => _grouped;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Convenience: get entries for a specific prefix, max 5
  List<TrendingEntry> entriesFor(String prefix) {
    return (_grouped[prefix] ?? []).take(5).toList();
  }

  TrendingProvider() {
    _listen();
  }

  void _listen() {
    FirebaseFirestore.instance
        .collection('trends')
        .snapshots()
        .listen(
          (snapshot) {
            final Map<String, List<TrendingEntry>> grouped = {};

            for (final doc in snapshot.docs) {
              final entry = TrendingEntry.fromFirestore(doc.data(), doc.id);
              // Extract prefix: "overall_1" → "overall", "vibecoding_3" → "vibecoding"
              final prefix = doc.id.replaceAll(RegExp(r'_?\d+$'), '');
              grouped.putIfAbsent(prefix, () => []).add(entry);
            }

            // Sort each group by rank
            for (final list in grouped.values) {
              list.sort((a, b) => a.rank.compareTo(b.rank));
            }

            _grouped = grouped;
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (err) {
            debugPrint('[TrendingProvider] ERROR: $err');
            _error = err.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }
}
