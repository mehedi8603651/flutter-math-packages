import '../syntax_tree.dart';
import '../types.dart';

/// Pure model for phantom nodes that preserve another node's dimensions.
class PhantomNodeModel extends LeafNode {
  final EquationRowNode phantomChild;
  final bool zeroWidth;
  final bool zeroHeight;
  final bool zeroDepth;

  PhantomNodeModel({
    required this.phantomChild,
    this.zeroWidth = false,
    this.zeroHeight = false,
    this.zeroDepth = false,
  });

  @override
  Mode get mode => Mode.math;

  @override
  AtomType get leftType => phantomChild.leftType;

  @override
  AtomType get rightType => phantomChild.rightType;

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'phantomChild': phantomChild.toJson(),
      if (zeroWidth) 'zeroWidth': zeroWidth,
      if (zeroHeight) 'zeroHeight': zeroHeight,
      if (zeroDepth) 'zeroDepth': zeroDepth,
    });

  PhantomNodeModel copyWith({
    EquationRowNode? phantomChild,
    bool? zeroWidth,
    bool? zeroHeight,
    bool? zeroDepth,
  }) =>
      PhantomNodeModel(
        phantomChild: phantomChild ?? this.phantomChild,
        zeroWidth: zeroWidth ?? this.zeroWidth,
        zeroHeight: zeroHeight ?? this.zeroHeight,
        zeroDepth: zeroDepth ?? this.zeroDepth,
      );
}
