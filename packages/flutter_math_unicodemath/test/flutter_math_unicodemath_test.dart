import 'package:flutter_math_tex/flutter_math_tex.dart' as tex;
import 'package:flutter_math_unicodemath/flutter_math_unicodemath.dart';
import 'package:test/test.dart';

void main() {
  const doubleStruckR = '\u211D';
  const sqrt = '\u221A';
  const boldY = '\u{1D432}';

  test('encodes manual AST with Unicode mathematical alphabets', () {
    final ast = EquationRowNode(
      children: [
        StyleNode(
          children: [SymbolNode(symbol: 'R')],
          optionsDiff: const OptionsDiff(
            mathFontOptions: FontOptions(fontFamily: 'AMS'),
          ),
        ),
        SymbolNode(symbol: '+'),
        MultiscriptsNodeModel(
          base: stringToNode('x', Mode.math),
          sub: stringToNode('1', Mode.math),
        ),
      ],
    );

    expect(ast.encodeUnicodeMath(), '$doubleStruckR+x_1');
  });

  test('encodes fractions and roots from a TeX AST', () {
    final ast = tex.TexParser(
      r'\frac{\mathbb{R}+\sqrt{x_1}}{\mathbf{y}}',
      const tex.TexParserSettings(),
    ).parse();

    expect(ast.encodeUnicodeMath(), '($doubleStruckR+$sqrt(x_1))/$boldY');
  });

  test('encodes matrix nodes into readable command syntax', () {
    final matrix = MatrixNodeModel(
      body: [
        [stringToNode('a', Mode.math), stringToNode('b', Mode.math)],
        [stringToNode('c', Mode.math), stringToNode('d', Mode.math)],
      ],
    );

    expect(matrix.encodeUnicodeMath(), r'\matrix(a&b@c&d)');
  });

  test('parses direct UnicodeMath with styled symbols and scripts', () {
    final ast = UnicodeMathParser('$doubleStruckR+x_1').parse();

    expect(ast.encodeUnicodeMath(), '$doubleStruckR+x_1');
  });

  test('parses encoder output back into a stable UnicodeMath tree', () {
    final ast = UnicodeMathParser('($doubleStruckR+$sqrt(x_1))/$boldY').parse();

    expect(ast.encodeUnicodeMath(), '($doubleStruckR+$sqrt(x_1))/$boldY');
  });

  test('parses readable fallback commands', () {
    final ast = UnicodeMathParser(
      r'\color{ffff0000}(\matrix(a&b@c&d))',
    ).parse();

    expect(ast.encodeUnicodeMath(), r'\color{ffff0000}(\matrix(a&b@c&d))');
  });
}
