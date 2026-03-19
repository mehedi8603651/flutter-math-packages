import 'dart:convert';

import 'package:flutter_math_model/ast.dart';

import 'unicode_math/encoder.dart' as unicode_math;

/// Behavior for nodes or properties that do not yet have a normalized
/// UnicodeMath encoding in this package.
enum UnicodeMathEncodeUnsupportedBehavior { preserve, omit, error }

/// Encoder configuration for UnicodeMath export.
class UnicodeMathEncodeConf {
  final Mode mode;
  final FontOptions? mathFontOptions;
  final FontOptions? textFontOptions;
  final bool preferUnicodeStylePlane;
  final UnicodeMathEncodeUnsupportedBehavior unsupportedBehavior;

  const UnicodeMathEncodeConf({
    this.mode = Mode.math,
    this.mathFontOptions,
    this.textFontOptions,
    this.preferUnicodeStylePlane = true,
    this.unsupportedBehavior = UnicodeMathEncodeUnsupportedBehavior.preserve,
  });

  UnicodeMathEncodeConf copyWith({
    Mode? mode,
    FontOptions? mathFontOptions,
    FontOptions? textFontOptions,
    bool? preferUnicodeStylePlane,
    UnicodeMathEncodeUnsupportedBehavior? unsupportedBehavior,
  }) =>
      UnicodeMathEncodeConf(
        mode: mode ?? this.mode,
        mathFontOptions: mathFontOptions ?? this.mathFontOptions,
        textFontOptions: textFontOptions ?? this.textFontOptions,
        preferUnicodeStylePlane:
            preferUnicodeStylePlane ?? this.preferUnicodeStylePlane,
        unsupportedBehavior: unsupportedBehavior ?? this.unsupportedBehavior,
      );

  UnicodeMathEncodeConf forMode(Mode nextMode) =>
      nextMode == mode ? this : copyWith(mode: nextMode);

  UnicodeMathEncodeConf mergeStyle(OptionsDiff diff) => copyWith(
        mathFontOptions: diff.mathFontOptions ?? mathFontOptions,
        textFontOptions: diff.textFontOptions == null
            ? textFontOptions
            : (textFontOptions ?? const FontOptions()).mergeWith(
                diff.textFontOptions,
              ),
      );
}

/// Thrown when UnicodeMath encoding cannot continue in strict mode.
class UnicodeMathEncoderException implements Exception {
  final String message;

  const UnicodeMathEncoderException(this.message);

  @override
  String toString() => 'UnicodeMathEncoderException: $message';
}

/// Stateless converter wrapper around the UnicodeMath encoder.
class UnicodeMathEncoder extends Converter<GreenNode, String> {
  final UnicodeMathEncodeConf conf;

  const UnicodeMathEncoder({this.conf = const UnicodeMathEncodeConf()});

  @override
  String convert(GreenNode input) =>
      unicode_math.encodeUnicodeMathNode(input, conf: conf);
}
