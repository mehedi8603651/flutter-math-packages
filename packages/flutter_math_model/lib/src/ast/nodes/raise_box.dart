import '../size.dart';
import '../syntax_tree.dart';

/// Pure model for `\raisebox`.
class RaiseBoxNodeModel extends SlotableNode<EquationRowNode> {
  final EquationRowNode body;
  final Measurement dy;

  RaiseBoxNodeModel({
    required this.body,
    required this.dy,
  });

  @override
  List<EquationRowNode> computeChildren() => <EquationRowNode>[body];

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  RaiseBoxNodeModel updateChildren(List<EquationRowNode?> newChildren) =>
      copyWith(body: _requireEquationRow(newChildren, 0, 'body'));

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'body': body.toJson(),
      'dy': dy.toString(),
    });

  RaiseBoxNodeModel copyWith({
    EquationRowNode? body,
    Measurement? dy,
  }) =>
      RaiseBoxNodeModel(
        body: body ?? this.body,
        dy: dy ?? this.dy,
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
      'RaiseBoxNodeModel requires a non-null $slotName child.',
    );
  }
  return child;
}
