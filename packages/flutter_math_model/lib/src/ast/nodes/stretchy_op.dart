import '../syntax_tree.dart';

/// Pure model for stretchy operators such as `\xrightarrow`.
class StretchyOpNodeModel extends SlotableNode<EquationRowNode?> {
  final String symbol;
  final EquationRowNode? above;
  final EquationRowNode? below;

  StretchyOpNodeModel({
    required this.above,
    required this.below,
    required this.symbol,
  }) : assert(above != null || below != null);

  @override
  List<EquationRowNode?> computeChildren() => <EquationRowNode?>[
        above,
        below,
      ];

  @override
  AtomType get leftType => AtomType.rel;

  @override
  AtomType get rightType => AtomType.rel;

  @override
  StretchyOpNodeModel updateChildren(List<EquationRowNode?> newChildren) =>
      copyWith(
        above: newChildren[0],
        below: newChildren[1],
      );

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'symbol': symbol,
      if (above != null) 'above': above!.toJson(),
      if (below != null) 'below': below!.toJson(),
    });

  StretchyOpNodeModel copyWith({
    String? symbol,
    EquationRowNode? above,
    EquationRowNode? below,
  }) =>
      StretchyOpNodeModel(
        symbol: symbol ?? this.symbol,
        above: above ?? this.above,
        below: below ?? this.below,
      );
}
