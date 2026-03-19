// ignore_for_file: constant_identifier_names

/// Unit used by TeX-like size values.
enum Unit {
  pt,
  mm,
  cm,
  inches,
  bp,
  pc,
  dd,
  cc,
  nd,
  nc,
  sp,
  px,
  ex,
  em,
  mu,
  lp,
  cssEm,
}

extension UnitExt on Unit {
  static const _ptPerUnit = <Unit, double?>{
    Unit.pt: 1.0,
    Unit.mm: 7227 / 2540,
    Unit.cm: 7227 / 254,
    Unit.inches: 72.27,
    Unit.bp: 803 / 800,
    Unit.pc: 12.0,
    Unit.dd: 1238 / 1157,
    Unit.cc: 14856 / 1157,
    Unit.nd: 685 / 642,
    Unit.nc: 1370 / 107,
    Unit.sp: 1 / 65536,
    Unit.px: 803 / 800,
    Unit.ex: null,
    Unit.em: null,
    Unit.mu: null,
    Unit.lp: 72.27 / 160,
    Unit.cssEm: null,
  };

  double? get toPt => _ptPerUnit[this];

  String get name => const <Unit, String>{
        Unit.pt: 'pt',
        Unit.mm: 'mm',
        Unit.cm: 'cm',
        Unit.inches: 'inches',
        Unit.bp: 'bp',
        Unit.pc: 'pc',
        Unit.dd: 'dd',
        Unit.cc: 'cc',
        Unit.nd: 'nd',
        Unit.nc: 'nc',
        Unit.sp: 'sp',
        Unit.px: 'px',
        Unit.ex: 'ex',
        Unit.em: 'em',
        Unit.mu: 'mu',
        Unit.lp: 'lp',
        Unit.cssEm: 'cssEm',
      }[this]!;

  static Unit? parse(String unit) => unit.parseUnit();
}

extension UnitExtOnString on String {
  Unit? parseUnit() => const <String, Unit>{
        'pt': Unit.pt,
        'mm': Unit.mm,
        'cm': Unit.cm,
        'inches': Unit.inches,
        'bp': Unit.bp,
        'pc': Unit.pc,
        'dd': Unit.dd,
        'cc': Unit.cc,
        'nd': Unit.nd,
        'nc': Unit.nc,
        'sp': Unit.sp,
        'px': Unit.px,
        'ex': Unit.ex,
        'em': Unit.em,
        'mu': Unit.mu,
        'lp': Unit.lp,
        'cssEm': Unit.cssEm,
      }[this];
}

/// Renderer-agnostic measurement value.
class Measurement {
  final double value;
  final Unit unit;

  const Measurement({
    required this.value,
    required this.unit,
  });

  static const zero = Measurement(value: 0, unit: Unit.pt);

  bool get isZero => value == 0;

  Measurement copyWith({
    double? value,
    Unit? unit,
  }) =>
      Measurement(
        value: value ?? this.value,
        unit: unit ?? this.unit,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Measurement && other.value == value && other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(value, unit);

  @override
  String toString() => '$value${unit.name}';
}

extension MeasurementExtOnNum on num {
  Measurement get pt => Measurement(value: toDouble(), unit: Unit.pt);
  Measurement get mm => Measurement(value: toDouble(), unit: Unit.mm);
  Measurement get cm => Measurement(value: toDouble(), unit: Unit.cm);
  Measurement get inches => Measurement(value: toDouble(), unit: Unit.inches);
  Measurement get bp => Measurement(value: toDouble(), unit: Unit.bp);
  Measurement get pc => Measurement(value: toDouble(), unit: Unit.pc);
  Measurement get dd => Measurement(value: toDouble(), unit: Unit.dd);
  Measurement get cc => Measurement(value: toDouble(), unit: Unit.cc);
  Measurement get nd => Measurement(value: toDouble(), unit: Unit.nd);
  Measurement get nc => Measurement(value: toDouble(), unit: Unit.nc);
  Measurement get sp => Measurement(value: toDouble(), unit: Unit.sp);
  Measurement get px => Measurement(value: toDouble(), unit: Unit.px);
  Measurement get ex => Measurement(value: toDouble(), unit: Unit.ex);
  Measurement get em => Measurement(value: toDouble(), unit: Unit.em);
  Measurement get mu => Measurement(value: toDouble(), unit: Unit.mu);
  Measurement get lp => Measurement(value: toDouble(), unit: Unit.lp);
  Measurement get cssEm => Measurement(value: toDouble(), unit: Unit.cssEm);
}

/// TeX-like declared size.
enum MathSize {
  tiny,
  size2,
  scriptsize,
  footnotesize,
  small,
  normalsize,
  large,
  Large,
  LARGE,
  huge,
  HUGE,
}

extension SizeModeExt on MathSize {
  double get sizeMultiplier => const <double>[
        0.5,
        0.6,
        0.7,
        0.8,
        0.9,
        1.0,
        1.2,
        1.44,
        1.728,
        2.074,
        2.488,
      ][index];
}
