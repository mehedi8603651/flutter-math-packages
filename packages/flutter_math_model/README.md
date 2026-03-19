# flutter_math_model

Shared AST and semantic model layer for Flutter math packages.

## Who Should Use This Package?

Most app developers should not depend on this package directly.

Use it if you are:

- building parsers or encoders
- building custom renderers
- working on advanced editor or conversion tooling
- contributing to the package split itself

## What This Package Provides

- shared AST node types
- tree traversal helpers
- semantic value types such as:
  - `Measurement`
  - `MathSize`
  - `MathStyle`
  - `MathColor`
  - `OptionsDiff`
- shared syntax tree types:
  - `GreenNode`
  - `SyntaxNode`
  - `SyntaxTree`
  - `EquationRowNode`
- pure structural node models used across TeX, UnicodeMath, MathML, and
  renderers

## What It Does Not Provide

- TeX parsing
- UnicodeMath parsing
- MathML parsing
- Flutter widget rendering
- KaTeX font assets or metrics

## Example

```dart
import 'package:flutter_math_model/flutter_math_model.dart';

void main() {
  final tree = SyntaxTree(
    greenRoot: EquationRowNode(children: const []),
  );

  print(tree.greenRoot.children.length);
}
```
