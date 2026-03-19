import '../syntax_tree.dart';

/// Pure model for accents such as `\hat`.
class AccentNodeModel extends SlotableNode<EquationRowNode> {
  final EquationRowNode base;
  final String label;
  final bool isStretchy;
  final bool isShifty;

  AccentNodeModel({
    required this.base,
    required this.label,
    required this.isStretchy,
    required this.isShifty,
  });

  @override
  List<EquationRowNode> computeChildren() => <EquationRowNode>[base];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  AccentNodeModel updateChildren(List<EquationRowNode?> newChildren) =>
      copyWith(base: _requireEquationRow(newChildren, 0, 'base'));

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'base': base.toJson(),
      'label': label,
      'isStretchy': isStretchy,
      'isShifty': isShifty,
    });

  AccentNodeModel copyWith({
    EquationRowNode? base,
    String? label,
    bool? isStretchy,
    bool? isShifty,
  }) =>
      AccentNodeModel(
        base: base ?? this.base,
        label: label ?? this.label,
        isStretchy: isStretchy ?? this.isStretchy,
        isShifty: isShifty ?? this.isShifty,
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
      'AccentNodeModel requires a non-null $slotName child.',
    );
  }
  return child;
}
