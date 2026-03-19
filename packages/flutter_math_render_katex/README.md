# flutter_math_render_katex

KaTeX-style renderer backend, fonts, metrics, and layout helpers for Flutter
math packages.

## Who Should Use This Package?

Most app developers should not use this package directly.

Use it if you are:

- building a higher-level package such as `flutter_math_katex`
- working on renderer internals
- reusing KaTeX fonts, metrics, or low-level symbol/layout helpers

If you want a public widget package, use `flutter_math_katex`.

## What This Package Provides

- bundled KaTeX font assets
- KaTeX font metrics
- symbol/SVG helper layer
- shared layout widgets such as:
  - `Line`
  - `EditableLine`
  - `VList`
  - `Multiscripts`
  - `EqnArray`
  - `EquationRowView`

## What It Does Not Provide

- a full public widget API
- TeX parsing by itself
- the final selection/controller facade

## Intended Role

This package is the low-level high-fidelity rendering backend under
`flutter_math_katex`.
