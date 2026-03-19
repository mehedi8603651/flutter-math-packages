# flutter_math_katex

High-fidelity public facade for the current KaTeX-backed `flutter_math`
renderer.

## Current role

This package is the public high-fidelity package for apps that want the current
KaTeX-backed rendering behavior and bundled KaTeX-style assets.

It now depends directly on:

- `flutter_math_model`
- `flutter_math_tex`
- `flutter_math_render_katex`

The package owns the high-fidelity widget, selection, and AST-rendering facade
it needs on top of those shared packages.

## Use

```dart
import 'package:flutter_math_katex/flutter_math_katex.dart';

Math.tex(
  r'\int_0^\infty e^{-x^2}\,\mathrm{d}x',
  mathStyle: MathStyle.display,
)
```

Advanced public surfaces are also re-exported:

- `package:flutter_math_katex/ast.dart`
- `package:flutter_math_katex/tex.dart`

## Migration note

This package is now off the root `flutter_math_fork` dependency path.

The remaining migration work is reducing duplication between this high-fidelity
facade and the root compatibility package while the root package shrinks toward
the smaller default `flutter_math` surface.
