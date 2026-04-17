import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:toolshub/core/models/tool_model.dart';
import 'package:toolshub/core/providers/tool_provider.dart';
import 'package:toolshub/features/home/widgets/animated_background.dart';
import 'package:toolshub/features/home/widgets/category_row.dart';
import 'package:toolshub/features/home/widgets/footer.dart';
import 'package:toolshub/features/home/widgets/hero_section.dart';
import 'package:toolshub/features/home/widgets/landing_content.dart';
import 'package:toolshub/features/home/widgets/popular_tools_grid.dart';
import 'package:toolshub/features/home/widgets/scroll_reveal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final toolProvider = context.watch<ToolProvider>();
    final allTools = <ToolInfo>[];
    for (final cat in toolProvider.categories) {
      allTools.addAll(cat.tools);
    }
    final totalTools = allTools.length;
    final totalCategories = toolProvider.categories.length;
    final toolsWithLogo = allTools
        .where((t) => t.logo.trim().isNotEmpty)
        .length;

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isPhone = screenWidth < 600;
    final double horizontalPadding = isPhone ? 20 : 40;

    return AnimatedGridBackground(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScrollReveal(
                        child: HeroSection(
                          toolCount: totalTools,
                          categoryCount: totalCategories,
                          logoCount: toolsWithLogo,
                        ),
                      ),
                      SizedBox(height: isPhone ? 60 : 100),
                      const ScrollReveal(delay: 0.2, child: CategoryRow()),
                      SizedBox(height: isPhone ? 80 : 120),
                      const PopularToolsGrid(),
                      SizedBox(height: isPhone ? 80 : 120),
                      const LandingContent(),
                      SizedBox(height: isPhone ? 80 : 120),
                      const Footer(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
