import '../syntax_tree.dart';

/// Pure model for nodes that place content above a base.
class OverNodeModel extends SlotableNode<EquationRowNode> {
  final EquationRowNode base;
  final EquationRowNode above;
  final bool stackRel;

  OverNodeModel({
    required this.base,
    required this.above,
    this.stackRel = false,
  });

  @override
  List<EquationRowNode> computeChildren() => <EquationRowNode>[
        base,
        above,
      ];

  @override
  AtomType get leftType => stackRel ? AtomType.rel : AtomType.ord;

  @override
  AtomType get rightType => stackRel ? AtomType.rel : AtomType.ord;

  @override
  OverNodeModel updateChildren(List<EquationRowNode?> newChildren) => copyWith(
        base: _requireEquationRow(newChildren, 0, 'base'),
        above: _requireEquationRow(newChildren, 1, 'above'),
      );

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'base': base.toJson(),
      'above': above.toJson(),
      if (stackRel) 'stackRel': stackRel,
    });

  OverNodeModel copyWith({
    EquationRowNode? base,
    EquationRowNode? above,
    bool? stackRel,
  }) =>
      OverNodeModel(
        base: base ?? this.base,
        above: above ?? this.above,
        stackRel: stackRel ?? this.stackRel,
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
      'OverNodeModel requires a non-null $slotName child.',
    );
  }
  return child;
}
