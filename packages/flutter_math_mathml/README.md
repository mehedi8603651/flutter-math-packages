# flutter_math_mathml

MathML parser and encoder for Flutter math packages.

## Use This Package When

- you need MathML export
- you need MathML import
- you want TeX AST to MathML conversion
- you are integrating with web, XML, document, or accessibility pipelines

If your goal is normal Flutter widget rendering, use `flutter_math_katex`
instead.

## Install

```yaml
dependencies:
  flutter_math_mathml: ^0.1.0
```

## Quick Start

Encode MathML from a TeX AST:

```dart
import 'package:flutter_math_mathml/flutter_math_mathml.dart';
import 'package:flutter_math_tex/flutter_math_tex.dart';

final ast = TexParser(
  r'\frac{\mathbb{R}+1}{x_2}',
  const TexParserSettings(),
).parse();

print(ast.encodeMathML());
```

Parse MathML:

```dart
final ast = MathMLParser(
  '<math><mfrac><mi>a</mi><mi>b</mi></mfrac></math>',
).parse();

print(ast.encodeMathML());
```

## Current Scope

This package currently covers the shared presentation-math subset used by the
project:

- rows
- symbols
- fractions
- roots
- scripts
- functions
- paired delimiters
- n-ary operators
- accents
- style wrappers
- matrices and equation arrays
- raise-box and phantom nodes

## Current Boundary

The package is aimed at useful Presentation MathML round-tripping. Broader
MathML coverage can be added later without changing the package role.
