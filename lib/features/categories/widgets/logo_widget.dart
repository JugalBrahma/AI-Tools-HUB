import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolshub/core/models/tool_model.dart';

class LogoWidget extends StatefulWidget {
  const LogoWidget({
    super.key,
    required this.tool,
    this.size = 52.0,
    this.forceLocal = false,
  });
  final ToolInfo tool;
  final double size;
  final bool forceLocal;

  @override
  State<LogoWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget> {
  int _stage = 0;

  String get _domain {
    var url = widget.tool.url;
    if (url.isNotEmpty && !url.contains('://')) url = 'https://$url';
    if (url.isEmpty) return '';
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return '';
    }
  }

  String? get _localAsset {
    final name = widget.tool.name.toLowerCase().trim();
    final url = widget.tool.url.toLowerCase();

    bool matches(String term) => name.contains(term) || url.contains(term);

    // 1. Priority: Top Rated AI Tools (Static mapping)
    if (matches('chatgpt') || url.contains('openai'))
      return 'lib/core/assets/top_rated_ai_tools/chatgpt.png';
    if (matches('claude') || url.contains('anthropic'))
      return 'lib/core/assets/top_rated_ai_tools/claude.png';
    if (matches('gemini'))
      return 'lib/core/assets/top_rated_ai_tools/gemini.png';
    if (matches('perplexity'))
      return 'lib/core/assets/top_rated_ai_tools/perplexity.png';
    if (matches('midjourney'))
      return 'lib/core/assets/top_rated_ai_tools/midjourney.png';
    if (matches('cursor'))
      return 'lib/core/assets/top_rated_ai_tools/cursor.png';

    // 2. Secondary: Scroll Animation Logos (Dynamic mapping with overrides)
    // Naming Overrides for typos/specific filenames:
    const overrides = {
      'hugging face': 'higgingface.png',
      'huggingface': 'higgingface.png',
      'grammarly': 'grammerly.png',
      'logrocket': 'logRocket.png',
      'runway': 'runwayml.png',
      'stability ai': 'stability.png',
      'notion ai': 'notion.png',
      'notion': 'notion.png',
      'grok': 'x.png',
      'x': 'x.png',
      'twitter': 'x.png',
      'v0': 'v0.png',
      'veo': 'veo.png',
      'suno': 'suno.png',
      'canva': 'canva.jpeg',
      'pika': 'pika.png',
      'framer': 'framer.jpeg',
      'gamma': 'gamma.jpg',
      'make': 'make.jpg',
      'n8n': 'n8n.png',
      'bolt': 'bolt.png',
      'fireflies': 'fireflies.png',
      'replit': 'replit.png',
      'writesonic': 'writesonic.png',
      'elevenlabs': 'elevenlabs.png',
      'eleven labs': 'elevenlabs.png',
      'jasper': 'jasper.png',
      'leonardo': 'leonardo.png',
    };

    String? foundAsset;
    overrides.forEach((key, filename) {
      if (name.contains(key)) foundAsset = filename;
    });

    if (foundAsset != null) {
      return 'lib/core/assets/scroll_logo/$foundAsset';
    }

    // Default slugification: lowercase, no spaces, add .png
    final slug = name.replaceAll(' ', '');
    if (slug.isNotEmpty) {
      // We return the path and let the Image.asset errorBuilder handle if it's actually missing
      return 'lib/core/assets/scroll_logo/$slug.png';
    }

    return null;
  }

  String get _currentUrl {
    final d = _domain;
    String url;
    switch (_stage) {
      case 0:
        url = widget.tool.logo;
        break;
      case 1:
        url = d.isNotEmpty ? 'https://icons.duckduckgo.com/ip3/$d.ico' : '';
        break;
      case 2:
        url = d.isNotEmpty ? 'https://icon.horse/icon/$d' : '';
        break;
      case 3:
        url = d.isNotEmpty ? 'https://unavatar.io/$d' : '';
        break;
      case 4:
        url = d.isNotEmpty ? 'https://logo.clearbit.com/$d' : '';
        break;
      default:
        url = '';
    }
    return _wrapCORS(url);
  }

  String _wrapCORS(String url) {
    if (!kIsWeb || url.isEmpty || url.startsWith('assets/')) return url;
    // weserv.nl is a free image proxy that adds CORS headers
    // Reverted to 2.5x for a natural, sharp look without over-sharpening
    return 'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}&w=${(widget.size * 2.5).toInt()}&fit=contain';
  }

  void _nextStage() {
    if (widget.forceLocal) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _stage++);
    });
  }

  Widget _buildInitials() {
    final tool = widget.tool;
    final label = tool.name.length >= 2
        ? tool.name.substring(0, 2).toUpperCase()
        : tool.name.isNotEmpty
        ? tool.name[0].toUpperCase()
        : 'AI';

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: tool.logoGradient),
        borderRadius: BorderRadius.circular(widget.size * 0.27),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: widget.size * 0.35,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localPath = _localAsset;
    if (localPath != null && (_stage == 0 || widget.forceLocal)) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size * 0.27),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          localPath,
          fit: BoxFit.contain,
          scale: 1.0,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) {
            if (!widget.forceLocal) _nextStage();
            return _buildInitials();
          },
        ),
      );
    }

    if (widget.forceLocal || _stage >= 5 || (widget.tool.logo.isEmpty && widget.tool.url.isEmpty)) {
      return _buildInitials();
    }

    final url = _currentUrl;
    if (url.isEmpty) {
      _nextStage();
      return SizedBox(width: widget.size, height: widget.size);
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.size * 0.27),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        memCacheWidth: (widget.size * 2.5).toInt(),
        memCacheHeight: (widget.size * 2.5).toInt(),
        placeholder: (context, s) => _buildInitials(),
        errorWidget: (context, error, stack) {
          _nextStage();
          return _buildInitials();
        },
      ),
    );
  }
}
