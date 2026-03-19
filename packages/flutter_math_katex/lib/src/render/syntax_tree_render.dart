part of '../ast/syntax_tree.dart';

mixin _RenderableNode {
  /// Calculate the options passed to children when given [options] from parent.
  List<MathOptions> computeChildOptions(MathOptions options);

  /// Compose a Flutter widget with child widgets already built.
  BuildResult buildWidget(
    MathOptions options,
    List<BuildResult?> childBuildResults,
  );

  /// Whether this node needs to rebuild when options change.
  bool shouldRebuildWidget(MathOptions oldOptions, MathOptions newOptions);

  MathOptions? _oldOptions;
  BuildResult? _oldBuildResult;
  List<BuildResult?>? _oldChildBuildResults;
}

extension SyntaxTreeRenderExt on SyntaxTree {
  /// Build the widget tree for this AST.
  Widget buildWidget(MathOptions options) => root.buildWidget(options).widget;
}

extension SyntaxNodeRenderExt on SyntaxNode {
  /// Build the widget tree rooted at this syntax node.
  BuildResult buildWidget(MathOptions options) {
    if (value is PositionDependentMixin) {
      (value as PositionDependentMixin).updatePos(pos);
    }

    if (value._oldOptions != null && options == value._oldOptions) {
      return value._oldBuildResult!;
    }

    final childOptions = value.computeChildOptions(options);
    final newChildBuildResults = _buildChildWidgets(childOptions);

    final bypassRebuild = value._oldOptions != null &&
        !value.shouldRebuildWidget(value._oldOptions!, options) &&
        listEquals(newChildBuildResults, value._oldChildBuildResults);

    value._oldOptions = options;
    value._oldChildBuildResults = newChildBuildResults;

    return bypassRebuild
        ? value._oldBuildResult!
        : (value._oldBuildResult =
            value.buildWidget(options, newChildBuildResults));
  }

  List<BuildResult?> _buildChildWidgets(List<MathOptions> childOptions) {
    assert(children.length == childOptions.length);
    if (children.isEmpty) {
      return const <BuildResult?>[];
    }
    return List<BuildResult?>.generate(
      children.length,
      (index) => children[index]?.buildWidget(childOptions[index]),
      growable: false,
    );
  }
}

mixin _TransparentNodeRendering {
  BuildResult buildWidget(
    MathOptions options,
    List<BuildResult?> childBuildResults,
  ) =>
      BuildResult(
        widget: const Text(
          'This widget should not appear. '
          'It means one of FlutterMath\'s AST nodes '
          'forgot to handle the case for TransparentNodes',
        ),
        options: options,
        results: childBuildResults
            .expand((result) => result!.results ?? <BuildResult>[result])
            .toList(growable: false),
      );
}

mixin _TemporaryNodeRendering {
  BuildResult buildWidget(
    MathOptions options,
    List<BuildResult?> childBuildResults,
  ) =>
      throw UnsupportedError('Temporary node $runtimeType encountered.');

  bool shouldRebuildWidget(MathOptions oldOptions, MathOptions newOptions) =>
      throw UnsupportedError('Temporary node $runtimeType encountered.');

  int get editingWidth =>
      throw UnsupportedError('Temporary node $runtimeType encountered.');

  AtomType get leftType =>
      throw UnsupportedError('Temporary node $runtimeType encountered.');

  AtomType get rightType =>
      throw UnsupportedError('Temporary node $runtimeType encountered.');
}
