import 'dart:convert';

import 'package:flutter_math_model/ast.dart';

import 'mathml/encoder.dart' as mathml;

/// Behavior for nodes or properties that are not fully normalized yet.
enum MathMLEncodeUnsupportedBehavior { preserve, omit, error }

/// Encoder configuration for MathML export.
class MathMLEncodeConf {
  final bool includeMathTag;
  final bool includeXmlNamespace;
  final bool displayMode;
  final MathMLEncodeUnsupportedBehavior unsupportedBehavior;

  const MathMLEncodeConf({
    this.includeMathTag = true,
    this.includeXmlNamespace = true,
    this.displayMode = false,
    this.unsupportedBehavior = MathMLEncodeUnsupportedBehavior.preserve,
  });

  MathMLEncodeConf copyWith({
    bool? includeMathTag,
    bool? includeXmlNamespace,
    bool? displayMode,
    MathMLEncodeUnsupportedBehavior? unsupportedBehavior,
  }) =>
      MathMLEncodeConf(
        includeMathTag: includeMathTag ?? this.includeMathTag,
        includeXmlNamespace: includeXmlNamespace ?? this.includeXmlNamespace,
        displayMode: displayMode ?? this.displayMode,
        unsupportedBehavior: unsupportedBehavior ?? this.unsupportedBehavior,
      );
}

/// Thrown when MathML encoding cannot continue in strict mode.
class MathMLEncoderException implements Exception {
  final String message;

  const MathMLEncoderException(this.message);

  @override
  String toString() => 'MathMLEncoderException: $message';
}

/// Stateless converter wrapper around the MathML encoder.
class MathMLEncoder extends Converter<GreenNode, String> {
  final MathMLEncodeConf conf;

  const MathMLEncoder({this.conf = const MathMLEncodeConf()});

  @override
  String convert(GreenNode input) => mathml.encodeMathMLNode(input, conf: conf);
}
