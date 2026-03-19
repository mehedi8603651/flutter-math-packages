# flutter_math_model

Shared model layer for the `flutter_math` package family.

This package is intended to hold the renderer-agnostic parts of the future
package split:

- AST node types
- tree traversal and shared semantic helpers
- edit/cursor model
- structures shared by TeX, UnicodeMath, MathML, and renderer packages

Current status:

- package scaffold created
- stable package metadata in place
- extracted shared value/model API landed:
  - `MathRange`
  - `Measurement`
  - `Unit`
  - `MathSize`
  - `MathStyle`
  - `MathColor`
  - `MathFontWeight`
  - `MathFontStyle`
  - `FontOptions`
  - `PartialFontOptions`
  - `OptionsDiff`
  - `Mode`
  - `AtomType`
  - `GreenNode` / `SyntaxNode` / `SyntaxTree`
  - `EquationRowNode`
  - wrapping and clipping helpers
  - pure structural node models:
    - `AccentNodeModel`
    - `AccentUnderNodeModel`
    - `EquationArrayNodeModel`
    - `FracNodeModel`
    - `FunctionNodeModel`
    - `LeftRightNodeModel`
    - `MatrixNodeModel`
    - `MultiscriptsNodeModel`
    - `NaryOperatorNodeModel`
    - `OverNodeModel`
    - `UnderNodeModel`
    - `PhantomNodeModel`
    - `RaiseBoxNodeModel`
    - `SpaceNodeModel`
    - `SqrtNodeModel`
    - `StretchyOpNodeModel`
  - generic parser-facing wrappers:
    - `SymbolNodeModel`
    - `StyleNodeModel`

Design constraints:

- no bundled KaTeX font assets
- no Flutter widget rendering code
- no TeX-only dependency direction
- no Flutter `Color`, `TextStyle`, or widget-layer font objects in the core API

Deliberate non-goals for now:

- render-only nodes that directly depend on Flutter widget/layout primitives
- bundled symbol tables or KaTeX font-metric data

## Planned dependents

- `flutter_math_tex`
- `flutter_math_unicodemath`
- `flutter_math_mathml`
- `flutter_math_render_lite`
- `flutter_math_render_katex`

## Usage

This package is now the shared renderer-agnostic AST/value surface for the next
package split. Downstream parser and renderer packages can build on this
without pulling in Flutter widget code or KaTeX assets.

```dart
import 'package:flutter_math_model/flutter_math_model.dart';

void main() {
  final tree = SyntaxTree(
    greenRoot: EquationRowNode(children: const []),
  );
  print(tree.greenRoot.children.length);
}
```
