class TrendingEntry {
  final String docId;
  final int rank;
  final String name;
  final String logo;
  final String url;
  final String desc;

  const TrendingEntry({
    required this.docId,
    required this.rank,
    required this.name,
    required this.logo,
    required this.url,
    required this.desc,
  });

  factory TrendingEntry.fromFirestore(Map<String, dynamic> data, String docId) {
    final rankFromDoc =
        int.tryParse(docId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final rawLogo = (data['logo'] ?? '').toString().trim();
    final rawUrl  = (data['url']  ?? '').toString().trim();

    return TrendingEntry(
      docId: docId,
      rank:  (data['rank'] as num?)?.toInt() ?? rankFromDoc,
      name:  (data['name'] ?? '').toString(),
      logo:  _transformLogoUrl(rawLogo, fallbackUrl: rawUrl),
      url:   rawUrl,
      desc:  (data['desc'] ?? '').toString(),
    );
  }

  /// Converts any logo URL into the CORS-friendly gstatic FaviconV2 endpoint.
  ///
  /// Handles:
  ///  - Google S2 favicons  (`google.com/s2/favicons?domain=…`)
  ///  - gstatic FaviconV2   (already correct format, pass through)
  ///  - Clearbit logos      (`logo.clearbit.com/domain.com`) — shut down
  ///  - DuckDuckGo icons    (`icons.duckduckgo.com/ip3/…`)
  ///  - Direct image URLs   (`https://example.com/logo.png`)  → extract domain
  ///  - Empty logo          → fall back to tool's own URL domain
  static String _transformLogoUrl(String logoUrl, {String fallbackUrl = ''}) {
    // Helper to build the gstatic URL
    String gstatic(String siteUrl) =>
        'https://t3.gstatic.com/faviconV2'
        '?client=SOCIAL'
        '&type=FAVICON'
        '&fallback_opts=TYPE,SIZE,URL'
        '&url=${Uri.encodeComponent(siteUrl)}'
        '&size=128';

    // Helper to extract clean domain from any URL string
    String domain(String raw) {
      raw = raw.trim();
      if (raw.isEmpty) return '';
      if (!raw.contains('://')) raw = 'https://$raw';
      try {
        return Uri.parse(raw).host.replaceFirst('www.', '');
      } catch (_) {
        return '';
      }
    }

    if (logoUrl.isEmpty) {
      final d = domain(fallbackUrl);
      return d.isNotEmpty ? gstatic('https://$d') : '';
    }

    // Already a gstatic FaviconV2 URL — pass through
    if (logoUrl.contains('t3.gstatic.com/faviconV2')) return logoUrl;

    // Google S2 favicons
    if (logoUrl.contains('google.com/s2/favicons') ||
        logoUrl.contains('gstatic.com/faviconV2')) {
      try {
        final uri = Uri.parse(logoUrl);
        String d = uri.queryParameters['domain'] ??
            uri.queryParameters['url'] ?? '';
        d = d.replaceFirst(RegExp(r'^https?://'), '').split('/').first.trim();
        if (d.isNotEmpty) return gstatic('https://$d');
      } catch (_) {}
    }

    // Clearbit (shut down) — extract domain from URL path
    if (logoUrl.contains('logo.clearbit.com')) {
      try {
        final d = Uri.parse(logoUrl).pathSegments.firstWhere(
            (s) => s.contains('.'), orElse: () => '');
        if (d.isNotEmpty) return gstatic('https://$d');
      } catch (_) {}
    }

    // DuckDuckGo icons — extract domain
    if (logoUrl.contains('icons.duckduckgo.com/ip3/')) {
      try {
        final d = Uri.parse(logoUrl).pathSegments.last
            .replaceAll('.ico', '');
        if (d.isNotEmpty) return gstatic('https://$d');
      } catch (_) {}
    }

    // Any other URL — convert to gstatic using its domain
    final d = domain(logoUrl);
    if (d.isNotEmpty) return gstatic('https://$d');

    // Last resort: use the tool's own URL domain
    final fd = domain(fallbackUrl);
    return fd.isNotEmpty ? gstatic('https://$fd') : logoUrl;
  }
}
