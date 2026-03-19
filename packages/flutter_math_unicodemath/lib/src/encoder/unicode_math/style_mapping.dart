import 'package:flutter_math_model/ast.dart';

enum _MathAlphabetStyle {
  bold,
  italic,
  boldItalic,
  script,
  boldScript,
  fraktur,
  boldFraktur,
  doubleStruck,
  sans,
  sansBold,
  sansItalic,
  sansBoldItalic,
  monospace,
}

/// Result of decoding a Unicode mathematical alphanumeric symbol.
class DecodedMathAlphabetSymbol {
  final String symbol;
  final FontOptions font;

  const DecodedMathAlphabetSymbol({
    required this.symbol,
    required this.font,
  });
}

String applyMathAlphabetStyle(String symbol, FontOptions? font) {
  if (font == null) {
    return symbol;
  }
  final style = _fontToAlphabetStyle(font);
  if (style == null) {
    return symbol;
  }
  return String.fromCharCodes(
    symbol.runes.map((rune) => _mapRune(rune, style) ?? rune),
  );
}

DecodedMathAlphabetSymbol? decodeMathAlphabetStyle(String symbol) {
  if (symbol.runes.length != 1) {
    return null;
  }
  return _reverseMathAlphabetMap[symbol.runes.single];
}

_MathAlphabetStyle? _fontToAlphabetStyle(FontOptions font) {
  switch (font.fontFamily) {
    case 'AMS':
      return _MathAlphabetStyle.doubleStruck;
    case 'Caligraphic':
    case 'Script':
      return font.fontWeight == MathFontWeight.bold
          ? _MathAlphabetStyle.boldScript
          : _MathAlphabetStyle.script;
    case 'Fraktur':
      return font.fontWeight == MathFontWeight.bold
          ? _MathAlphabetStyle.boldFraktur
          : _MathAlphabetStyle.fraktur;
    case 'Typewriter':
      return _MathAlphabetStyle.monospace;
    case 'SansSerif':
      if (font.fontWeight == MathFontWeight.bold &&
          font.fontShape == MathFontStyle.italic) {
        return _MathAlphabetStyle.sansBoldItalic;
      }
      if (font.fontWeight == MathFontWeight.bold) {
        return _MathAlphabetStyle.sansBold;
      }
      if (font.fontShape == MathFontStyle.italic) {
        return _MathAlphabetStyle.sansItalic;
      }
      return _MathAlphabetStyle.sans;
    case 'Math':
    case 'Main':
      if (font.fontWeight == MathFontWeight.bold &&
          font.fontShape == MathFontStyle.italic) {
        return _MathAlphabetStyle.boldItalic;
      }
      if (font.fontWeight == MathFontWeight.bold) {
        return _MathAlphabetStyle.bold;
      }
      if (font.fontShape == MathFontStyle.italic) {
        return _MathAlphabetStyle.italic;
      }
      return null;
    default:
      return null;
  }
}

int? _mapRune(int rune, _MathAlphabetStyle style) {
  if (_isAsciiUpper(rune)) {
    return _mapUppercaseRune(rune, style);
  }
  if (_isAsciiLower(rune)) {
    return _mapLowercaseRune(rune, style);
  }
  if (_isAsciiDigit(rune)) {
    return _mapDigitRune(rune, style);
  }
  return null;
}

int? _mapUppercaseRune(int rune, _MathAlphabetStyle style) {
  final override = switch (style) {
    _MathAlphabetStyle.script => _scriptUpperExceptions[rune],
    _MathAlphabetStyle.fraktur => _frakturUpperExceptions[rune],
    _MathAlphabetStyle.doubleStruck => _doubleStruckUpperExceptions[rune],
    _ => null,
  };
  if (override != null) {
    return override;
  }

  final base = switch (style) {
    _MathAlphabetStyle.bold => 0x1D400,
    _MathAlphabetStyle.italic => 0x1D434,
    _MathAlphabetStyle.boldItalic => 0x1D468,
    _MathAlphabetStyle.script => 0x1D49C,
    _MathAlphabetStyle.boldScript => 0x1D4D0,
    _MathAlphabetStyle.fraktur => 0x1D504,
    _MathAlphabetStyle.boldFraktur => 0x1D56C,
    _MathAlphabetStyle.doubleStruck => 0x1D538,
    _MathAlphabetStyle.sans => 0x1D5A0,
    _MathAlphabetStyle.sansBold => 0x1D5D4,
    _MathAlphabetStyle.sansItalic => 0x1D608,
    _MathAlphabetStyle.sansBoldItalic => 0x1D63C,
    _MathAlphabetStyle.monospace => 0x1D670,
  };
  return base + (rune - 0x41);
}

int? _mapLowercaseRune(int rune, _MathAlphabetStyle style) {
  final override = switch (style) {
    _MathAlphabetStyle.italic => _italicLowerExceptions[rune],
    _MathAlphabetStyle.script => _scriptLowerExceptions[rune],
    _ => null,
  };
  if (override != null) {
    return override;
  }

  final base = switch (style) {
    _MathAlphabetStyle.bold => 0x1D41A,
    _MathAlphabetStyle.italic => 0x1D44E,
    _MathAlphabetStyle.boldItalic => 0x1D482,
    _MathAlphabetStyle.script => 0x1D4B6,
    _MathAlphabetStyle.boldScript => 0x1D4EA,
    _MathAlphabetStyle.fraktur => 0x1D51E,
    _MathAlphabetStyle.boldFraktur => 0x1D586,
    _MathAlphabetStyle.doubleStruck => 0x1D552,
    _MathAlphabetStyle.sans => 0x1D5BA,
    _MathAlphabetStyle.sansBold => 0x1D5EE,
    _MathAlphabetStyle.sansItalic => 0x1D622,
    _MathAlphabetStyle.sansBoldItalic => 0x1D656,
    _MathAlphabetStyle.monospace => 0x1D68A,
  };
  return base + (rune - 0x61);
}

int? _mapDigitRune(int rune, _MathAlphabetStyle style) {
  final base = switch (style) {
    _MathAlphabetStyle.bold => 0x1D7CE,
    _MathAlphabetStyle.doubleStruck => 0x1D7D8,
    _MathAlphabetStyle.sans => 0x1D7E2,
    _MathAlphabetStyle.sansBold => 0x1D7EC,
    _MathAlphabetStyle.monospace => 0x1D7F6,
    _ => null,
  };
  return base == null ? null : base + (rune - 0x30);
}

bool _isAsciiUpper(int rune) => rune >= 0x41 && rune <= 0x5A;

bool _isAsciiLower(int rune) => rune >= 0x61 && rune <= 0x7A;

bool _isAsciiDigit(int rune) => rune >= 0x30 && rune <= 0x39;

const _italicLowerExceptions = <int, int>{0x68: 0x210E};

const _scriptUpperExceptions = <int, int>{
  0x42: 0x212C,
  0x45: 0x2130,
  0x46: 0x2131,
  0x48: 0x210B,
  0x49: 0x2110,
  0x4C: 0x2112,
  0x4D: 0x2133,
  0x52: 0x211B,
};

const _scriptLowerExceptions = <int, int>{
  0x65: 0x212F,
  0x67: 0x210A,
  0x6F: 0x2134,
};

const _frakturUpperExceptions = <int, int>{
  0x43: 0x212D,
  0x48: 0x210C,
  0x49: 0x2111,
  0x52: 0x211C,
  0x5A: 0x2128,
};

const _doubleStruckUpperExceptions = <int, int>{
  0x43: 0x2102,
  0x48: 0x210D,
  0x4E: 0x2115,
  0x50: 0x2119,
  0x51: 0x211A,
  0x52: 0x211D,
  0x5A: 0x2124,
};

final _reverseMathAlphabetMap = _buildReverseMathAlphabetMap();

Map<int, DecodedMathAlphabetSymbol> _buildReverseMathAlphabetMap() {
  const fontOptions = <FontOptions>[
    FontOptions(
      fontFamily: 'Main',
      fontWeight: MathFontWeight.bold,
    ),
    FontOptions(
      fontFamily: 'Main',
      fontShape: MathFontStyle.italic,
    ),
    FontOptions(
      fontFamily: 'Main',
      fontWeight: MathFontWeight.bold,
      fontShape: MathFontStyle.italic,
    ),
    FontOptions(fontFamily: 'Script'),
    FontOptions(
      fontFamily: 'Script',
      fontWeight: MathFontWeight.bold,
    ),
    FontOptions(fontFamily: 'Fraktur'),
    FontOptions(
      fontFamily: 'Fraktur',
      fontWeight: MathFontWeight.bold,
    ),
    FontOptions(fontFamily: 'AMS'),
    FontOptions(fontFamily: 'SansSerif'),
    FontOptions(
      fontFamily: 'SansSerif',
      fontWeight: MathFontWeight.bold,
    ),
    FontOptions(
      fontFamily: 'SansSerif',
      fontShape: MathFontStyle.italic,
    ),
    FontOptions(
      fontFamily: 'SansSerif',
      fontWeight: MathFontWeight.bold,
      fontShape: MathFontStyle.italic,
    ),
    FontOptions(fontFamily: 'Typewriter'),
  ];

  final map = <int, DecodedMathAlphabetSymbol>{};

  void addEntry(String sourceSymbol, FontOptions font) {
    final encoded = applyMathAlphabetStyle(sourceSymbol, font);
    if (encoded == sourceSymbol || encoded.runes.length != 1) {
      return;
    }
    map.putIfAbsent(
      encoded.runes.single,
      () => DecodedMathAlphabetSymbol(symbol: sourceSymbol, font: font),
    );
  }

  for (final font in fontOptions) {
    for (var codePoint = 0x41; codePoint <= 0x5A; codePoint++) {
      addEntry(String.fromCharCode(codePoint), font);
    }
    for (var codePoint = 0x61; codePoint <= 0x7A; codePoint++) {
      addEntry(String.fromCharCode(codePoint), font);
    }
    for (var codePoint = 0x30; codePoint <= 0x39; codePoint++) {
      addEntry(String.fromCharCode(codePoint), font);
    }
  }

  return map;
}
