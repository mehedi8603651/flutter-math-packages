import '../size.dart';
import '../syntax_tree.dart';

/// Pure model for fractions such as `\frac`.
class FracNodeModel extends SlotableNode<EquationRowNode> {
  final EquationRowNode numerator;
  final EquationRowNode denominator;
  final Measurement? barSize;
  final bool continued;

  FracNodeModel({
    required this.numerator,
    required this.denominator,
    this.barSize,
    this.continued = false,
  });

  @override
  List<EquationRowNode> computeChildren() => <EquationRowNode>[
        numerator,
        denominator,
      ];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  FracNodeModel updateChildren(List<EquationRowNode?> newChildren) => copyWith(
        numerator: _requireEquationRow(newChildren, 0, 'numerator'),
        denominator: _requireEquationRow(newChildren, 1, 'denominator'),
      );

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'numerator': numerator.toJson(),
      'denominator': denominator.toJson(),
      if (barSize != null) 'barSize': barSize.toString(),
      if (continued) 'continued': continued,
    });

  FracNodeModel copyWith({
    EquationRowNode? numerator,
    EquationRowNode? denominator,
    Measurement? barSize,
    bool? continued,
  }) =>
      FracNodeModel(
        numerator: numerator ?? this.numerator,
        denominator: denominator ?? this.denominator,
        barSize: barSize ?? this.barSize,
        continued: continued ?? this.continued,
      );
}

EquationRowNode _requireEquationRow(
  List<EquationRowNode?> children,
  int index,
  String slotName,
) {
  final child = children[index];
  if (child == null) {
    throw ArgumentError.value(
      children,
      'children',
      'FracNodeModel requires a non-null $slotName child.',
    );
  }
  return child;
}
