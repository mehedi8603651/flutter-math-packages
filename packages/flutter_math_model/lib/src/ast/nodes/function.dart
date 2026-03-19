import '../syntax_tree.dart';

/// Pure model for a function-like application such as `\sin x`.
class FunctionNodeModel extends SlotableNode<EquationRowNode> {
  final EquationRowNode functionName;
  final EquationRowNode argument;

  FunctionNodeModel({
    required this.functionName,
    required this.argument,
  });

  @override
  List<EquationRowNode> computeChildren() => <EquationRowNode>[
        functionName,
        argument,
      ];

  @override
  AtomType get leftType => AtomType.op;

  @override
  AtomType get rightType => argument.rightType;

  @override
  FunctionNodeModel updateChildren(List<EquationRowNode?> newChildren) =>
      copyWith(
        functionName: _requireEquationRow(newChildren, 0, 'functionName'),
        argument: _requireEquationRow(newChildren, 1, 'argument'),
      );

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'functionName': functionName.toJson(),
      'argument': argument.toJson(),
    });

  FunctionNodeModel copyWith({
    EquationRowNode? functionName,
    EquationRowNode? argument,
  }) =>
      FunctionNodeModel(
        functionName: functionName ?? this.functionName,
        argument: argument ?? this.argument,
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
      'FunctionNodeModel requires a non-null $slotName child.',
    );
  }
  return child;
}
