import '../syntax_tree.dart';

/// Pure model for nodes that place content below a base.
class UnderNodeModel extends SlotableNode<EquationRowNode> {
  final EquationRowNode base;
  final EquationRowNode below;

  UnderNodeModel({
    required this.base,
    required this.below,
  });

  @override
  List<EquationRowNode> computeChildren() => <EquationRowNode>[
        base,
        below,
      ];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  UnderNodeModel updateChildren(List<EquationRowNode?> newChildren) => copyWith(
        base: _requireEquationRow(newChildren, 0, 'base'),
        below: _requireEquationRow(newChildren, 1, 'below'),
      );

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'base': base.toJson(),
      'below': below.toJson(),
    });

  UnderNodeModel copyWith({
    EquationRowNode? base,
    EquationRowNode? below,
  }) =>
      UnderNodeModel(
        base: base ?? this.base,
        below: below ?? this.below,
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
      'UnderNodeModel requires a non-null $slotName child.',
    );
  }
  return child;
}
