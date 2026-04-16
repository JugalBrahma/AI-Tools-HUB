import 'package:flutter/material.dart';
import 'package:toolshub/features/home/widgets/scroll_reveal.dart';
import 'sections/discovery_engine_section.dart';
import 'sections/four_steps_section.dart';
import 'sections/whats_hot_section.dart';
import 'sections/who_is_this_for_section.dart';
import 'sections/cta_section.dart';

class LandingContent extends StatelessWidget {
  const LandingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 40),
        ScrollReveal(child: DiscoveryEngineSection()),
        SizedBox(height: 140),
        ScrollReveal(delay: 0.1, child: FourStepsSection()),
        SizedBox(height: 140),
        ScrollReveal(delay: 0.2, child: WhatsHotSection()),
        SizedBox(height: 160),
        ScrollReveal(delay: 0.3, child: WhoIsThisForSection()),
        SizedBox(height: 160),
        ScrollReveal(delay: 0.4, child: CtaSection()),
        SizedBox(height: 80),
      ],
    );
  }
}
