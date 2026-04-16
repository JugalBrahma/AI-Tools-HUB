import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolshub/core/models/tool_model.dart';

class LogoWidget extends StatefulWidget {
  const LogoWidget({super.key, required this.tool, this.size = 52.0});
  final ToolInfo tool;
  final double size;

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
    final name = widget.tool.name.toLowerCase();
    final url = widget.tool.url.toLowerCase();
    
    bool matches(String term) => name.contains(term) || url.contains(term);

    if (matches('chatgpt') || url.contains('openai')) return 'lib/core/assets/top_rated_ai_tools/chatgpt.png';
    if (matches('claude') || url.contains('anthropic')) return 'lib/core/assets/top_rated_ai_tools/claude.png';
    if (matches('gemini')) return 'lib/core/assets/top_rated_ai_tools/gemini.png';
    if (matches('perplexity')) return 'lib/core/assets/top_rated_ai_tools/perplexity.png';
    if (matches('midjourney')) return 'lib/core/assets/top_rated_ai_tools/midjourney.png';
    if (matches('cursor')) return 'lib/core/assets/top_rated_ai_tools/cursor.png';
    
    return null;
  }

  String get _currentUrl {
    final d = _domain;
    String url;
    switch (_stage) {
      case 0: url = widget.tool.logo; break;
      case 1: url = d.isNotEmpty ? 'https://icons.duckduckgo.com/ip3/$d.ico' : ''; break;
      case 2: url = d.isNotEmpty ? 'https://icon.horse/icon/$d' : ''; break;
      case 3: url = d.isNotEmpty ? 'https://unavatar.io/$d' : ''; break;
      case 4: url = d.isNotEmpty ? 'https://logo.clearbit.com/$d' : ''; break;
      default: url = '';
    }
    return _wrapCORS(url);
  }

  String _wrapCORS(String url) {
    if (!kIsWeb || url.isEmpty || url.startsWith('assets/')) return url;
    // weserv.nl is a free image proxy that adds CORS headers
    return 'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}&w=${(widget.size * 2).toInt()}&fit=contain';
  }

  void _nextStage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _stage++);
    });
  }

  Widget _buildInitials() {
    final tool = widget.tool;
    final label = tool.name.length >= 2
        ? tool.name.substring(0, 2).toUpperCase()
        : tool.name.isNotEmpty ? tool.name[0].toUpperCase() : 'AI';

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
    if (localPath != null && _stage == 0) {
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
          errorBuilder: (context, error, stackTrace) {
            _nextStage();
            return _buildInitials();
          },
        ),
      );
    }

    if (_stage >= 5 || (widget.tool.logo.isEmpty && widget.tool.url.isEmpty)) {
      return _buildInitials();
    }

    final url = _currentUrl;
    if (url.isEmpty) { _nextStage(); return SizedBox(width: widget.size, height: widget.size); }

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
        filterQuality: FilterQuality.low,
        memCacheWidth: (widget.size * 2).toInt(),
        memCacheHeight: (widget.size * 2).toInt(),
        placeholder: (context, s) => _buildInitials(),
        errorWidget: (context, error, stack) {
          _nextStage();
          return _buildInitials();
        },
      ),
    );
  }
}
