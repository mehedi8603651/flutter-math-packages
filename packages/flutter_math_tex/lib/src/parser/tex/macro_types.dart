import 'package:flutter_math_model/flutter_math_model.dart' show Mode;

import 'lexer.dart';
import 'namespace.dart';
import 'token.dart';

/// Context contract used by macro definitions.
abstract interface class MacroContext {
  Mode get mode;

  Namespace<MacroDefinition> get macros;

  Token future();

  Token popToken();

  void consumeSpaces();

  Token? expandOnce([bool expandableOnly = false]);

  Token expandAfterFuture();

  Token expandNextToken();

  List<List<Token>> consumeArgs(int numArgs);

  bool isDefined(String name);

  bool isExpandable(String name);

  Lexer getNewLexer(String input);
}

/// Result of expanding a macro.
class MacroExpansion {
  const MacroExpansion({
    required this.tokens,
    required this.numArgs,
    this.unexpandable = false,
  });

  final List<Token> tokens;
  final int numArgs;
  final bool unexpandable;

  static final RegExp _strippedRegex = RegExp(r'##', multiLine: true);

  static MacroExpansion fromString(String expansion, MacroContext context) {
    var numArgs = 0;
    if (expansion.contains('#')) {
      final stripped = expansion.replaceAll(_strippedRegex, '');
      while (stripped.contains('#${numArgs + 1}')) {
        numArgs += 1;
      }
    }
    final bodyLexer = context.getNewLexer(expansion);
    final tokens = <Token>[];
    var tok = bodyLexer.lex();
    while (tok.text != 'EOF') {
      tokens.add(tok);
      tok = bodyLexer.lex();
    }
    return MacroExpansion(
      tokens: tokens.reversed.toList(growable: false),
      numArgs: numArgs,
    );
  }
}

/// TeX macro definition.
class MacroDefinition {
  final MacroExpansion Function(MacroContext context) expand;
  final bool unexpandable;

  const MacroDefinition(this.expand, {this.unexpandable = false});

  bool get expandable => !unexpandable;

  factory MacroDefinition.fromString(String output) =>
      MacroDefinition((context) => MacroExpansion.fromString(output, context));

  factory MacroDefinition.fromCtxString(
    String Function(MacroContext context) expand,
  ) => MacroDefinition(
    (context) => MacroExpansion.fromString(expand(context), context),
  );

  factory MacroDefinition.fromMacroExpansion(MacroExpansion output) =>
      MacroDefinition((_) => output, unexpandable: output.unexpandable);
}
