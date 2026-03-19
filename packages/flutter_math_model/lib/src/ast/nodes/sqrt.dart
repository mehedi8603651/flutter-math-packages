import '../syntax_tree.dart';

/// Pure model for square-root and root nodes.
class SqrtNodeModel extends SlotableNode<EquationRowNode?> {
  final EquationRowNode? index;
  final EquationRowNode base;

  SqrtNodeModel({
    required this.index,
    required this.base,
  });

  @override
  List<EquationRowNode?> computeChildren() => <EquationRowNode?>[
        index,
        base,
      ];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  SqrtNodeModel updateChildren(List<EquationRowNode?> newChildren) => copyWith(
        index: newChildren[0],
        base: _requireEquationRow(newChildren, 1, 'base'),
      );

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'index': index?.toJson(),
      'base': base.toJson(),
    });

  SqrtNodeModel copyWith({
    EquationRowNode? index,
    EquationRowNode? base,
  }) =>
      SqrtNodeModel(
        index: index ?? this.index,
        base: base ?? this.base,
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
      'SqrtNodeModel requires a non-null $slotName child.',
    );
  }
  return child;
}
