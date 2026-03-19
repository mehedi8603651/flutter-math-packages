import 'package:flutter_math_render_katex/flutter_math_render_katex.dart';

void main() {
  final metrics = getCharacterMetrics(
    character: 'A',
    fontName: 'AMS-Regular',
    mode: Mode.math,
  );
  final plus = makeBaseSymbol(
    symbol: '+',
    atomType: AtomType.bin,
    mode: Mode.math,
    options: MathOptions.textOptions,
  );
  final sum = makeBaseSymbol(
    symbol: '∑',
    atomType: AtomType.op,
    mode: Mode.math,
    options: MathOptions.displayOptions,
  );

  print('Packaged main font family: '
      '${KaTeXFontFamilies.packaged(KaTeXFontFamilies.main)}');
  print('Metric width for "A" in AMS-Regular: ${metrics?.width}');
  print('Rendered plus widget: ${plus.widget.runtimeType}');
  print('Rendered sum widget: ${sum.widget.runtimeType}');
}
