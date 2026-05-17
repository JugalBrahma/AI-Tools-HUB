// Stub for dart:html to allow compilation on non-web platforms (e.g. Windows).
// These are no-ops; the real dart:html is used on Flutter Web.

class window {
  static _Location location = _Location();
  static _History history = _History();
  static void open(String url, String target) {}
}

class _Location {
  String href = '';
  String get origin => '';
  String? get search => '';
}

class _History {
  void replaceState(dynamic data, String title, String? url) {}
}

class document {
  static String title = '';
  static List<NodeList> querySelectorAll(String selectors) => [];
  static _Element? querySelector(String selectors) => null;
  static _Head? head = _Head();
}

class _Element {
  void setAttribute(String name, String value) {}
  void remove() {}
}

class _Head {
  void append(ScriptElement element) {}
}

class NodeList implements _Element {
  @override
  void setAttribute(String name, String value) {}

  @override
  void remove() {}
}

class ScriptElement {
  String type = '';
  String text = '';
}
