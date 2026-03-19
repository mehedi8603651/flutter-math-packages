import '../syntax_tree.dart';

/// Pure model for n-ary operators such as `\sum` and `\int`.
class NaryOperatorNodeModel extends SlotableNode<EquationRowNode?> {
  final String operator;
  final EquationRowNode? lowerLimit;
  final EquationRowNode? upperLimit;
  final EquationRowNode naryand;
  final bool? limits;
  final bool allowLargeOp;

  NaryOperatorNodeModel({
    required this.operator,
    required this.lowerLimit,
    required this.upperLimit,
    required this.naryand,
    this.limits,
    this.allowLargeOp = true,
  });

  @override
  List<EquationRowNode?> computeChildren() => <EquationRowNode?>[
        lowerLimit,
        upperLimit,
        naryand,
      ];

  @override
  AtomType get leftType => AtomType.op;

  @override
  AtomType get rightType => naryand.rightType;

  @override
  NaryOperatorNodeModel updateChildren(List<EquationRowNode?> newChildren) =>
      copyWith(
        lowerLimit: newChildren[0],
        upperLimit: newChildren[1],
        naryand: _requireEquationRow(newChildren, 2, 'naryand'),
      );

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'operator': operator,
      if (upperLimit != null) 'upperLimit': upperLimit!.toJson(),
      if (lowerLimit != null) 'lowerLimit': lowerLimit!.toJson(),
      'naryand': naryand.toJson(),
      if (limits != null) 'limits': limits,
      if (!allowLargeOp) 'allowLargeOp': allowLargeOp,
    });

  NaryOperatorNodeModel copyWith({
    String? operator,
    EquationRowNode? lowerLimit,
    EquationRowNode? upperLimit,
    EquationRowNode? naryand,
    bool? limits,
    bool? allowLargeOp,
  }) =>
      NaryOperatorNodeModel(
        operator: operator ?? this.operator,
        lowerLimit: lowerLimit ?? this.lowerLimit,
        upperLimit: upperLimit ?? this.upperLimit,
        naryand: naryand ?? this.naryand,
        limits: limits ?? this.limits,
        allowLargeOp: allowLargeOp ?? this.allowLargeOp,
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
      'NaryOperatorNodeModel requires a non-null $slotName child.',
    );
  }
  return child;
}
