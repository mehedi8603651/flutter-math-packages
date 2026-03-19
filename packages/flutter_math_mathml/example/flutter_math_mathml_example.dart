import 'package:flutter_math_mathml/flutter_math_mathml.dart';
import 'package:flutter_math_tex/flutter_math_tex.dart';

void main() {
  final sourceAst = TexParser(
    r'\frac{\mathbb{R}+1}{x_2}',
    const TexParserSettings(),
  ).parse();
  final mathml = sourceAst.encodeMathML();
  final parsedAst = MathMLParser(mathml).parse();

  print(parsedAst.encodeMathML());
}
