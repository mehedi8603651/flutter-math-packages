import '../syntax_tree.dart';

/// Pure model for accents placed below a base such as `\utilde`.
class AccentUnderNodeModel extends SlotableNode<EquationRowNode> {
  final EquationRowNode base;
  final String label;

  AccentUnderNodeModel({
    required this.base,
    required this.label,
  });

  @override
  List<EquationRowNode> computeChildren() => <EquationRowNode>[base];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  AccentUnderNodeModel updateChildren(List<EquationRowNode?> newChildren) =>
      copyWith(base: _requireEquationRow(newChildren, 0, 'base'));

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'base': base.toJson(),
      'label': label,
    });

  AccentUnderNodeModel copyWith({
    EquationRowNode? base,
    String? label,
  }) =>
      AccentUnderNodeModel(
        base: base ?? this.base,
        label: label ?? this.label,
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
      'AccentUnderNodeModel requires a non-null $slotName child.',
    );
  }
  return child;
}
