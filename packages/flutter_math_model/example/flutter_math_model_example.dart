import 'package:flutter_math_model/flutter_math_model.dart';

void main() {
  final tree = SyntaxTree(
    greenRoot: EquationRowNode(
      children: [
        _TokenNode('x'),
        _TokenNode('+', type: AtomType.bin),
        _TokenNode('1'),
      ],
    ),
  );

  print(
    '$flutterMathModelPackageName: '
    '${tree.greenRoot.flattenedChildList.map((node) => node.toJson()).toList()}',
  );
}

final class _TokenNode extends LeafNode {
  final String value;
  final AtomType type;

  _TokenNode(this.value, {this.type = AtomType.ord});

  @override
  Mode get mode => Mode.math;

  @override
  AtomType get leftType => type;

  @override
  AtomType get rightType => type;

  @override
  Map<String, Object?> toJson() => super.toJson()..['value'] = value;
}
