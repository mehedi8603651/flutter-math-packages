import 'package:flutter_math_model/flutter_math_model.dart';

void main() {
  final tree = SyntaxTree(
    greenRoot: EquationRowNode(
      children: [
        _TokenNode('S'),
        _TokenNode('=', type: AtomType.rel),
        FracNodeModel(
          numerator: EquationRowNode(children: [_TokenNode('1')]),
          denominator: EquationRowNode(
            children: [
              _TokenNode('n'),
              _TokenNode('+', type: AtomType.bin),
              _TokenNode('1'),
            ],
          ),
        ),
      ],
    ),
  );

  print(flutterMathModelPackageName);
  print('Root node: ${tree.greenRoot.runtimeType}');
  print('Flattened child count: ${tree.greenRoot.flattenedChildList.length}');
  print('Tree JSON: ${tree.greenRoot.toJson()}');
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
