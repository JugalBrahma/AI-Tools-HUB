import 'package:flutter/material.dart';
import 'tool_card.dart';
import 'package:toolshub/core/models/tool_model.dart';

class ToolSliverGrid extends StatelessWidget {
  const ToolSliverGrid({super.key, required this.tools, required this.themeColor});
  final List<ToolInfo> tools;
  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.crossAxisExtent;
        final crossCount = w > 1000
            ? 4
            : w > 700
            ? 3
            : w > 460
            ? 2
            : 1;
        
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: w < 600 ? 0.95 : 0.75,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => ToolCard(tool: tools[i], themeColor: themeColor),
            childCount: tools.length,
          ),
        );
      },
    );
  }
}
