# flutter-math-packages

Modular Flutter math packages for TeX parsing, KaTeX-style rendering,
UnicodeMath, and MathML.

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
- `flutter_math_render_lite`: small-size renderer without bundled KaTeX fonts
- `flutter_math_render_katex`: high-fidelity KaTeX font, metric, symbol, SVG,
  and layout backend
- `flutter_math_katex`: public high-fidelity widget package
- `flutter_math_unicodemath`: UnicodeMath encoder and parser
- `flutter_math_mathml`: MathML encoder and parser

## App

- `apps/math_test`: local Flutter app for package-by-package manual testing

## Getting Started

1. Install Melos:

```bash
dart pub global activate melos
```

2. Bootstrap the workspace:

```bash
melos bootstrap
```

3. Run the demo app:

```bash
cd apps/math_test
flutter run
```

## Notes

- Package directories keep their own `example/` folders where useful.
- This repo is independent from the original `flutter_math_fork` source.
- Path dependencies are kept for local monorepo development.
