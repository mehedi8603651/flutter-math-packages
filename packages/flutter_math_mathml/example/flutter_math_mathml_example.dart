import 'package:flutter_math_mathml/flutter_math_mathml.dart';
import 'package:flutter_math_tex/flutter_math_tex.dart';

void main() {
  _printSection('1. Encode TeX AST as MathML');
  const texSource = r'\frac{\mathbb{R}+1}{x_2}+\sqrt{y_1}';
  final texAst = TexParser(texSource, const TexParserSettings()).parse();
  final encodedMathML = texAst.encodeMathML();
  print('TeX source: $texSource');
  print('MathML output: $encodedMathML');

  _printSection('2. Parse MathML back into the shared AST');
  final parsedMathMLAst = MathMLParser(encodedMathML).parse();
  print('Round-trip MathML: ${parsedMathMLAst.encodeMathML()}');
  print('Parsed AST type: ${parsedMathMLAst.runtimeType}');
  print('Top-level child count: ${parsedMathMLAst.children.length}');
}

void _printSection(String title) {
  print('');
  print(title);
  print('-' * title.length);
}
