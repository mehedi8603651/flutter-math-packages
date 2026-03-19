# flutter_math_unicodemath

UnicodeMath parser and encoder for Flutter math packages.

## Use This Package When

- you need UnicodeMath input parsing
- you need UnicodeMath output encoding
- you are building conversion tools, editors, or copy/paste workflows
- you want TeX AST to UnicodeMath conversion

Most normal Flutter UI users do not need this package directly unless they are
doing import/export or editor work.

## Install

```yaml
dependencies:
  flutter_math_unicodemath: ^0.1.0
```

## Quick Start

Parse UnicodeMath:

```dart
import 'package:flutter_math_unicodemath/flutter_math_unicodemath.dart';

final ast = UnicodeMathParser('(ℝ+√(x_1))/𝐲').parse();

print(ast.encodeUnicodeMath());
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

## Current Scope

This package already handles a practical UnicodeMath subset well enough for:

- styled Unicode letters
- rows
- fractions
- roots
- subscripts and superscripts
- common operator-name functions
- n-ary operators
- round-tripping the package's current encoder output

## Current Boundary

This is not yet a full UnicodeMath specification implementation. The package
currently focuses on useful real-world input and stable round-tripping.
