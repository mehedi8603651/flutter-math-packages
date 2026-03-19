import 'package:flutter_math_model/ast.dart' as math_model show StyleNodeModel;

import '../options.dart';
import '../syntax_tree.dart';

/// Node to denote all kinds of style changes.
class StyleNode extends TransparentNode {
  final math_model.StyleNodeModel<GreenNode> _model;

  StyleNode({
    required List<GreenNode> children,
    required OptionsDiff optionsDiff,
  })  : children = children,
        optionsDiff = optionsDiff,
        _model = math_model.StyleNodeModel<GreenNode>(
          children: children,
          optionsDiff: optionsDiff,
        );

  @override
  final List<GreenNode> children;

  /// The difference of [MathOptions].
  final OptionsDiff optionsDiff;

  math_model.StyleNodeModel<GreenNode> get sharedModel => _model;

  @override
  List<MathOptions> computeChildOptions(MathOptions options) =>
      List.filled(children.length, options.merge(optionsDiff), growable: false);

  @override
  bool shouldRebuildWidget(MathOptions oldOptions, MathOptions newOptions) =>
      false;

  @override
  ParentableNode<GreenNode> updateChildren(List<GreenNode> newChildren) =>
      copyWith(children: newChildren);

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll(_model.toJsonWith((child) => child.toJson()));

  StyleNode copyWith({
    List<GreenNode>? children,
    OptionsDiff? optionsDiff,
  }) =>
      StyleNode(
        children: children ?? this.children,
        optionsDiff: optionsDiff ?? this.optionsDiff,
      );
}
