# flutter_math_mathml

MathML frontend package for the `flutter_math` package family.

Current status:

- working pure Dart package
- initial MathML encoder exists
- initial MathML parser exists

What it currently provides:

- MathML encoding for the shared `flutter_math_model` AST
- MathML parsing back into the shared `flutter_math_model` AST for the current
  package-supported presentation subset
- support for common shared nodes:
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
  - matrices / equation arrays
  - raise-box / phantom
- package-local `EnclosureNode` for future `menclose`-style parsing and
  encoding work

Current boundary:

- the encoder is intended as the first stable MathML export layer
- the parser is intended as the first stable round-trip import layer for the
  package's current encoder output
- it focuses on clean, readable MathML over exact browser-specific layout
  tuning
- broader MathML coverage and ambiguity handling are the next major steps after
  this package baseline

Example:

```dart
import 'package:flutter_math_mathml/flutter_math_mathml.dart';
import 'package:flutter_math_tex/flutter_math_tex.dart';

void main() {
  final mathml = TexParser(
    r'\frac{\mathbb{R}+1}{x_2}',
    const TexParserSettings(),
  ).parse().encodeMathML();

  print(MathMLParser(mathml).parse().encodeMathML());
}
```
