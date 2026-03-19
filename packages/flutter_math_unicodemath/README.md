# flutter_math_unicodemath

UnicodeMath frontend package for the `flutter_math` package family.

Current status:

- real standalone pure Dart package
- depends only on `flutter_math_model` at runtime
- owns an initial UnicodeMath encoder
- owns an initial UnicodeMath parser

What the package does today:

- encodes shared AST nodes into UnicodeMath-friendly plain text
- parses a practical first UnicodeMath subset back into shared-model AST nodes
- uses direct Unicode symbols where possible
- maps common font styles such as bold, italic, double-struck, script,
  fraktur, sans-serif, and monospace onto Unicode mathematical alphanumeric
  characters when possible
- falls back to readable command forms for nodes that do not yet have a
  normalized UnicodeMath encoding in this package

Current parser coverage:

- styled Unicode math letters and digits such as `ℝ` and `𝐲`
- plain symbol rows
- fractions with `/`
- roots with `√`
- subscripts and superscripts with `_` and `^`
- function-style application for common operator names such as `sin x`
- n-ary operators such as `∑_i^n x`
- readable fallback commands emitted by the current encoder:
  - `\color`
  - `\size`
  - `\style`
  - `\overset`
  - `\underset`
  - `\accent`
  - `\underaccent`
  - `\enclose`
  - `\matrix`
  - `\eqarray`
  - `\raise`
  - `\phantom`
  - `\hphantom`
  - `\vphantom`

Current boundary:

- the parser is intentionally an initial subset aimed at stable round-tripping
  of this package's current UnicodeMath encoder output
- full UnicodeMath coverage and richer ambiguity handling still need future
  work

Example:

```dart
import 'package:flutter_math_model/ast.dart';
import 'package:flutter_math_unicodemath/flutter_math_unicodemath.dart';

void main() {
  final ast = UnicodeMathParser('(ℝ+√(x_1))/𝐲').parse();

  print(ast.encodeUnicodeMath()); // (ℝ+√(x_1))/𝐲
}
```
