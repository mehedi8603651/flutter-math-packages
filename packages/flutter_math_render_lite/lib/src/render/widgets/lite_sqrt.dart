import 'package:flutter/widgets.dart';
import 'package:flutter_math_model/ast.dart';

import '../../lite_math_options.dart';

class LiteSqrt extends StatelessWidget {
  const LiteSqrt({
    super.key,
    required this.radicand,
    required this.options,
    this.index,
    this.borderWidth,
    this.padding,
  });

  final Widget radicand;
  final LiteMathOptions options;
  final Widget? index;
  final double? borderWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final radicandOptions = options.forChildStyle(options.style.cramp());
    final indexOptions = options.forChildStyle(MathStyle.scriptscript);
    final resolvedPadding = padding ??
        EdgeInsets.only(
          left: options.fontSize * 0.12,
          right: options.fontSize * 0.08,
          top: options.fontSize * 0.1,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (index != null)
          Transform.translate(
            offset: Offset(options.fontSize * 0.04, options.fontSize * 0.28),
            child: DefaultTextStyle.merge(
              style: indexOptions.resolveTextStyle(textMode: true),
              child: index!,
            ),
          ),
        Text(
          '√',
          style: options.resolveTextStyle().copyWith(
                fontSize: options.fontSize * 1.15,
              ),
        ),
        DefaultTextStyle.merge(
          style: radicandOptions.resolveTextStyle(textMode: true),
          child: Container(
            padding: resolvedPadding,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: options.color,
                  width: borderWidth ?? options.lineThickness,
                ),
              ),
            ),
            child: radicand,
          ),
        ),
      ],
    );
  }
}
