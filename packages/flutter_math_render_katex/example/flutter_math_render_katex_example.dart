import 'package:flutter_math_render_katex/flutter_math_render_katex.dart';

void main() {
  final metrics = getCharacterMetrics(
    character: 'A',
    fontName: 'AMS-Regular',
    mode: Mode.math,
  );

  print(KaTeXFontFamilies.packaged(KaTeXFontFamilies.main));
  print(metrics?.width);
  print(
    makeBaseSymbol(
      symbol: '+',
      atomType: AtomType.bin,
      mode: Mode.math,
      options: MathOptions.textOptions,
    ).widget.runtimeType,
  );
}
