import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toolshub/core/models/tool_model.dart';
import 'package:toolshub/core/providers/tool_provider.dart';
import 'package:toolshub/features/categories/widgets/logo_widget.dart';

class CategoryRow extends StatelessWidget {
  const CategoryRow({super.key});

  static const List<String> _topPreferredNames = [
    'chatgpt',
    'claude',
    'gemini',
    'n8n',
    'midjourney',
    'cursor',
    'notion ai',
    'bolt',
    'runway',
    'elevenlabs',
    'canva',
    'suno',
    'jasper',
    'hugging face',
    'stability',
    'openrouter',
    'replit',
    'bolt',
    'v0',
    'framer',
    'gamma',
    'leonardo',
    'veo',
    'lovable',
    'pika',
    'synthesia',
    'descript',
    'otter',
    'grammarly',
    'quillbot',
    'writesonic',
    'zapier',
    'make',
    'airtable',
    'logrocket',
    'mistral',
    'grok',
    'deepseek',
    'fireflies',
    'typefully',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ToolProvider>(context);
    final allTools = <ToolInfo>[];
    for (var cat in provider.categories) {
      allTools.addAll(cat.tools);
    }

    // Only show tools that have a logo URL
    final logoTools = allTools.where((t) => t.logo.trim().isNotEmpty).toList();

    if (logoTools.isEmpty && provider.isLoading) {
      return const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (logoTools.isEmpty) {
      return const SizedBox(height: 72);
    }

    final topRanked = _rankPopularByList(logoTools, _topPreferredNames);
    final top12 = topRanked.take(12).toList();
    final bottom12 = topRanked.skip(12).take(12).toList();

    // If catalog has less than 24 tools, bottom row falls back safely.
    final List<ToolInfo> group1 = top12;
    final List<ToolInfo> group2 = bottom12.isNotEmpty ? bottom12 : top12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScrollingRow(items: group1, reverse: false),
        const SizedBox(height: 16),
        _ScrollingRow(items: group2, reverse: true),
      ],
    );
  }

  List<ToolInfo> _rankPopularByList(List<ToolInfo> tools, List<String> keys) {
    final preferred = <ToolInfo>[];
    final others = <ToolInfo>[];
    final usedNames = <String>{};
    final usedKeys = <String>{};

    for (final tool in tools) {
      final name = tool.name.toLowerCase().trim();
      if (name.isEmpty || usedNames.contains(name)) continue;
      usedNames.add(name);

      String? matchedKey;
      for (final key in keys) {
        if (name.contains(key)) {
          matchedKey = key;
          break;
        }
      }

      if (matchedKey != null) {
        if (usedKeys.contains(matchedKey)) continue;
        usedKeys.add(matchedKey);
        preferred.add(tool);
      } else {
        others.add(tool);
      }
    }

    preferred.sort((a, b) {
      final ai = keys.indexWhere((k) => a.name.toLowerCase().contains(k));
      final bi = keys.indexWhere((k) => b.name.toLowerCase().contains(k));
      return ai.compareTo(bi);
    });

    others.sort((a, b) => a.name.compareTo(b.name));
    return [...preferred, ...others];
  }
}

class _ScrollingRow extends StatefulWidget {
  final List<ToolInfo> items;
  final bool reverse;
  const _ScrollingRow({required this.items, required this.reverse});

  @override
  State<_ScrollingRow> createState() => _ScrollingRowState();
}

class _ScrollingRowState extends State<_ScrollingRow>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  Duration _lastVisualTick = Duration.zero;
  final ValueNotifier<double> _offset = ValueNotifier(0.0);

  static const double _scrollSpeed =
      30.0; // Slightly slower for better web perf
  static const int _targetFrameMs = 33;
  static const double _itemSize = 72.0;
  static const double _itemMargin = 10.0;
  static const double _itemExtent = _itemSize + _itemMargin * 2;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if ((elapsed - _lastVisualTick).inMilliseconds < _targetFrameMs) return;
      final double delta = (elapsed - _lastElapsed).inMilliseconds / 1000.0;
      _lastElapsed = elapsed;
      _lastVisualTick = elapsed;

      double newOffset = _offset.value;
      if (widget.reverse) {
        newOffset -= _scrollSpeed * delta;
        if (newOffset <= 0) {
          newOffset += (_itemExtent * widget.items.length);
        }
      } else {
        newOffset += _scrollSpeed * delta;
        if (newOffset >= _itemExtent * widget.items.length) {
          newOffset -= _itemExtent * widget.items.length;
        }
      }
      _offset.value = newOffset;
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _offset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ValueListenableBuilder<double>(
        valueListenable: _offset,
        builder: (context, currentOffset, child) {
          return ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [0.0, 0.08, 0.92, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ClipRect(
              child: _CarouselLayout(
                offset: currentOffset,
                itemExtent: _itemExtent,
                itemSize: _itemSize,
                itemMargin: _itemMargin,
                items: widget.items,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CarouselLayout extends StatelessWidget {
  const _CarouselLayout({
    required this.offset,
    required this.itemExtent,
    required this.itemSize,
    required this.itemMargin,
    required this.items,
  });

  final double offset;
  final double itemExtent;
  final double itemSize;
  final double itemMargin;
  final List<ToolInfo> items;

  @override
  Widget build(BuildContext context) {
    final int count = items.length;
    final double totalWidth = itemExtent * count;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double viewWidth = constraints.maxWidth;
        final List<Widget> positioned = [];

        for (int cycle = -1; cycle < 3; cycle++) {
          for (int i = 0; i < count; i++) {
            final double x = (cycle * totalWidth) + (i * itemExtent) - offset;

            if (x + itemExtent < -100 || x > viewWidth + 100) continue;

            positioned.add(
              Positioned(
                left: x + itemMargin,
                top: 0,
                bottom: 0,
                width: itemSize,
                child: _CarouselItem(tool: items[i], size: itemSize),
              ),
            );
          }
        }

        return Stack(clipBehavior: Clip.none, children: positioned);
      },
    );
  }
}

class _CarouselItem extends StatelessWidget {
  const _CarouselItem({required this.tool, required this.size});
  final ToolInfo tool;
  final double size;

  @override
  Widget build(BuildContext context) {
    return LogoWidget(tool: tool, size: size, forceLocal: true);
  }
}
