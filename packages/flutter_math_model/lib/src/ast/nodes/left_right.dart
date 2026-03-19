import '../syntax_tree.dart';

/// Pure model for paired delimiters with optional middle delimiters.
class LeftRightNodeModel extends SlotableNode<EquationRowNode> {
  final String? leftDelim;
  final String? rightDelim;
  final List<EquationRowNode> body;
  final List<String?> middle;

  LeftRightNodeModel({
    required this.leftDelim,
    required this.rightDelim,
    required List<EquationRowNode> body,
    List<String?> middle = const <String?>[],
  })  : assert(body.isNotEmpty),
        assert(middle.length == body.length - 1),
        body = List<EquationRowNode>.unmodifiable(body),
        middle = List<String?>.unmodifiable(middle);

  @override
  List<EquationRowNode> computeChildren() => body;

  @override
  AtomType get leftType => AtomType.open;

  @override
  AtomType get rightType => AtomType.close;

  @override
  LeftRightNodeModel updateChildren(List<EquationRowNode?> newChildren) =>
      copyWith(
        body: newChildren.map((child) {
          if (child == null) {
            throw ArgumentError.value(
              newChildren,
              'children',
              'LeftRightNodeModel body children must be non-null.',
            );
          }
          return child;
        }).toList(growable: false),
      );

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'body': body.map((child) => child.toJson()).toList(growable: false),
      'leftDelim': leftDelim,
      'rightDelim': rightDelim,
      if (middle.isNotEmpty) 'middle': middle,
    });

  LeftRightNodeModel copyWith({
    String? leftDelim,
    String? rightDelim,
    List<EquationRowNode>? body,
    List<String?>? middle,
  }) =>
      LeftRightNodeModel(
        leftDelim: leftDelim ?? this.leftDelim,
        rightDelim: rightDelim ?? this.rightDelim,
        body: body ?? this.body,
        middle: middle ?? this.middle,
      );
}
