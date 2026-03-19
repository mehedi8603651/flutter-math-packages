import '../size.dart';
import '../syntax_tree.dart';
import '../types.dart';

/// Pure model for fixed-size spaces and rule-like boxes.
class SpaceNodeModel extends LeafNode {
  final Measurement height;
  final Measurement width;
  final Measurement depth;
  final Measurement shift;
  final int? breakPenalty;
  final bool fill;
  @override
  final Mode mode;
  final bool alignerOrSpacer;

  SpaceNodeModel({
    required this.height,
    required this.width,
    this.shift = Measurement.zero,
    this.depth = Measurement.zero,
    this.breakPenalty,
    this.fill = false,
    required this.mode,
    this.alignerOrSpacer = false,
  });

  SpaceNodeModel.alignerOrSpacer()
      : height = Measurement.zero,
        width = Measurement.zero,
        shift = Measurement.zero,
        depth = Measurement.zero,
        breakPenalty = null,
        fill = true,
        mode = Mode.math,
        alignerOrSpacer = true;

  @override
  AtomType get leftType => AtomType.spacing;

  @override
  AtomType get rightType => AtomType.spacing;

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'mode': mode.toString(),
      'height': height.toString(),
      'width': width.toString(),
      if (depth != Measurement.zero) 'depth': depth.toString(),
      if (shift != Measurement.zero) 'shift': shift.toString(),
      if (breakPenalty != null) 'breakPenalty': breakPenalty,
      if (fill) 'fill': fill,
      if (alignerOrSpacer) 'alignerOrSpacer': alignerOrSpacer,
    });

  SpaceNodeModel copyWith({
    Measurement? height,
    Measurement? width,
    Measurement? shift,
    Measurement? depth,
    int? breakPenalty,
    bool? fill,
    Mode? mode,
    bool? alignerOrSpacer,
  }) =>
      SpaceNodeModel(
        height: height ?? this.height,
        width: width ?? this.width,
        shift: shift ?? this.shift,
        depth: depth ?? this.depth,
        breakPenalty: breakPenalty ?? this.breakPenalty,
        fill: fill ?? this.fill,
        mode: mode ?? this.mode,
        alignerOrSpacer: alignerOrSpacer ?? this.alignerOrSpacer,
      );
}
