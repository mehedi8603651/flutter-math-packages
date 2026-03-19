import 'dart:developer' as developer;

import 'macro_types.dart';
import 'parse_error.dart';
import 'token.dart';

/// Strictness level for TeX front-end processing.
enum Strict { ignore, warn, error, function }

/// Settings shared by TeX front-end components.
class TexParserSettings {
  final bool displayMode;
  final bool throwOnError;
  final Map<String, MacroDefinition> macros;
  final int maxExpand;
  final Strict strict;
  final Strict Function(String, String, Token?)? strictFun;
  final bool globalGroup;
  final bool colorIsTextColor;

  const TexParserSettings({
    this.displayMode = false,
    this.throwOnError = true,
    this.macros = const <String, MacroDefinition>{},
    this.maxExpand = 1000,
    Strict strict = Strict.warn,
    this.strictFun,
    this.globalGroup = false,
    this.colorIsTextColor = false,
  }) : strict = strictFun == null ? strict : Strict.function;

  void reportNonstrict(String errorCode, String errorMsg, [Token? token]) {
    final effectiveStrict = strict != Strict.function
        ? strict
        : (strictFun?.call(errorCode, errorMsg, token) ?? Strict.warn);
    switch (effectiveStrict) {
      case Strict.ignore:
        return;
      case Strict.error:
        throw ParseException(
          "LaTeX-incompatible input and strict mode is set to 'error': "
          '$errorMsg [$errorCode]',
          token,
        );
      case Strict.warn:
        developer.log(
          "LaTeX-incompatible input and strict mode is set to 'warn': "
          '$errorMsg [$errorCode]',
          name: 'flutter_math_tex',
        );
        break;
      default:
        developer.log(
          'LaTeX-incompatible input and strict mode is set to '
          "unrecognized '$effectiveStrict': $errorMsg [$errorCode]",
          name: 'flutter_math_tex',
        );
    }
  }

  bool useStrictBehavior(String errorCode, String errorMsg, [Token? token]) {
    var effectiveStrict = strict;
    if (effectiveStrict == Strict.function) {
      try {
        effectiveStrict = strictFun!(errorCode, errorMsg, token);
      } on Object {
        effectiveStrict = Strict.error;
      }
    }
    switch (effectiveStrict) {
      case Strict.ignore:
        return false;
      case Strict.error:
        return true;
      case Strict.warn:
        developer.log(
          "LaTeX-incompatible input and strict mode is set to 'warn': "
          '$errorMsg [$errorCode]',
          name: 'flutter_math_tex',
        );
        return false;
      default:
        developer.log(
          'LaTeX-incompatible input and strict mode is set to '
          "unrecognized '$effectiveStrict': $errorMsg [$errorCode]",
          name: 'flutter_math_tex',
        );
        return false;
    }
  }
}
