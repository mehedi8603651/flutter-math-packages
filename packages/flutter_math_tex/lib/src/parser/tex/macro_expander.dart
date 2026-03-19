import 'package:flutter_math_model/flutter_math_model.dart' show Mode;

import 'definition_lookup.dart';
import 'lexer.dart';
import 'macro_types.dart';
import 'namespace.dart';
import 'parse_error.dart';
import 'settings.dart';
import 'token.dart';

/// Commands that act like known parser tokens even when not macro-defined.
const Set<String> implicitCommands = <String>{
  r'\relax',
  '^',
  '_',
  r'\limits',
  r'\nolimits',
};

/// Expands macros over a TeX token stream.
class MacroExpander implements MacroContext {
  MacroExpander(
    this.input,
    this.settings,
    this.mode, {
    Map<String, MacroDefinition> builtins = const <String, MacroDefinition>{},
    TexDefinitionLookup lookup = const EmptyTexDefinitionLookup(),
  }) : macros = Namespace<MacroDefinition>(builtins, settings.macros),
       lexer = Lexer(input, settings),
       _lookup = lookup;

  String input;
  TexParserSettings settings;
  @override
  Mode mode;
  int expansionCount = 0;
  final List<Token> stack = <Token>[];
  final Lexer lexer;
  @override
  final Namespace<MacroDefinition> macros;
  final TexDefinitionLookup _lookup;

  @override
  Token expandAfterFuture() {
    expandOnce();
    return future();
  }

  @override
  Token expandNextToken() {
    while (true) {
      final expanded = expandOnce();
      if (expanded != null) {
        if (expanded.text == r'\relax') {
          stack.removeLast();
        } else {
          return stack.removeLast();
        }
      }
    }
  }

  void beginGroup() {
    macros.beginGroup();
  }

  void endGroup() {
    macros.endGroup();
  }

  @override
  Token? expandOnce([bool expandableOnly = false]) {
    final topToken = popToken();
    final name = topToken.text;
    final expansion = !topToken.noexpand ? _getExpansion(name) : null;
    if (expansion == null || (expandableOnly && expansion.unexpandable)) {
      if (expandableOnly &&
          expansion == null &&
          name.startsWith(r'\') &&
          isDefined(name)) {
        throw ParseException('Undefined control sequence: $name');
      }
      pushToken(topToken);
      return topToken;
    }

    expansionCount += 1;
    if (expansionCount > settings.maxExpand) {
      throw ParseException(
        'Too many expansions: infinite loop or need to increase maxExpand setting',
      );
    }

    var tokens = expansion.tokens;
    if (expansion.numArgs != 0) {
      final args = consumeArgs(expansion.numArgs);
      tokens = tokens.toList(growable: true);
      for (var index = tokens.length - 1; index >= 0; --index) {
        var token = tokens[index];
        if (token.text == '#') {
          if (index == 0) {
            throw ParseException(
              'Incomplete placeholder at end of macro body',
              token,
            );
          }
          --index;
          token = tokens[index];
          if (token.text == '#') {
            tokens.removeAt(index + 1);
          } else {
            try {
              tokens.replaceRange(
                index,
                index + 2,
                args[int.parse(token.text) - 1],
              );
            } on FormatException {
              throw ParseException('Not a valid argument number', token);
            }
          }
        }
      }
    }

    pushTokens(tokens);
    return null;
  }

  void pushToken(Token token) {
    stack.add(token);
  }

  void pushTokens(List<Token> tokens) {
    stack.addAll(tokens);
  }

  @override
  Token popToken() {
    future();
    return stack.removeLast();
  }

  @override
  Token future() {
    if (stack.isEmpty) {
      stack.add(lexer.lex());
    }
    return stack.last;
  }

  MacroExpansion? _getExpansion(String name) {
    final definition = macros.get(name);
    if (definition == null) {
      return null;
    }
    return definition.expand(this);
  }

  @override
  List<List<Token>> consumeArgs(int numArgs) {
    return List<List<Token>>.generate(numArgs, (index) {
      consumeSpaces();
      final startOfArg = popToken();
      if (startOfArg.text == '{') {
        final arg = <Token>[];
        var depth = 1;
        while (depth != 0) {
          final token = popToken();
          arg.add(token);
          switch (token.text) {
            case '{':
              ++depth;
            case '}':
              --depth;
            case 'EOF':
              throw ParseException(
                'End of input in macro argument',
                startOfArg,
              );
          }
        }
        arg.removeLast();
        return arg.reversed.toList(growable: false);
      }
      if (startOfArg.text == 'EOF') {
        throw ParseException('End of input expecting macro argument');
      }
      return <Token>[startOfArg];
    }, growable: false);
  }

  @override
  void consumeSpaces() {
    while (true) {
      final token = future();
      if (token.text == ' ') {
        stack.removeLast();
      } else {
        break;
      }
    }
  }

  @override
  bool isDefined(String name) =>
      macros.has(name) ||
      _lookup.hasFunction(name) ||
      _lookup.hasSymbol(Mode.math, name) ||
      _lookup.hasSymbol(Mode.text, name) ||
      implicitCommands.contains(name);

  @override
  bool isExpandable(String name) {
    final macro = macros.get(name);
    return macro?.expandable ?? _lookup.hasFunction(name);
  }

  @override
  Lexer getNewLexer(String input) => Lexer(input, settings);

  String? expandMacroAsText(String name) {
    final tokens = expandMacro(name);
    if (tokens == null) {
      return null;
    }
    return tokens.map((token) => token.text).join();
  }

  List<Token>? expandMacro(String name) {
    if (macros.get(name) == null) {
      return null;
    }
    final output = <Token>[];
    final oldStackLength = stack.length;
    pushToken(Token(name));
    while (stack.length > oldStackLength) {
      final expanded = expandOnce();
      if (expanded != null) {
        output.add(stack.removeLast());
      }
    }
    return output;
  }
}
