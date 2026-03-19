import 'package:flutter_math_model/ast.dart' as math_model
    show AtomType, EquationRowNode, MathColor, Measurement, SlotableNode;

/// UnicodeMath-side enclosure node for future parser work.
class EnclosureNode
    extends math_model.SlotableNode<math_model.EquationRowNode> {
  final math_model.EquationRowNode base;
  final bool hasBorder;
  final math_model.MathColor? bordercolor;
  final math_model.MathColor? backgroundcolor;
  final List<String> notation;
  final math_model.Measurement horizontalPadding;
  final math_model.Measurement verticalPadding;

  EnclosureNode({
    required this.base,
    required this.hasBorder,
    this.bordercolor,
    this.backgroundcolor,
    this.notation = const <String>[],
    this.horizontalPadding = math_model.Measurement.zero,
    this.verticalPadding = math_model.Measurement.zero,
  });

  @override
  List<math_model.EquationRowNode> computeChildren() =>
      <math_model.EquationRowNode>[base];

  @override
  math_model.AtomType get leftType => math_model.AtomType.ord;

  @override
  math_model.AtomType get rightType => math_model.AtomType.ord;

  @override
  EnclosureNode updateChildren(
    covariant List<math_model.EquationRowNode?> newChildren,
  ) {
    final updatedBase = newChildren.first;
    if (updatedBase == null) {
      throw ArgumentError.value(
        newChildren,
        'children',
        'EnclosureNode requires a non-null base child.',
      );
    }
    return copyWith(base: updatedBase);
  }

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'base': base.toJson(),
      'hasBorder': hasBorder,
      if (bordercolor != null) 'bordercolor': bordercolor.toString(),
      if (backgroundcolor != null)
        'backgroundcolor': backgroundcolor.toString(),
      if (notation.isNotEmpty) 'notation': notation,
      if (horizontalPadding != math_model.Measurement.zero)
        'horizontalPadding': horizontalPadding.toString(),
      if (verticalPadding != math_model.Measurement.zero)
        'verticalPadding': verticalPadding.toString(),
    });

  EnclosureNode copyWith({
    math_model.EquationRowNode? base,
    bool? hasBorder,
    math_model.MathColor? bordercolor,
    math_model.MathColor? backgroundcolor,
    List<String>? notation,
    math_model.Measurement? horizontalPadding,
    math_model.Measurement? verticalPadding,
  }) =>
      EnclosureNode(
        base: base ?? this.base,
        hasBorder: hasBorder ?? this.hasBorder,
        bordercolor: bordercolor ?? this.bordercolor,
        backgroundcolor: backgroundcolor ?? this.backgroundcolor,
        notation: notation ?? this.notation,
        horizontalPadding: horizontalPadding ?? this.horizontalPadding,
        verticalPadding: verticalPadding ?? this.verticalPadding,
      );
}
