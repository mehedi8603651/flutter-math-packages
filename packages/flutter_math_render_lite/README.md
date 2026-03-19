# flutter_math_render_lite

Small-size renderer core for the `flutter_math` package family.

Current status:

- depends on `flutter_math_model`
- real Flutter package scaffold
- no bundled KaTeX fonts
- minimal future-safe low-level renderer surface:
  - `LiteMathOptions`
  - `LiteBuildResult`
  - `LiteSymbol`
  - `LiteLine`
  - `LiteFraction`
  - `LiteSqrt`
  - `LiteSymbolNode`
  - `LiteSyntaxTreeView`
  - AST-backed builder support for:
    - `EquationRowNode`
    - `LiteSymbolNode`
    - `FracNodeModel`
    - `SqrtNodeModel`
    - `SpaceNodeModel`
    - `FunctionNodeModel`
    - `MultiscriptsNodeModel`
    - `OverNodeModel`
    - `UnderNodeModel`
    - `LeftRightNodeModel`
    - `StretchyOpNodeModel`
    - `StyleNode`
    - `AccentNodeModel`
    - `AccentUnderNodeModel`
    - `NaryOperatorNodeModel`
    - `RaiseBoxNodeModel`
    - `PhantomNodeModel`
    - `MatrixNodeModel`
    - `EquationArrayNodeModel`

Design notes:

- this package is intentionally renderer-only
- it uses system text rendering instead of bundled KaTeX fonts
- it is a low-level primitive layer for the future default `flutter_math`
  package, not the final high-level widget facade

Still intentionally outside this package:

- TeX parsing and encoding
- AST-driven widget building
- full delimiter/stretchy operator coverage
- selection/controller/widget facade APIs
