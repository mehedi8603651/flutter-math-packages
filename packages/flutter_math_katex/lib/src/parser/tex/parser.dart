import 'package:flutter_math_katex/ast.dart' as katex_ast;
import 'package:flutter_math_tex/flutter_math_tex.dart' as tex_ast;

import '../../interop/shared_ast_adapter.dart';
import 'parse_error.dart';

class TexParser {
  TexParser(this.expression, [this.settings = const tex_ast.TexParserSettings()]);

  final String expression;
  final tex_ast.TexParserSettings settings;

  katex_ast.EquationRowNode parse() {
    try {
      return toKatexGreenNode(
        tex_ast.TexParser(expression, settings).parse(),
      ).wrapWithEquationRow();
    } on tex_ast.ParseException catch (error) {
      throw ParseException(
        error.message,
        position: error.position,
        cause: error,
      );
    }
  }
}
