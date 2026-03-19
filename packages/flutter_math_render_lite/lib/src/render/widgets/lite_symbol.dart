import 'package:flutter/widgets.dart';
import 'package:flutter_math_model/ast.dart';

import '../../lite_math_options.dart';
import '../lite_build_result.dart';

class LiteSymbol extends StatelessWidget {
  const LiteSymbol({
    super.key,
    required this.symbol,
    required this.options,
    this.mode = Mode.math,
    this.overrideFont,
    this.textAlign,
  });

  final String symbol;
  final LiteMathOptions options;
  final Mode mode;
  final FontOptions? overrideFont;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      symbol,
      locale: options.textLocale,
      softWrap: false,
      textAlign: textAlign,
      style: options.resolveTextStyle(
        overrideFont: overrideFont,
        textMode: mode == Mode.text,
      ),
    );
  }
}

LiteBuildResult buildLiteSymbol({
  required String symbol,
  required LiteMathOptions options,
  Mode mode = Mode.math,
  FontOptions? overrideFont,
  TextAlign? textAlign,
}) {
  return LiteBuildResult(
    widget: LiteSymbol(
      symbol: symbol,
      options: options,
      mode: mode,
      overrideFont: overrideFont,
      textAlign: textAlign,
    ),
    options: options,
  );
}
