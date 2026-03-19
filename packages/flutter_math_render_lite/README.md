# flutter_math_render_lite

Lightweight renderer backend for Flutter math packages.

## Who Should Use This Package?

Most app developers should not depend on this package directly.

Use it only if you are:

- building a higher-level math widget package
- experimenting with a smaller renderer backend
- working on the internal package split

If you want a ready-to-use public widget package today, use
`flutter_math_katex`.

## What This Package Provides

- system-font-based rendering without bundled KaTeX fonts
- low-level lightweight widgets such as:
  - `LiteLine`
  - `LiteFraction`
  - `LiteSqrt`
  - `LiteSymbol`
- AST-backed rendering for a practical shared subset of math nodes

## What It Does Not Provide

- TeX parsing
- a full public widget facade
- the same visual fidelity as the KaTeX renderer
- selectable math widgets

## Intended Role

This package is the low-level lightweight renderer layer for a future smaller
default public package.
