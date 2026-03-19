import 'package:flutter/widgets.dart';

class LiteLine extends StatelessWidget {
  const LiteLine({
    super.key,
    this.spacing = 0,
    this.runSpacing = 0,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.center,
    this.direction = Axis.horizontal,
    this.textDirection,
    required this.children,
  });

  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final Axis direction;
  final TextDirection? textDirection;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: direction,
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      children: children,
    );
  }
}
