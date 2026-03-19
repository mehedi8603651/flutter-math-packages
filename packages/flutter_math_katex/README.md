# flutter_math_katex

High-fidelity KaTeX-style Flutter math widgets.

## Use This Package When

- you want a public Flutter widget package
- you want TeX rendering, not just parsing
- you want behavior close to the current `flutter_math_fork` experience
- you need selectable math

If you already used `flutter_math_fork`, this is the easiest new package to
start with.

## Install

```yaml
dependencies:
  flutter_math_katex: ^0.1.0
```

## Quick Start

```dart
import 'package:flutter_math_katex/flutter_math_katex.dart';

Math.tex(
  r'\int_0^\infty e^{-x^2}\,\mathrm{d}x = \frac{\sqrt{\pi}}{2}',
  mathStyle: MathStyle.display,
);
```

## More Examples

Inline math:

```dart
Math.tex(
  r'x^2 + y^2 = z^2',
  mathStyle: MathStyle.text,
);
```

Display math:

```dart
Math.tex(
  r'\sum_{n=1}^{\infty}\frac{1}{n^2} = \frac{\pi^2}{6}',
  mathStyle: MathStyle.display,
);
```

Selectable math:

```dart
SelectableMath.tex(
  r'\begin{bmatrix}1 & 2 \\ 3 & 4\end{bmatrix}\vec{x}=\vec{b}',
  mathStyle: MathStyle.display,
);
```

## What This Package Includes

- `Math.tex(...)`
- `SelectableMath.tex(...)`
- TeX parsing through `flutter_math_tex`
- high-fidelity KaTeX-style rendering through `flutter_math_render_katex`

## What This Package Does Not Try To Be

- the smallest possible renderer
- a TeX-only parser package
- a UnicodeMath or MathML conversion package

For those use:

- `flutter_math_tex`
- `flutter_math_unicodemath`
- `flutter_math_mathml`

## Advanced Exports

- `package:flutter_math_katex/ast.dart`
- `package:flutter_math_katex/tex.dart`
