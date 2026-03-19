import 'package:flutter/widgets.dart';
import 'package:flutter_math_model/ast.dart';

@immutable
class LiteMathOptions {
  static const double defaultFontSize = 16.0;

  static const LiteMathOptions textOptions = LiteMathOptions();

  const LiteMathOptions({
    this.style = MathStyle.text,
    this.fontSize = defaultFontSize,
    this.color = const Color(0xFF000000),
    this.textStyle,
    this.textLocale,
    this.mathFontOptions,
    this.textFontOptions,
  });

  final MathStyle style;
  final double fontSize;
  final Color color;
  final TextStyle? textStyle;
  final Locale? textLocale;
  final FontOptions? mathFontOptions;
  final FontOptions? textFontOptions;

  double get lineThickness => (fontSize * 0.06).clamp(1.0, 4.0);

  double get axisHeight => fontSize * 0.25;

  LiteMathOptions copyWith({
    MathStyle? style,
    double? fontSize,
    Color? color,
    TextStyle? textStyle,
    Locale? textLocale,
    FontOptions? mathFontOptions,
    FontOptions? textFontOptions,
  }) {
    return LiteMathOptions(
      style: style ?? this.style,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      textStyle: textStyle ?? this.textStyle,
      textLocale: textLocale ?? this.textLocale,
      mathFontOptions: mathFontOptions ?? this.mathFontOptions,
      textFontOptions: textFontOptions ?? this.textFontOptions,
    );
  }

  LiteMathOptions forChildStyle(MathStyle childStyle) {
    return copyWith(
      style: childStyle,
      fontSize: fontSize * _styleScale(childStyle),
    );
  }

  LiteMathOptions havingStyle(MathStyle style) {
    if (this.style == style) {
      return this;
    }
    return copyWith(
      style: style,
      fontSize: defaultFontSize * _styleScale(style),
    );
  }

  LiteMathOptions havingSize(MathSize size) {
    final targetFontSize = fontSize * size.sizeMultiplier;
    if (targetFontSize == fontSize) {
      return this;
    }
    return copyWith(fontSize: targetFontSize);
  }

  LiteMathOptions withColor(MathColor color) =>
      copyWith(color: Color(color.toARGB32()));

  LiteMathOptions withTextFont(PartialFontOptions font) => copyWith(
        mathFontOptions: null,
        textFontOptions:
            (textFontOptions ?? const FontOptions()).mergeWith(font),
      );

  LiteMathOptions withMathFont(FontOptions font) => copyWith(
        mathFontOptions: font,
      );

  LiteMathOptions merge(OptionsDiff partialOptions) {
    var result = this;
    if (partialOptions.size != null) {
      result = result.havingSize(partialOptions.size!);
    }
    if (partialOptions.style != null) {
      result = result.havingStyle(partialOptions.style!);
    }
    if (partialOptions.color != null) {
      result = result.withColor(partialOptions.color!);
    }
    if (partialOptions.textFontOptions != null) {
      result = result.withTextFont(partialOptions.textFontOptions!);
    }
    if (partialOptions.mathFontOptions != null) {
      result = result.withMathFont(partialOptions.mathFontOptions!);
    }
    return result;
  }

  TextStyle resolveTextStyle({
    FontOptions? overrideFont,
    bool textMode = false,
  }) {
    final font = overrideFont ?? (textMode ? textFontOptions : mathFontOptions);
    final baseStyle = (textStyle ?? const TextStyle()).copyWith(
      color: color,
      fontSize: fontSize,
    );

    return baseStyle.copyWith(
      fontFamily: _resolveFontFamily(font?.fontFamily),
      fontWeight: _resolveFontWeight(font?.fontWeight) ?? baseStyle.fontWeight,
      fontStyle: _resolveFontStyle(font?.fontShape) ?? baseStyle.fontStyle,
    );
  }

  static double _styleScale(MathStyle style) {
    switch (style.size) {
      case 0:
      case 1:
        return 1.0;
      case 2:
        return 0.7;
      case 3:
        return 0.5;
      default:
        return 1.0;
    }
  }

  static String? _resolveFontFamily(String? family) {
    switch (family) {
      case null:
      case 'Main':
      case 'Math':
      case 'AMS':
      case 'Caligraphic':
      case 'Fraktur':
      case 'Script':
      case 'Size1':
      case 'Size2':
      case 'Size3':
      case 'Size4':
        return null;
      case 'SansSerif':
        return 'sans-serif';
      case 'Typewriter':
        return 'monospace';
      default:
        return family;
    }
  }

  static FontWeight? _resolveFontWeight(MathFontWeight? weight) {
    switch (weight) {
      case null:
        return null;
      case MathFontWeight.normal:
        return FontWeight.w400;
      case MathFontWeight.bold:
        return FontWeight.w700;
    }
  }

  static FontStyle? _resolveFontStyle(MathFontStyle? style) {
    switch (style) {
      case null:
        return null;
      case MathFontStyle.normal:
        return FontStyle.normal;
      case MathFontStyle.italic:
        return FontStyle.italic;
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LiteMathOptions &&
            other.style == style &&
            other.fontSize == fontSize &&
            other.color == color &&
            other.textStyle == textStyle &&
            other.textLocale == textLocale &&
            other.mathFontOptions == mathFontOptions &&
            other.textFontOptions == textFontOptions;
  }

  @override
  int get hashCode => Object.hash(
        style,
        fontSize,
        color,
        textStyle,
        textLocale,
        mathFontOptions,
        textFontOptions,
      );
}
