import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolshub/core/models/tool_model.dart';

class LogoWidget extends StatefulWidget {
  const LogoWidget({super.key, required this.tool});
  final ToolInfo tool;

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
    if (name.contains('chatgpt')) return 'lib/core/assets/top_rated_ai_tools/chatgpt.png';
    if (name.contains('claude')) return 'lib/core/assets/top_rated_ai_tools/claude.png';
    if (name.contains('gemini')) return 'lib/core/assets/top_rated_ai_tools/gemini.png';
    if (name.contains('perplexity')) return 'lib/core/assets/top_rated_ai_tools/perplexity.png';
    if (name.contains('midjourney')) return 'lib/core/assets/top_rated_ai_tools/midjourney.png';
    if (name.contains('cursor')) return 'lib/core/assets/top_rated_ai_tools/cursor.png';
    return null;
  }

  String get _currentUrl {
    final d = _domain;
    switch (_stage) {
      case 0: return widget.tool.logo;
      case 1: return d.isNotEmpty ? 'https://icons.duckduckgo.com/ip3/$d.ico' : '';
      case 2: return d.isNotEmpty ? 'https://icon.horse/icon/$d' : '';
      case 3: return d.isNotEmpty ? 'https://unavatar.io/$d' : '';
      case 4: return d.isNotEmpty ? 'https://logo.clearbit.com/$d' : '';
      default: return '';
    }
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
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: tool.logoGradient),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 18,
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
    if (localPath != null) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          localPath,
          fit: BoxFit.contain,
        ),
      );
    }

    if (_stage >= 5 || (widget.tool.logo.isEmpty && widget.tool.url.isEmpty)) {
      return _buildInitials();
    }

    final url = _currentUrl;
    if (url.isEmpty) { _nextStage(); return const SizedBox(width: 52, height: 52); }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.low,
        memCacheWidth: 52 * 2, // Double for retina displays
        memCacheHeight: 52 * 2,
        placeholder: (context, s) => _buildInitials(),
        errorWidget: (context, error, stack) {
          return SvgPicture.network(
            url,
            width: 52,
            height: 52,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, s) { _nextStage(); return _buildInitials(); },
          );
        },
      ),
    );
  }
}
