import 'package:toolshub/core/utils/html_stub.dart'
    if (dart.library.html) 'dart:html'
    as html;

/// Service for managing SEO and structured data (rich snippets)
/// Dynamically injects JSON-LD structured data based on current route
class SeoService {
  static final SeoService _instance = SeoService._internal();
  factory SeoService() => _instance;
  SeoService._internal();

  static const String _baseUrl = 'https://www.aiworkx.space';

  /// Updates document title and meta tags for the current route (web).
  void updatePageMeta(String path) {
    final normalized = path.isEmpty ? '/' : path;
    final meta = _metaForPath(normalized);
    html.document.title = meta.title;
    _setMetaContent('description', meta.description);
    _setMetaContent('og:title', meta.title, isProperty: true);
    _setMetaContent('og:description', meta.description, isProperty: true);
    _setMetaContent('og:url', meta.canonical, isProperty: true);
    _setMetaContent('twitter:title', meta.title);
    _setMetaContent('twitter:description', meta.description);
    _setLinkHref('canonical', meta.canonical);
  }

  void _setMetaContent(String name, String content, {bool isProperty = false}) {
    final selector = isProperty
        ? 'meta[property="$name"]'
        : 'meta[name="$name"]';
    final element = html.document.querySelector(selector);
    element?.setAttribute('content', content);
  }

  void _setLinkHref(String rel, String href) {
    html.document.querySelector('link[rel="$rel"]')?.setAttribute('href', href);
  }

  ({String title, String description, String canonical}) _metaForPath(String path) {
    switch (path) {
      case '/trending':
        return (
          title: 'Trending AI Tools — Live Leaderboard | AI Tools Hub',
          description:
              'Real-time leaderboard of trending AI tools for coding, image, video, and writing. Updated daily.',
          canonical: '$_baseUrl/trending',
        );
      case '/assistant':
        return (
          title: 'AI Stack Assistant — Personalized Tool Recommendations',
          description:
              'Describe your goals and get personalized AI tool stack recommendations for coding, design, and content.',
          canonical: '$_baseUrl/assistant',
        );
      case '/bookmarks':
        return (
          title: 'Saved AI Tools — Your Bookmarks | AI Tools Hub',
          description:
              'Save and organize AI tools from the directory. Sign in to sync bookmarks across devices.',
          canonical: '$_baseUrl/bookmarks',
        );
      case '/':
      default:
        return (
          title: 'AI Tools Hub — The Ultimate AI Tool Directory',
          description:
              'Find the best AI tools for coding, image generation, video production, and writing. The most comprehensive AI directory updated daily.',
          canonical: '$_baseUrl/',
        );
    }
  }

  /// Update structured data based on current route
  void updateStructuredData(String path) {
    updatePageMeta(path);
    _clearExistingStructuredData();

    switch (path) {
      case '/assistant':
        _injectAssistantStructuredData();
        break;
      case '/bookmarks':
        _injectBookmarksStructuredData();
        break;
      case '/trending':
        _injectTrendingStructuredData();
        break;
      case '/':
      default:
        _injectHomeStructuredData();
        break;
    }
  }

  /// Clear all existing JSON-LD structured data scripts
  void _clearExistingStructuredData() {
    final scripts = html.document.querySelectorAll('script[type="application/ld+json"]');
    for (final script in scripts) {
      script.remove();
    }
  }

  void _injectBookmarksStructuredData() {
    final data = {
      '@context': 'https://schema.org',
      '@type': 'CollectionPage',
      'name': 'Saved AI Tools — Bookmarks',
      'url': '$_baseUrl/bookmarks',
      'description':
          'Personal shortlist of AI tools saved from the AI Tools Hub directory.',
      'inLanguage': 'en',
    };
    _injectJsonLd(data);
  }

  /// Inject structured data for AI Assistant page
  void _injectAssistantStructuredData() {
    final data = {
      '@context': 'https://schema.org',
      '@type': 'SoftwareApplication',
      'name': 'AI Tools Hub - AI Stack Assistant',
      'url': '$_baseUrl/assistant',
      'description': 'AI-powered tool stack recommender. Describe your goals and get personalized AI tool recommendations for coding, image generation, video production, and more.',
      'applicationCategory': 'UtilitiesApplication',
      'operatingSystem': 'Web',
      'offers': {
        '@type': 'Offer',
        'price': '0',
        'priceCurrency': 'USD',
      },
      'featureList': [
        'AI-powered tool recommendations',
        'Custom stack generation',
        'Category-based filtering',
        'Budget optimization',
        'Team size considerations',
      ],
      'aggregateRating': {
        '@type': 'AggregateRating',
        'ratingValue': '4.8',
        'ratingCount': '1000',
      },
    };

    _injectJsonLd(data);
  }

  /// Inject structured data for Trending page
  void _injectTrendingStructuredData() {
    final data = {
      '@context': 'https://schema.org',
      '@type': 'CollectionPage',
      'name': 'AI Tools Hub - Trending AI Tools',
      'url': '$_baseUrl/trending',
      'description': 'Real-time leaderboard of the most trending AI tools across coding, image generation, video production, and writing categories. Updated daily.',
      'about': {
        '@type': 'Thing',
        'name': 'Artificial Intelligence Tools',
        'description': 'Directory of trending AI applications and services',
      },
      'mainEntity': {
        '@type': 'ItemList',
        'itemListElement': [
          {
            '@type': 'ListItem',
            'position': 1,
            'name': 'Overall Trending',
            'description': 'Most dominant AI tools across all categories',
          },
          {
            '@type': 'ListItem',
            'position': 2,
            'name': 'Coding & Vibe Coding',
            'description': 'The future of software engineering',
          },
          {
            '@type': 'ListItem',
            'position': 3,
            'name': 'Image Generation',
            'description': 'AI-powered visual creation',
          },
          {
            '@type': 'ListItem',
            'position': 4,
            'name': 'Video Generation',
            'description': 'Next-gen AI video production',
          },
          {
            '@type': 'ListItem',
            'position': 5,
            'name': 'Writing',
            'description': 'AI writing, editing & content creation',
          },
        ],
      },
    };

    _injectJsonLd(data);
  }

  /// Inject structured data for Home page (fallback)
  void _injectHomeStructuredData() {
    final websiteData = {
      '@context': 'https://schema.org',
      '@type': 'WebSite',
      'name': 'AI Tools Hub',
      'url': _baseUrl,
      'description': 'Find the best AI tools for coding, image generation, video production, and writing.',
      'potentialAction': {
        '@type': 'SearchAction',
        'target': '$_baseUrl/search?q={search_term_string}',
        'query-input': 'required name=search_term_string',
      },
    };

    final orgData = {
      '@context': 'https://schema.org',
      '@type': 'Organization',
      'name': 'AI Tools Hub',
      'url': _baseUrl,
      'logo': '$_baseUrl/icons/Icon-512.png',
      'description': 'The most comprehensive AI tool directory updated daily',
      'sameAs': [
        'https://twitter.com/aiworkx',
        'https://github.com/jugalbrahma',
      ],
    };

    final breadcrumbData = {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      'itemListElement': [
        {
          '@type': 'ListItem',
          'position': 1,
          'name': 'Home',
          'item': _baseUrl,
        },
        {
          '@type': 'ListItem',
          'position': 2,
          'name': 'AI Tools',
          'item': '$_baseUrl/tools',
        },
      ],
    };

    final appData = {
      '@context': 'https://schema.org',
      '@type': 'SoftwareApplication',
      'name': 'AI Tools Hub',
      'applicationCategory': 'UtilitiesApplication',
      'operatingSystem': 'Web',
      'offers': {
        '@type': 'Offer',
        'price': '0',
        'priceCurrency': 'USD',
      },
      'aggregateRating': {
        '@type': 'AggregateRating',
        'ratingValue': '4.8',
        'ratingCount': '1000',
      },
      'description': 'Find the best AI tools for coding, image generation, video production, and writing.',
    };

    _injectJsonLd(websiteData);
    _injectJsonLd(orgData);
    _injectJsonLd(breadcrumbData);
    _injectJsonLd(appData);
  }

  /// Inject JSON-LD script tag into head
  void _injectJsonLd(Map<String, dynamic> data) {
    final script = html.ScriptElement();
    script.type = 'application/ld+json';
    script.text = _jsonEncode(data);
    html.document.head?.append(script);
  }

  /// Simple JSON encoder (avoiding dart:convert for minimal dependencies)
  String _jsonEncode(Map<String, dynamic> data) {
    return _encodeValue(data);
  }

  String _encodeValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"${_escapeString(value)}"';
    if (value is num) return value.toString();
    if (value is bool) return value ? 'true' : 'false';
    if (value is List) {
      return '[${value.map((e) => _encodeValue(e)).join(',')}]';
    }
    if (value is Map) {
      final entries = value.entries.map((e) => '"${e.key}":${_encodeValue(e.value)}');
      return '{${entries.join(',')}}';
    }
    return 'null';
  }

  String _escapeString(String str) {
    return str
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}
