import '../size.dart';
import '../syntax_tree.dart';
import 'matrix.dart';

/// Pure model for equation arrays with alignment metadata.
class EquationArrayNodeModel extends SlotableNode<EquationRowNode> {
  final double arrayStretch;
  final bool addJot;
  final List<EquationRowNode> body;
  final List<MatrixSeparatorStyle> hlines;
  final List<Measurement> rowSpacings;

  EquationArrayNodeModel({
    this.addJot = false,
    required List<EquationRowNode> body,
    this.arrayStretch = 1.0,
    List<MatrixSeparatorStyle>? hlines,
    List<Measurement>? rowSpacings,
  })  : body = List<EquationRowNode>.unmodifiable(body),
        hlines = List<MatrixSeparatorStyle>.unmodifiable(
          _extendToByFill(
            hlines ?? const <MatrixSeparatorStyle>[],
            body.length + 1,
            MatrixSeparatorStyle.none,
          ),
        ),
        rowSpacings = List<Measurement>.unmodifiable(
          _extendToByFill(
            rowSpacings ?? const <Measurement>[],
            body.length,
            Measurement.zero,
          ),
        );

  @override
  List<EquationRowNode> computeChildren() => body;

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  EquationArrayNodeModel updateChildren(List<EquationRowNode?> newChildren) =>
      copyWith(
        body: newChildren.map((child) {
          if (child == null) {
            throw ArgumentError.value(
              newChildren,
              'children',
              'EquationArrayNodeModel body children must be non-null.',
            );
          }
          return child;
        }).toList(growable: false),
      );

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      if (addJot) 'addJot': addJot,
      'body': body.map((row) => row.toJson()).toList(growable: false),
      if (arrayStretch != 1.0) 'arrayStretch': arrayStretch,
      'hlines': hlines.map((line) => line.toString()).toList(growable: false),
      'rowSpacings': rowSpacings
          .map((spacing) => spacing.toString())
          .toList(growable: false),
    });

  EquationArrayNodeModel copyWith({
    double? arrayStretch,
    bool? addJot,
    List<EquationRowNode>? body,
    List<MatrixSeparatorStyle>? hlines,
    List<Measurement>? rowSpacings,
  }) =>
      EquationArrayNodeModel(
        arrayStretch: arrayStretch ?? this.arrayStretch,
        addJot: addJot ?? this.addJot,
        body: body ?? this.body,
        hlines: hlines ?? this.hlines,
        rowSpacings: rowSpacings ?? this.rowSpacings,
      );
}

List<T> _extendToByFill<T>(List<T> list, int desiredLength, T fill) =>
    list.length >= desiredLength
        ? List<T>.from(list, growable: false)
        : List<T>.generate(
            desiredLength,
            (index) => index < list.length ? list[index] : fill,
            growable: false,
          );
