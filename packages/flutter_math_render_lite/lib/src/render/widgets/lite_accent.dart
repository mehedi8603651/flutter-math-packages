import 'package:flutter/widgets.dart';

import '../../lite_math_options.dart';
import 'lite_symbol.dart';
import 'lite_under_over.dart';

class LiteAccent extends StatelessWidget {
  const LiteAccent({
    super.key,
    required this.base,
    required this.label,
    required this.options,
    this.below = false,
    this.stretchy = false,
  });

  final Widget base;
  final String label;
  final LiteMathOptions options;
  final bool below;
  final bool stretchy;

  @override
  Widget build(BuildContext context) {
    final accent = LiteSymbol(
      symbol: label,
      options: options.copyWith(
        fontSize: options.fontSize * (stretchy ? 1.15 : 0.9),
      ),
    );

    return LiteUnderOver(
      above: below ? null : accent,
      below: below ? accent : null,
      base: base,
      gap: options.fontSize * 0.04,
    );
  }
}
