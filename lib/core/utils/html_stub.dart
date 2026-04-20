// Stub for dart:html to allow compilation on non-web platforms (e.g. Windows).
// These are no-ops; the real dart:html is used on Flutter Web.

class window {
  static _Location location = _Location();
  static _History history = _History();
}

class _Location {
  String href = '';
  String get origin => '';
}

class _History {
  void replaceState(dynamic data, String title, String? url) {}
}
