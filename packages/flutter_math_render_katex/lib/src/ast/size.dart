import 'package:flutter_math_model/ast.dart';

import 'options.dart';

export 'package:flutter_math_model/ast.dart'
    show
        MathSize,
        Measurement,
        MeasurementExtOnNum,
        SizeModeExt,
        Unit,
        UnitExt,
        UnitExtOnString;

extension MeasurementRenderExt on Measurement {
  double toLpUnder(MathOptions options) {
    if (unit == Unit.lp) {
      return value;
    }
    if (unit.toPt != null) {
      return value * unit.toPt! / Unit.inches.toPt! * options.logicalPpi;
    }
    switch (unit) {
      case Unit.cssEm:
        return value * options.fontSize * options.sizeMultiplier;
      case Unit.mu:
        return value *
            options.fontSize *
            options.fontMetrics.cssEmPerMu *
            options.sizeMultiplier;
      case Unit.ex:
        return value *
            options.fontSize *
            options.fontMetrics.xHeight *
            options.havingStyle(options.style.atLeastText()).sizeMultiplier;
      case Unit.em:
        return value *
            options.fontSize *
            options.fontMetrics.quad *
            options.havingStyle(options.style.atLeastText()).sizeMultiplier;
      default:
        throw ArgumentError("Invalid unit: '${unit.toString()}'");
    }
  }

  double toCssEmUnder(MathOptions options) =>
      toLpUnder(options) / options.fontSize;
}
