/// TeX front-end core for the `flutter_math` package family.
///
/// This package owns the TeX parsing and encoding stack over
/// `flutter_math_model`.
library;

export 'src/ast.dart';
export 'src/encoder/encoder.dart';
export 'src/encoder/exception.dart';
export 'src/encoder/tex/encoder.dart';
export 'src/parser/tex/definition_lookup.dart';
export 'src/parser/tex/colors.dart';
export 'src/parser/tex/font.dart';
export 'src/parser/tex/lexer.dart';
export 'src/parser/tex/macro_expander.dart';
export 'src/parser/tex/macro_types.dart';
export 'src/parser/tex/namespace.dart';
export 'src/parser/tex/parse_error.dart';
export 'src/parser/tex/parser.dart';
export 'src/parser/tex/registry.dart';
export 'src/parser/tex/settings.dart';
export 'src/parser/tex/source_location.dart';
export 'src/parser/tex/symbols.dart';
export 'src/parser/tex/token.dart';
export 'tex.dart';
