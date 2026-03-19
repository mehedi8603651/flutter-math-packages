import 'package:flutter_math_model/ast.dart';

import '../lite_math_options.dart';
import 'lite_measurement.dart';

const Measurement _thinSpace = Measurement(value: 3, unit: Unit.mu);
const Measurement _mediumSpace = Measurement(value: 4, unit: Unit.mu);
const Measurement _thickSpace = Measurement(value: 5, unit: Unit.mu);

const Map<AtomType, Map<AtomType, Measurement>> _spacings =
    <AtomType, Map<AtomType, Measurement>>{
  AtomType.ord: <AtomType, Measurement>{
    AtomType.op: _thinSpace,
    AtomType.bin: _mediumSpace,
    AtomType.rel: _thickSpace,
    AtomType.inner: _thinSpace,
  },
  AtomType.op: <AtomType, Measurement>{
    AtomType.ord: _thinSpace,
    AtomType.op: _thinSpace,
    AtomType.rel: _thickSpace,
    AtomType.inner: _thinSpace,
  },
  AtomType.bin: <AtomType, Measurement>{
    AtomType.ord: _mediumSpace,
    AtomType.op: _mediumSpace,
    AtomType.open: _mediumSpace,
    AtomType.inner: _mediumSpace,
  },
  AtomType.rel: <AtomType, Measurement>{
    AtomType.ord: _thickSpace,
    AtomType.op: _thickSpace,
    AtomType.open: _thickSpace,
    AtomType.inner: _thickSpace,
  },
  AtomType.open: <AtomType, Measurement>{},
  AtomType.close: <AtomType, Measurement>{
    AtomType.op: _thinSpace,
    AtomType.bin: _mediumSpace,
    AtomType.rel: _thickSpace,
    AtomType.inner: _thinSpace,
  },
  AtomType.punct: <AtomType, Measurement>{
    AtomType.ord: _thinSpace,
    AtomType.op: _thinSpace,
    AtomType.rel: _thickSpace,
    AtomType.open: _thinSpace,
    AtomType.close: _thinSpace,
    AtomType.punct: _thinSpace,
    AtomType.inner: _thinSpace,
  },
  AtomType.inner: <AtomType, Measurement>{
    AtomType.ord: _thinSpace,
    AtomType.op: _thinSpace,
    AtomType.bin: _mediumSpace,
    AtomType.rel: _thickSpace,
    AtomType.open: _thinSpace,
    AtomType.punct: _thinSpace,
    AtomType.inner: _thinSpace,
  },
  AtomType.spacing: <AtomType, Measurement>{},
};

const Map<AtomType, Map<AtomType, Measurement>> _tightSpacings =
    <AtomType, Map<AtomType, Measurement>>{
  AtomType.ord: <AtomType, Measurement>{
    AtomType.op: _thinSpace,
  },
  AtomType.op: <AtomType, Measurement>{
    AtomType.ord: _thinSpace,
    AtomType.op: _thinSpace,
  },
  AtomType.bin: <AtomType, Measurement>{},
  AtomType.rel: <AtomType, Measurement>{},
  AtomType.open: <AtomType, Measurement>{},
  AtomType.close: <AtomType, Measurement>{
    AtomType.op: _thinSpace,
  },
  AtomType.punct: <AtomType, Measurement>{},
  AtomType.inner: <AtomType, Measurement>{
    AtomType.op: _thinSpace,
  },
  AtomType.spacing: <AtomType, Measurement>{},
};

double getLiteSpacingPx(
  AtomType left,
  AtomType right,
  LiteMathOptions options,
) {
  final table = options.style <= MathStyle.script ? _tightSpacings : _spacings;
  final spacing = table[left]?[right] ??
      Measurement.zero;
  return spacing.toLogicalPx(options);
}
