import 'package:flutter_math_model/ast.dart';

import '../lite_math_options.dart';

extension LiteMeasurementExt on Measurement {
  double toLogicalPx(LiteMathOptions options) {
    final pt = unit.toPt;
    if (pt != null) {
      return value * pt * 96 / 72.27;
    }

    switch (unit) {
      case Unit.em:
      case Unit.cssEm:
        return value * options.fontSize;
      case Unit.ex:
        return value * options.fontSize * 0.5;
      case Unit.mu:
        return value * options.fontSize / 18;
      case Unit.lp:
      case Unit.px:
        return value;
      default:
        return value;
    }
  }
}
