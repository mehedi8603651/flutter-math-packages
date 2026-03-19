# flutter-math-packages

Modular Flutter math packages for TeX parsing, KaTeX-style rendering,
UnicodeMath, and MathML.

## Which Package Should I Use?

- Use `flutter_math_katex` if you want to render TeX as Flutter widgets with
  the current high-fidelity KaTeX-style output.
- Use `flutter_math_tex` if you only need TeX parsing and encoding, not
  widget rendering.
- Use `flutter_math_unicodemath` if you need UnicodeMath parsing, encoding, or
  TeX-to-UnicodeMath conversion.
- Use `flutter_math_mathml` if you need MathML parsing, encoding, or
  TeX-to-MathML conversion.
- Use `flutter_math_render_lite`, `flutter_math_render_katex`, or
  `flutter_math_model` only if you are building infrastructure on top of the
  lower-level package split.

If you already know `flutter_math_fork`, start with `flutter_math_katex`.

## Workspace Layout

```text
flutter-math-packages/
  packages/
    flutter_math_model/
    flutter_math_tex/
    flutter_math_render_lite/
    flutter_math_render_katex/
    flutter_math_katex/
    flutter_math_unicodemath/
    flutter_math_mathml/
  apps/
    math_test/
  melos.yaml
```

## Packages

- `flutter_math_model`: shared AST, semantic values, and traversal/model APIs
- `flutter_math_tex`: TeX lexer, macro expansion, parser, and encoder
- `flutter_math_render_lite`: lightweight renderer backend without bundled
  KaTeX fonts
- `flutter_math_render_katex`: KaTeX-style renderer backend, fonts, metrics,
  symbols, and layout helpers
- `flutter_math_katex`: public high-fidelity widget package
- `flutter_math_unicodemath`: UnicodeMath parser and encoder
- `flutter_math_mathml`: MathML parser and encoder

## Quick Examples

Render TeX in Flutter:

```dart
import 'package:flutter_math_katex/flutter_math_katex.dart';

Math.tex(
  r'\int_0^\infty e^{-x^2}\,\mathrm{d}x = \frac{\sqrt{\pi}}{2}',
  mathStyle: MathStyle.display,
);
```

Parse and re-encode TeX:

```dart
import 'package:flutter_math_tex/flutter_math_tex.dart';

final ast = TexParser(
  r'\frac{\mathbb{R}+1}{x_2}',
  const TexParserSettings(),
).parse();

print(ast.encodeTeX(conf: TexEncodeConf.mathParamConf));
```

Convert TeX AST to UnicodeMath:

```dart
import 'package:flutter_math_tex/flutter_math_tex.dart';
import 'package:flutter_math_unicodemath/flutter_math_unicodemath.dart';

final ast = TexParser(
  r'\frac{\mathbb{R}+\sqrt{x_1}}{\mathbf{y}}',
  const TexParserSettings(),
).parse();

print(ast.encodeUnicodeMath());
```

Convert TeX AST to MathML:

```dart
import 'package:flutter_math_mathml/flutter_math_mathml.dart';
import 'package:flutter_math_tex/flutter_math_tex.dart';

final ast = TexParser(
  r'\frac{\mathbb{R}+1}{x_2}',
  const TexParserSettings(),
).parse();

print(ast.encodeMathML());
```

## App

- `apps/math_test`: local Flutter app for manual testing and screenshots

Run it with:

```bash
cd apps/math_test
flutter run
```

## Local Development

1. Install Melos:

```bash
dart pub global activate melos
```

2. Bootstrap the workspace:

```bash
melos bootstrap
```

3. Run tests inside the package you are changing.

## Notes

- Package directories keep their own `example/` folders where useful.
- This repo is independent from the original `flutter_math_fork` source.
- Internal package APIs may change faster than the public packages.
