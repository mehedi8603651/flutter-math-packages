import 'package:flutter_math_tex/flutter_math_tex.dart';
import 'package:flutter_math_unicodemath/flutter_math_unicodemath.dart';

void main() {
  _printSection('1. Parse UnicodeMath');
  const unicodeSource = '(\u211D+\u221A(x_1))/\u{1D432}';
  final unicodeAst = UnicodeMathParser(unicodeSource).parse();
  print('UnicodeMath source: $unicodeSource');
  print('Normalized UnicodeMath: ${unicodeAst.encodeUnicodeMath()}');
  print('Parsed AST type: ${unicodeAst.runtimeType}');
  print('Top-level child count: ${unicodeAst.children.length}');

  _printSection('2. Convert TeX to UnicodeMath');
  const texSource = r'\frac{\mathbb{R}+\sqrt{x_1}}{\mathbf{y}}';
  final texAst = TexParser(texSource, const TexParserSettings()).parse();
  final encodedUnicode = texAst.encodeUnicodeMath();
  print('TeX source: $texSource');
  print('UnicodeMath output: $encodedUnicode');
  print(
    'Round-trip UnicodeMath: '
    '${UnicodeMathParser(encodedUnicode).parse().encodeUnicodeMath()}',
  );
}

void _printSection(String title) {
  print('');
  print(title);
  print('-' * title.length);
}
