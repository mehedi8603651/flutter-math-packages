import 'package:flutter_math_unicodemath/flutter_math_unicodemath.dart';

void main() {
  final ast = UnicodeMathParser('(\u211D+\u221A(x_1))/\u{1D432}').parse();

  print(ast.encodeUnicodeMath());
}
