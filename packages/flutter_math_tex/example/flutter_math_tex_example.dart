import 'package:flutter_math_tex/flutter_math_tex.dart';

void main() {
  _printSection('1. Basic parse and encode');
  const basicSource = r'\frac{\mathbb{R}+1}{x_2}+\sqrt{y_1}';
  final basicAst = TexParser(basicSource, const TexParserSettings()).parse();
  print('TeX source: $basicSource');
  print(
    'Normalized TeX: '
    '${basicAst.encodeTeX(conf: TexEncodeConf.mathParamConf)}',
  );

  _printSection('2. Macro expansion');
  const macroSource = r'\frac{\RR+1}{x}+\sum_{n=1}^{3}n';
  final macroAst = TexParser(
    macroSource,
    TexParserSettings(
      macros: <String, MacroDefinition>{
        r'\RR': MacroDefinition.fromString(r'\mathbb{R}'),
      },
    ),
  ).parse();
  print('TeX source: $macroSource');
  print(
    'Normalized after macro expansion: '
    '${macroAst.encodeTeX(conf: TexEncodeConf.mathParamConf)}',
  );

  _printSection('3. Error handling');
  try {
    TexParser(r'\frac{1}{', const TexParserSettings()).parse();
  } on ParseException catch (error) {
    print(error.messageWithType);
  }
}

void _printSection(String title) {
  print('');
  print(title);
  print('-' * title.length);
}
