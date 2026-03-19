import 'package:flutter_math_tex/flutter_math_tex.dart';

void main() {
  final ast = TexParser(
    r'\frac{\RR + 1}{x}',
    TexParserSettings(
      macros: <String, MacroDefinition>{
        r'\RR': MacroDefinition.fromString(r'\mathbb{R}'),
      },
    ),
  ).parse();

  print(ast.encodeTeX(conf: TexEncodeConf.mathParamConf));
}
