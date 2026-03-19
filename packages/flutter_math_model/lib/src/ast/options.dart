import 'size.dart';
import 'style.dart';

/// Pure ARGB color value used by parser-facing APIs.
class MathColor {
  final int value;

  const MathColor(this.value);

  const MathColor.fromARGB(int a, int r, int g, int b)
      : value = ((a & 0xff) << 24) |
            ((r & 0xff) << 16) |
            ((g & 0xff) << 8) |
            (b & 0xff);

  int toARGB32() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MathColor && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() =>
      'MathColor(0x${value.toRadixString(16).padLeft(8, '0')})';
}

/// Parser-facing font weight that stays independent from Flutter.
enum MathFontWeight {
  normal,
  bold,
}

/// Parser-facing font shape that stays independent from Flutter.
enum MathFontStyle {
  normal,
  italic,
}

/// Pure font selection options shared by parsers, encoders, and renderers.
class FontOptions {
  /// Font family. E.g. Main, Math, SansSerif, etc.
  final String fontFamily;

  /// Font weight. Bold or normal.
  final MathFontWeight fontWeight;

  /// Font shape. Italic or normal.
  final MathFontStyle fontShape;

  /// Fallback font options if a character cannot be found in this font.
  final List<FontOptions> fallback;

  const FontOptions({
    this.fontFamily = 'Main',
    this.fontWeight = MathFontWeight.normal,
    this.fontShape = MathFontStyle.normal,
    this.fallback = const [],
  });

  /// Complete font name. Used to index character metrics.
  String get fontName {
    final postfix = '${fontWeight == MathFontWeight.bold ? 'Bold' : ''}'
        '${fontShape == MathFontStyle.italic ? 'Italic' : ''}';
    return '$fontFamily-${postfix.isEmpty ? 'Regular' : postfix}';
  }

  FontOptions copyWith({
    String? fontFamily,
    MathFontWeight? fontWeight,
    MathFontStyle? fontShape,
    List<FontOptions>? fallback,
  }) =>
      FontOptions(
        fontFamily: fontFamily ?? this.fontFamily,
        fontWeight: fontWeight ?? this.fontWeight,
        fontShape: fontShape ?? this.fontShape,
        fallback: fallback ?? this.fallback,
      );

  FontOptions mergeWith(PartialFontOptions? value) {
    if (value == null) {
      return this;
    }
    return copyWith(
      fontFamily: value.fontFamily,
      fontWeight: value.fontWeight,
      fontShape: value.fontShape,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FontOptions &&
            other.fontFamily == fontFamily &&
            other.fontWeight == fontWeight &&
            other.fontShape == fontShape &&
            _listEquals(other.fallback, fallback);
  }

  @override
  int get hashCode =>
      Object.hash(fontFamily, fontWeight, fontShape, Object.hashAll(fallback));

  @override
  String toString() {
    return 'FontOptions(fontFamily: $fontFamily, fontWeight: $fontWeight, '
        'fontShape: $fontShape, fallback: $fallback)';
  }
}

/// Partial font override shared by parser-facing APIs.
class PartialFontOptions {
  final String? fontFamily;
  final MathFontWeight? fontWeight;
  final MathFontStyle? fontShape;

  const PartialFontOptions({
    this.fontFamily,
    this.fontWeight,
    this.fontShape,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PartialFontOptions &&
            other.fontFamily == fontFamily &&
            other.fontWeight == fontWeight &&
            other.fontShape == fontShape;
  }

  @override
  int get hashCode => Object.hash(fontFamily, fontWeight, fontShape);

  @override
  String toString() {
    return 'PartialFontOptions(fontFamily: $fontFamily, '
        'fontWeight: $fontWeight, fontShape: $fontShape)';
  }
}

/// Difference between the current style/font state and the desired one.
class OptionsDiff {
  final MathStyle? style;
  final MathSize? size;
  final MathColor? color;
  final PartialFontOptions? textFontOptions;
  final FontOptions? mathFontOptions;

  const OptionsDiff({
    this.style,
    this.size,
    this.color,
    this.textFontOptions,
    this.mathFontOptions,
  });

  bool get isEmpty =>
      style == null &&
      size == null &&
      color == null &&
      textFontOptions == null &&
      mathFontOptions == null;

  OptionsDiff removeStyle() {
    if (style == null) {
      return this;
    }
    return OptionsDiff(
      size: size,
      color: color,
      textFontOptions: textFontOptions,
      mathFontOptions: mathFontOptions,
    );
  }

  OptionsDiff removeMathFont() {
    if (mathFontOptions == null) {
      return this;
    }
    return OptionsDiff(
      style: style,
      size: size,
      color: color,
      textFontOptions: textFontOptions,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OptionsDiff &&
            other.style == style &&
            other.size == size &&
            other.color == color &&
            other.textFontOptions == textFontOptions &&
            other.mathFontOptions == mathFontOptions;
  }

  @override
  int get hashCode =>
      Object.hash(style, size, color, textFontOptions, mathFontOptions);

  @override
  String toString() {
    return 'OptionsDiff(style: $style, size: $size, color: $color, '
        'textFontOptions: $textFontOptions, '
        'mathFontOptions: $mathFontOptions)';
  }
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (identical(left, right)) {
    return true;
  }
  if (left.length != right.length) {
    return false;
  }
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) {
      return false;
    }
  }
  return true;
}
