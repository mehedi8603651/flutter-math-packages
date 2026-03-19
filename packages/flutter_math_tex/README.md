# flutter_math_tex

TeX parser and encoder core for Flutter math packages.

## Use This Package When

- you need TeX parsing without Flutter widget rendering
- you need TeX encoding from a shared AST
- you want to build converters, editors, or import/export tools

Do not use this package if your only goal is to render equations in a Flutter
UI. In that case, use `flutter_math_katex`.

## Install

```yaml
dependencies:
  flutter_math_tex: ^0.1.0
```

## Quick Start

```dart
import 'package:flutter_math_tex/flutter_math_tex.dart';

final ast = TexParser(
  r'\frac{\mathbb{R}+1}{x_2}+\sqrt{y_1}',
  const TexParserSettings(),
).parse();

print(ast.encodeTeX(conf: TexEncodeConf.mathParamConf));
```

## Macro Example

```dart
final ast = TexParser(
  r'\frac{\RR + 1}{x}',
  TexParserSettings(
    macros: <String, MacroDefinition>{
      r'\RR': MacroDefinition.fromString(r'\mathbb{R}'),
    },
  ),
).parse();

print(ast.encodeTeX(conf: TexEncodeConf.mathParamConf));
// \frac{\mathbb{R}+1}{x}
```

## Error Handling

```dart
try {
  TexParser(r'\frac{1}{', const TexParserSettings()).parse();
} on ParseException catch (error) {
  print(error.messageWithType);
}
```

## What This Package Owns

- lexer
- token/source location types
- parser settings
- macro expansion
- TeX symbol, color, and font tables
- TeX parser
- TeX encoder

## What It Deliberately Does Not Include

- Flutter widget rendering
- KaTeX font assets
- selection/controller widgets

Those belong in higher- or lower-level packages.
