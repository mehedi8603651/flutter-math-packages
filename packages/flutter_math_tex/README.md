# flutter_math_tex

TeX front-end core for the `flutter_math` package family.

Current status:

- real standalone package
- depends only on `flutter_math_model`
- owns the TeX parsing and encoding stack:
  - `Lexer`
  - `Token`
  - `SourceLocation`
  - `ParseException`
  - `Namespace`
  - `TexParserSettings`
  - `MacroDefinition` / `MacroExpansion`
  - `MacroExpander`
  - `TexParser`
  - TeX function registry metadata
  - built-in macro tables
  - TeX symbol, color, and font tables
  - TeX encoder

Design notes:

- parser-facing AST/value types come from `flutter_math_model`
- shared pure Dart `StyleNode` now comes from `flutter_math_model`
- package-local pure Dart `SymbolNode` and `EnclosureNode` complete the TeX-side
  model surface without introducing Flutter dependencies
- the package exposes both the high-level `tex.dart` API and low-level parser
  primitives

Still intentionally outside this package:

- Flutter widget building
- render/layout code
- KaTeX font assets and font metrics
- editor-specific parser extensions such as cursor nodes

Example:

```dart
final ast = TexParser(
  r'\frac{\RR + 1}{x}',
  TexParserSettings(
    macros: <String, MacroDefinition>{
      r'\RR': MacroDefinition.fromString(r'\mathbb{R}'),
    },
  ),
).parse();

print(ast.encodeTeX(conf: TexEncodeConf.mathParamConf)); // \frac{\mathbb{R}+1}{x}
```
