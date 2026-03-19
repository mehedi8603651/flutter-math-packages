# flutter_math_render_katex

KaTeX renderer assets and metric lookup package for the `flutter_math` family.

Current status:

- real Flutter package scaffold
- depends on `flutter_math_model`
- owns the bundled KaTeX font assets
- owns the KaTeX font metric tables
- owns the KaTeX symbol/SVG helper layer
- owns the shared layout widgets used by the current renderer:
  - `CustomLayout`
  - `Line`
  - `EditableLine`
  - `VList`
  - `Multiscripts`
  - `EqnArray`
  - `EquationRowView`
  - `LayoutBuilderPreserveBaseline`
  - `MinDimension`
  - `RemoveBaseline`
- owns the shared render utility layer:
  - `infiniteConstraint`
  - `nullDelimiterSpace`
  - render-box layout/offset helpers
  - type helper used by `CustomLayout`
- exposes packaged font-family helpers for future renderer code

Current API surface:

- `FontMetrics`
- `CharacterMetrics`
- `getCharacterMetrics(...)`
- `getGlobalMetrics(...)`
- `KaTeXFontFamilies`
- `katexFontAssets`
- `MathOptions`
- `makeBaseSymbol(...)`
- `CustomLayout`, `Line`, `VList`, `Multiscripts`, `EqnArray`
- `staticSvg(...)`
- `strechySvgSpan(...)`
- `getHeightForDelim(...)`

What is intentionally not moved yet:

- the AST-specific equation-row bridge in `syntax_tree_equation_row.dart`
- selection/controller bridge code
- root AST/widget integration

Why:

- the current selection/controller bridge still depends on root-local AST and
  widget contracts
- the package now owns the complete low-level/generic render toolkit, but the
  final widget facade still depends on root-local AST and controller types

Next extraction target:

- decide whether the remaining AST-specific syntax-tree bridge should move into
  a higher-level `flutter_math_katex` facade package or remain in the root
  package during the migration period
