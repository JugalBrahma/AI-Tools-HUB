import 'package:flutter/material.dart';

/// Primary page heading with semantics for accessibility and SEO tooling.
class SeoPageHeading extends StatelessWidget {
  const SeoPageHeading({
    super.key,
    required this.text,
    required this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: text,
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}
