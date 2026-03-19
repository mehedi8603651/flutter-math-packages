import 'package:flutter/widgets.dart';
import 'package:flutter_math_model/ast.dart';

import '../../lite_math_options.dart';

class LiteFraction extends StatelessWidget {
  const LiteFraction({
    super.key,
    required this.numerator,
    required this.denominator,
    required this.options,
    this.barColor,
    this.barThickness,
    this.padding,
  });

  final Widget numerator;
  final Widget denominator;
  final LiteMathOptions options;
  final Color? barColor;
  final double? barThickness;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final numeratorOptions = options.forChildStyle(options.style.fracNum());
    final denominatorOptions = options.forChildStyle(options.style.fracDen());
    final resolvedPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: options.fontSize * 0.2,
          vertical: options.fontSize * 0.08,
        );

    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DefaultTextStyle.merge(
            style: numeratorOptions.resolveTextStyle(textMode: true),
            child: Padding(
              padding: resolvedPadding,
              child: Center(child: numerator),
            ),
          ),
          Container(
            height: barThickness ?? options.lineThickness,
            color: barColor ?? options.color,
          ),
          DefaultTextStyle.merge(
            style: denominatorOptions.resolveTextStyle(textMode: true),
            child: Padding(
              padding: resolvedPadding,
              child: Center(child: denominator),
            ),
          ),
        ],
      ),
    );
  }
}
