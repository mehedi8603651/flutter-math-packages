import 'dart:convert';

import 'package:flutter_math_katex/ast.dart' as katex_ast;
import 'package:flutter_math_tex/flutter_math_tex.dart' as tex_ast;

import '../../interop/shared_ast_adapter.dart';

class TexEncoder extends Converter<katex_ast.GreenNode, String> {
  @override
  String convert(katex_ast.GreenNode input) =>
      tex_ast.TexEncoder().convert(toTexGreenNode(input));
}

extension TexEncoderExt on katex_ast.GreenNode {
  String encodeTeX({
    tex_ast.TexEncodeConf conf = const tex_ast.TexEncodeConf(),
  }) =>
      tex_ast.encodeTex(toTexGreenNode(this)).stringify(conf);
}

extension ListTexEncoderExt on List<katex_ast.GreenNode> {
  String encodeTex() => tex_ast
      .encodeTex(
        tex_ast.EquationRowNode(
          children: toTexGreenNodes(this),
        ),
      )
      .stringify(const tex_ast.TexEncodeConf(removeRowBracket: true));
}
