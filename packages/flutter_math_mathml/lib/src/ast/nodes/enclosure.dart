import 'package:flutter_math_model/ast.dart';

/// Pure MathML-facing enclosure node for `<menclose>`.
class EnclosureNode extends SlotableNode<EquationRowNode> {
  final EquationRowNode base;
  final bool hasBorder;
  final MathColor? borderColor;
  final MathColor? backgroundColor;
  final List<String> notation;
  final Measurement horizontalPadding;
  final Measurement verticalPadding;

  EnclosureNode({
    required this.base,
    required this.hasBorder,
    this.borderColor,
    this.backgroundColor,
    this.notation = const <String>[],
    this.horizontalPadding = Measurement.zero,
    this.verticalPadding = Measurement.zero,
  });

  @override
  List<EquationRowNode> computeChildren() => <EquationRowNode>[base];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  EnclosureNode updateChildren(List<EquationRowNode?> newChildren) {
    final child = newChildren[0];
    if (child == null) {
      throw ArgumentError.value(
        newChildren,
        'children',
        'EnclosureNode requires a non-null base child.',
      );
    }
    return copyWith(base: child);
  }

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'base': base.toJson(),
      'hasBorder': hasBorder,
      if (borderColor != null) 'borderColor': borderColor.toString(),
      if (backgroundColor != null) 'backgroundColor': backgroundColor.toString(),
      if (notation.isNotEmpty) 'notation': notation,
      if (horizontalPadding != Measurement.zero)
        'horizontalPadding': horizontalPadding.toString(),
      if (verticalPadding != Measurement.zero)
        'verticalPadding': verticalPadding.toString(),
    });

  EnclosureNode copyWith({
    EquationRowNode? base,
    bool? hasBorder,
    MathColor? borderColor,
    MathColor? backgroundColor,
    List<String>? notation,
    Measurement? horizontalPadding,
    Measurement? verticalPadding,
  }) =>
      EnclosureNode(
        base: base ?? this.base,
        hasBorder: hasBorder ?? this.hasBorder,
        borderColor: borderColor ?? this.borderColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        notation: notation ?? this.notation,
        horizontalPadding: horizontalPadding ?? this.horizontalPadding,
        verticalPadding: verticalPadding ?? this.verticalPadding,
      );
}
