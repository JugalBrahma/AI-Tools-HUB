import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolshub/core/models/tool_model.dart';
import 'package:toolshub/core/widgets/logo_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolCard extends StatefulWidget {
  final ToolInfo tool;
  final Color themeColor;
  final bool showBookmark;
  final bool showDelete;
  final VoidCallback? onDelete;
  final VoidCallback? onBookmarkToggle;

  const ToolCard({
    super.key,
    required this.tool,
    required this.themeColor,
    this.showBookmark = true,
    this.showDelete = false,
    this.onDelete,
    this.onBookmarkToggle,
  });

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  bool _isHovered = false;

  Future<void> _launchUrl() async {
    final url = Uri.parse(widget.tool.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;
    final color = widget.themeColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Container(
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFF16161E) : const Color(0xFF0F0F15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? color.withOpacity(0.5) : const Color(0xFF24242A),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LogoWidget(
                        tool: tool,
                        size: 32,
                      ),
                      if (widget.showDelete)
                        _SmallIconButton(
                          icon: Icons.close_rounded,
                          color: Colors.white24,
                          hoverColor: Colors.redAccent,
                          onTap: widget.onDelete,
                        )
                      else if (widget.showBookmark)
                        _SmallIconButton(
                          icon: Icons.bookmark_rounded,
                          color: color.withOpacity(0.5),
                          hoverColor: color,
                          onTap: widget.onBookmarkToggle,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tool.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: Text(
                      tool.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white38,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 3,
                        child: _CompactBadge(
                          label: tool.pricing.toUpperCase(),
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        flex: 2,
                        child: Text(
                          _getDisplayCategory(tool.name, tool.category),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 8,
                            color: Colors.white10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _launchUrl,
                borderRadius: BorderRadius.circular(16),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayCategory(String name, String original) {
    final n = name.toLowerCase();
    if (n.contains('chatgpt') || n.contains('claude') || n.contains('gemini')) return 'AI';
    if (n.contains('perplexity')) return 'SEARCH';
    if (n.contains('midjourney')) return 'IMAGE';
    return original.split(' ').first.toUpperCase();
  }
}

class _CompactBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CompactBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.ibmPlexMono(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _SmallIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color hoverColor;
  final VoidCallback? onTap;

  const _SmallIconButton({
    required this.icon,
    required this.color,
    required this.hoverColor,
    this.onTap,
  });

  @override
  State<_SmallIconButton> createState() => _SmallIconButtonState();
}

class _SmallIconButtonState extends State<_SmallIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Icon(
          widget.icon,
          color: _isHovered ? widget.hoverColor : widget.color,
          size: 16,
        ),
      ),
    );
  }
}


