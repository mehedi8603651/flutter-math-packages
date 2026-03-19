import 'package:flutter_math_tex/flutter_math_tex.dart';
import 'package:test/test.dart';

void main() {
  group('lexer', () {
    test('normalizes control-word whitespace', () {
      final lexer = Lexer(r'\alpha   + x', const TexParserSettings());

      expect(lexer.lex().text, r'\alpha');
      expect(lexer.lex().text, '+');
      expect(lexer.lex().text, ' ');
      expect(lexer.lex().text, 'x');
    });

    test('keeps unicode symbols as single tokens', () {
      final lexer = Lexer('∑x', const TexParserSettings());

      expect(lexer.lex().text, '∑');
      expect(lexer.lex().text, 'x');
    });
  });

  group('namespace', () {
    test('restores scoped values after a group', () {
      final namespace = Namespace<String>(
        const <String, String>{'builtin': 'builtin'},
        <String, String>{'x': 'outer'},
      );

      namespace.beginGroup();
      namespace.set('x', 'inner');
      namespace.set('y', 'temp');
      namespace.endGroup();

      expect(namespace.get('x'), 'outer');
      expect(namespace.get('y'), isNull);
      expect(namespace.get('builtin'), 'builtin');
    });
  });

  group('macro expander', () {
    test('expands simple string macros with arguments', () {
      final expander = MacroExpander(
        r'\foo{z}',
        TexParserSettings(
          macros: <String, MacroDefinition>{
            r'\foo': MacroDefinition.fromString(r'{#1#1}'),
          },
        ),
        Mode.math,
      );

      expect(expander.expandNextToken().text, '{');
      expect(expander.expandNextToken().text, 'z');
      expect(expander.expandNextToken().text, 'z');
      expect(expander.expandNextToken().text, '}');
    });

    test('uses definition lookup for function awareness', () {
      final expander = MacroExpander(
        '',
        const TexParserSettings(),
        Mode.math,
        lookup: const _FakeLookup(),
      );

      expect(expander.isDefined(r'\sqrt'), isTrue);
      expect(expander.isDefined(r'\alpha'), isTrue);
      expect(expander.isDefined(r'\missing'), isFalse);
    });
  });

  group('parser and encoder', () {
    test('parses and encodes TeX without the root package', () {
      final ast = TexParser(
        r'\frac{\RR + 1}{x}',
        TexParserSettings(
          macros: <String, MacroDefinition>{
            r'\RR': MacroDefinition.fromString(r'\mathbb{R}'),
          },
        ),
      ).parse();

      expect(
        ast.encodeTeX(conf: TexEncodeConf.mathParamConf),
        r'\frac{\mathbb{R}+1}{x}',
      );
    });
  });
}

class _FakeLookup implements TexDefinitionLookup {
  const _FakeLookup();

  @override
  bool hasFunction(String name) => name == r'\sqrt';

  @override
  bool hasSymbol(Mode mode, String name) =>
      mode == Mode.math && name == r'\alpha';
}
