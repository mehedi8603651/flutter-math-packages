import 'size.dart';

/// TeX layout style.
enum MathStyle {
  display,
  displayCramped,
  text,
  textCramped,
  script,
  scriptCramped,
  scriptscript,
  scriptscriptCramped,
}

/// Relative style transforms used by TeX layout rules.
enum MathStyleDiff {
  sub,
  sup,
  fracNum,
  fracDen,
  cramp,
  text,
  uncramp,
}

MathStyle? parseMathStyle(String string) => const <String, MathStyle>{
      'display': MathStyle.display,
      'displayCramped': MathStyle.displayCramped,
      'text': MathStyle.text,
      'textCramped': MathStyle.textCramped,
      'script': MathStyle.script,
      'scriptCramped': MathStyle.scriptCramped,
      'scriptscript': MathStyle.scriptscript,
      'scriptscriptCramped': MathStyle.scriptscriptCramped,
    }[string];

extension MathStyleExt on MathStyle {
  bool get cramped => index.isEven;

  int get size => index ~/ 2;

  MathStyle reduce(MathStyleDiff? diff) =>
      diff == null ? this : MathStyle.values[_reduceTable[diff.index][index]];

  static const _reduceTable = <List<int>>[
    [4, 5, 4, 5, 6, 7, 6, 7],
    [5, 5, 5, 5, 7, 7, 7, 7],
    [2, 3, 4, 5, 6, 7, 6, 7],
    [3, 3, 5, 5, 7, 7, 7, 7],
    [1, 1, 3, 3, 5, 5, 7, 7],
    [0, 1, 2, 3, 2, 3, 2, 3],
    [0, 0, 2, 2, 4, 4, 6, 6],
  ];

  MathStyle sup() => reduce(MathStyleDiff.sup);

  MathStyle sub() => reduce(MathStyleDiff.sub);

  MathStyle fracNum() => reduce(MathStyleDiff.fracNum);

  MathStyle fracDen() => reduce(MathStyleDiff.fracDen);

  MathStyle cramp() => reduce(MathStyleDiff.cramp);

  MathStyle atLeastText() => reduce(MathStyleDiff.text);

  MathStyle uncramp() => reduce(MathStyleDiff.uncramp);

  bool operator >(MathStyle other) => index < other.index;

  bool operator <(MathStyle other) => index > other.index;

  bool operator >=(MathStyle other) => index <= other.index;

  bool operator <=(MathStyle other) => index >= other.index;

  bool isTight() => size >= 2;
}

extension MathStyleExtOnInt on int {
  MathStyle toMathStyle() => MathStyle.values[(this * 2).clamp(0, 6).toInt()];
}

extension MathStyleExtOnSize on MathSize {
  MathSize underStyle(MathStyle style) {
    if (style >= MathStyle.textCramped) {
      return this;
    }
    return MathSize.values[_sizeStyleMap[index][style.size - 1] - 1];
  }

  static const _sizeStyleMap = <List<int>>[
    [1, 1, 1],
    [2, 1, 1],
    [3, 1, 1],
    [4, 2, 1],
    [5, 2, 1],
    [6, 3, 1],
    [7, 4, 2],
    [8, 6, 3],
    [9, 7, 6],
    [10, 8, 7],
    [11, 10, 9],
  ];
}
