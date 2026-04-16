import 'package:flutter/material.dart';

class ToolInfo {
  final String docId;
  final String name;
  final String url;
  final String description;
  final String logo;
  final String category;
  final String pricing;
  final Color accentColor;
  final List<Color> logoGradient;
  final String searchName;
  final String searchDescription;

  const ToolInfo({
    required this.docId,
    required this.name,
    required this.url,
    required this.description,
    required this.logo,
    required this.category,
    required this.pricing,
    required this.accentColor,
    required this.logoGradient,
    required this.searchName,
    required this.searchDescription,
  });

  factory ToolInfo.fromFirestore(
    Map<String, dynamic> data,
    String docId, {
    String? categoryFromPath,
  }) {
    final name = (data['name'] ?? '').toString();
    final description = (data['description'] ?? '').toString();
    final colors = _generateColors(name);

    String resolvedCategory =
        (data['category']?.toString() ?? categoryFromPath ?? 'Other').trim();
    if (resolvedCategory.isEmpty) resolvedCategory = 'Other';

    final rawLogo = (data['logo'] ?? '').toString().trim();
    final transformedLogo = _transformLogoUrl(rawLogo);

    return ToolInfo(
      docId: docId,
      name: name,
      url: (data['url'] ?? '').toString(),
      description: description,
      logo: transformedLogo,
      category: resolvedCategory,
      pricing: (data['pricing']?.toString() ?? '').trim(),
      accentColor: colors[0],
      logoGradient: colors,
      searchName: name.toLowerCase(),
      searchDescription: description.toLowerCase(),
    );
  }

  /// Transforms logo URLs to be CORS-friendly for Flutter Web.
  ///
  /// The old Google Favicons endpoint (`google.com/s2/favicons`) and Clearbit
  /// (`logo.clearbit.com`) are either CORS-blocked or shut down.
  ///
  /// We use Google's newer gstatic FaviconV2 API which:
  ///  - Sets proper `Access-Control-Allow-Origin` headers (CORS-friendly)
  ///  - Is used by Google Calendar, Keep, etc. — stable and reliable
  ///  - Returns a real PNG image with a graceful fallback for unknown domains
  static String _transformLogoUrl(String url) {
    if (url.isEmpty) return url;

    // Extract domain from Google Favicons API URLs
    // Format: https://www.google.com/s2/favicons?domain=https://example.com&sz=128
    if (url.contains('google.com/s2/favicons') ||
        url.contains('gstatic.com/faviconV2')) {
      try {
        final uri = Uri.parse(url);
        String domain = uri.queryParameters['domain'] ??
            uri.queryParameters['url'] ??
            '';
        // Strip protocol (https:// or http://) if present
        domain = domain.replaceFirst(RegExp(r'^https?://'), '');
        // Keep only the host part
        domain = domain.split('/').first.trim();
        if (domain.isNotEmpty) {
          return _gstaticFaviconUrl('https://$domain');
        }
      } catch (_) {
        // URL parse failed — return original and let errorBuilder handle it
      }
    }

    return url;
  }

  /// Builds a Google gstatic FaviconV2 URL for a given site URL.
  /// This API is CORS-compliant and used internally by Google's web products.
  static String _gstaticFaviconUrl(String siteUrl) {
    return 'https://t3.gstatic.com/faviconV2'
        '?client=SOCIAL'
        '&type=FAVICON'
        '&fallback_opts=TYPE,SIZE,URL'
        '&url=${Uri.encodeComponent(siteUrl)}'
        '&size=128';
  }

  /// Returns a DuckDuckGo favicon URL for a given domain (used as fallback).
  /// DDG sets `Access-Control-Allow-Origin: *` — fully CORS-friendly.
  static String duckduckgoFaviconUrl(String domain) {
    return 'https://icons.duckduckgo.com/ip3/$domain.ico';
  }


  static List<Color> _generateColors(String name) {
    if (name.isEmpty) return const [Color(0xFF6C5CE7), Color(0xFF4834D4)];
    final double hue = (name.hashCode.abs() % 360).toDouble();
    final color = HSLColor.fromAHSL(1.0, hue, 0.8, 0.6).toColor();
    final darkColor = HSLColor.fromAHSL(1.0, hue, 0.9, 0.4).toColor();
    return [color, darkColor];
  }
}

class CategoryData {
  final IconData icon;
  final String name;
  final Color themeColor;
  final List<ToolInfo> tools;

  const CategoryData({
    required this.icon,
    required this.name,
    required this.themeColor,
    required this.tools,
  });
}
