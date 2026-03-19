import '../syntax_tree.dart';

/// Pure model for postscript and prescript attachment.
class MultiscriptsNodeModel extends SlotableNode<EquationRowNode?> {
  final bool alignPostscripts;
  final EquationRowNode base;
  final EquationRowNode? sub;
  final EquationRowNode? sup;
  final EquationRowNode? presub;
  final EquationRowNode? presup;

  MultiscriptsNodeModel({
    this.alignPostscripts = false,
    required this.base,
    this.sub,
    this.sup,
    this.presub,
    this.presup,
  });

  @override
  List<EquationRowNode?> computeChildren() => <EquationRowNode?>[
        base,
        sub,
        sup,
        presub,
        presup,
      ];

  @override
  AtomType get leftType =>
      presub == null && presup == null ? base.leftType : AtomType.ord;

  @override
  AtomType get rightType =>
      sub == null && sup == null ? base.rightType : AtomType.ord;

  @override
  MultiscriptsNodeModel updateChildren(List<EquationRowNode?> newChildren) =>
      copyWith(
        base: _requireEquationRow(newChildren, 0, 'base'),
        sub: newChildren[1],
        sup: newChildren[2],
        presub: newChildren[3],
        presup: newChildren[4],
      );

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'base': base.toJson(),
      if (sub != null) 'sub': sub?.toJson(),
      if (sup != null) 'sup': sup?.toJson(),
      if (presub != null) 'presub': presub?.toJson(),
      if (presup != null) 'presup': presup?.toJson(),
      if (alignPostscripts) 'alignPostscripts': alignPostscripts,
    });

  MultiscriptsNodeModel copyWith({
    bool? alignPostscripts,
    EquationRowNode? base,
    EquationRowNode? sub,
    EquationRowNode? sup,
    EquationRowNode? presub,
    EquationRowNode? presup,
  }) =>
      MultiscriptsNodeModel(
        alignPostscripts: alignPostscripts ?? this.alignPostscripts,
        base: base ?? this.base,
        sub: sub ?? this.sub,
        sup: sup ?? this.sup,
        presub: presub ?? this.presub,
        presup: presup ?? this.presup,
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
      'MultiscriptsNodeModel requires a non-null $slotName child.',
    );
  }
  return child;
}
