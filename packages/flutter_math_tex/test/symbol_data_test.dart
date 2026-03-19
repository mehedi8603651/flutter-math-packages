import 'package:flutter_math_tex/flutter_math_tex.dart';
import 'package:test/test.dart';

void main() {
  test('exports parser-facing font, color, and symbol tables', () {
    expect(colorByName['blue'], const MathColor(0xff0000ff));
    expect(
      texMathFontOptions[r'\mathbf'],
      const FontOptions(
        fontFamily: 'Main',
        fontWeight: MathFontWeight.bold,
      ),
    );
    expect(
      texTextFontOptions[r'\textit'],
      const PartialFontOptions(fontShape: MathFontStyle.italic),
    );
    expect(
      texSymbolCommandConfigs[Mode.math]![r'\prime']?.symbol,
      '\u2032',
    );
  });
}
