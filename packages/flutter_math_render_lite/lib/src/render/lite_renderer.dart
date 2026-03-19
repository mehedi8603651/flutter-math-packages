import 'package:flutter/widgets.dart';
import 'package:flutter_math_model/ast.dart';

import '../ast/nodes/symbol.dart';
import '../lite_math_options.dart';
import 'lite_build_result.dart';
import 'lite_measurement.dart';
import 'lite_spacing.dart';
import 'widgets/lite_accent.dart';
import 'widgets/lite_equation_array.dart';
import 'widgets/lite_delimited.dart';
import 'widgets/lite_fraction.dart';
import 'widgets/lite_line.dart';
import 'widgets/lite_matrix.dart';
import 'widgets/lite_scripts.dart';
import 'widgets/lite_sqrt.dart';
import 'widgets/lite_symbol.dart';
import 'widgets/lite_under_over.dart';

class LiteSyntaxTreeView extends StatelessWidget {
  const LiteSyntaxTreeView({
    super.key,
    required this.syntaxTree,
    this.options = LiteMathOptions.textOptions,
  });

  final SyntaxTree syntaxTree;
  final LiteMathOptions options;

  @override
  Widget build(BuildContext context) {
    return buildLiteSyntaxTree(
      syntaxTree: syntaxTree,
      options: options,
    ).widget;
  }
}

LiteBuildResult buildLiteSyntaxTree({
  required SyntaxTree syntaxTree,
  LiteMathOptions options = LiteMathOptions.textOptions,
}) {
  return buildLiteNode(
    node: syntaxTree.greenRoot,
    options: options,
  );
}

LiteBuildResult buildLiteNode({
  required GreenNode node,
  LiteMathOptions options = LiteMathOptions.textOptions,
}) {
  if (node is EquationRowNode) {
    return _buildEquationRow(node, options);
  }
  if (node is StyleNode) {
    return _buildRowChildren(
      _expandLiteRowChildren(node.children),
      options.merge(node.optionsDiff),
    );
  }
  if (node is TransparentNode) {
    return _buildRowChildren(_expandLiteRowChildren(node.children), options);
  }
  if (node is LiteSymbolNode) {
    return buildLiteSymbol(
      symbol: node.symbol,
      options: options,
      mode: node.mode,
      overrideFont: node.overrideFont,
    );
  }
  if (node is AccentNodeModel) {
    return LiteBuildResult(
      widget: LiteAccent(
        base: buildLiteNode(
          node: node.base,
          options: options,
        ).widget,
        label: node.label,
        options: options,
        stretchy: node.isStretchy,
      ),
      options: options,
    );
  }
  if (node is AccentUnderNodeModel) {
    return LiteBuildResult(
      widget: LiteAccent(
        base: buildLiteNode(
          node: node.base,
          options: options,
        ).widget,
        label: node.label,
        options: options,
        below: true,
      ),
      options: options,
    );
  }
  if (node is FracNodeModel) {
    final numeratorOptions = options.forChildStyle(options.style.fracNum());
    final denominatorOptions = options.forChildStyle(options.style.fracDen());
    return LiteBuildResult(
      widget: LiteFraction(
        numerator: buildLiteNode(
          node: node.numerator,
          options: numeratorOptions,
        ).widget,
        denominator: buildLiteNode(
          node: node.denominator,
          options: denominatorOptions,
        ).widget,
        options: options,
        barThickness: node.barSize?.toLogicalPx(options),
      ),
      options: options,
    );
  }
  if (node is FunctionNodeModel) {
    return LiteBuildResult(
      widget: LiteLine(
        children: <Widget>[
          buildLiteNode(
            node: node.functionName,
            options: options,
          ).widget,
          SizedBox(width: options.fontSize * 0.12),
          buildLiteNode(
            node: node.argument,
            options: options,
          ).widget,
        ],
      ),
      options: options,
    );
  }
  if (node is NaryOperatorNodeModel) {
    final decorationOptions = options.forChildStyle(MathStyle.script);
    final operatorWidget = LiteSymbol(
      symbol: node.operator,
      options: options.copyWith(
        fontSize: options.fontSize * (node.allowLargeOp ? 1.25 : 1.0),
      ),
    );
    final operatorWithLimits = node.limits == false
        ? LiteScripts(
            base: operatorWidget,
            sup: node.upperLimit == null
                ? null
                : buildLiteNode(
                    node: node.upperLimit!,
                    options: decorationOptions,
                  ).widget,
            sub: node.lowerLimit == null
                ? null
                : buildLiteNode(
                    node: node.lowerLimit!,
                    options: decorationOptions,
                  ).widget,
            baseGap: options.fontSize * 0.06,
            scriptGap: options.fontSize * 0.04,
          )
        : LiteUnderOver(
            above: node.upperLimit == null
                ? null
                : buildLiteNode(
                    node: node.upperLimit!,
                    options: decorationOptions,
                  ).widget,
            base: operatorWidget,
            below: node.lowerLimit == null
                ? null
                : buildLiteNode(
                    node: node.lowerLimit!,
                    options: decorationOptions,
                  ).widget,
            gap: options.fontSize * 0.06,
          );
    return LiteBuildResult(
      widget: LiteLine(
        children: <Widget>[
          operatorWithLimits,
          SizedBox(width: options.fontSize * 0.12),
          buildLiteNode(
            node: node.naryand,
            options: options,
          ).widget,
        ],
      ),
      options: options,
    );
  }
  if (node is MultiscriptsNodeModel) {
    final scriptOptions = options.forChildStyle(MathStyle.script);
    return LiteBuildResult(
      widget: LiteScripts(
        base: buildLiteNode(
          node: node.base,
          options: options,
        ).widget,
        presup: node.presup == null
            ? null
            : buildLiteNode(
                node: node.presup!,
                options: scriptOptions,
              ).widget,
        presub: node.presub == null
            ? null
            : buildLiteNode(
                node: node.presub!,
                options: scriptOptions,
              ).widget,
        sup: node.sup == null
            ? null
            : buildLiteNode(
                node: node.sup!,
                options: scriptOptions,
              ).widget,
        sub: node.sub == null
            ? null
            : buildLiteNode(
                node: node.sub!,
                options: scriptOptions,
              ).widget,
        baseGap: options.fontSize * 0.08,
        scriptGap: options.fontSize * 0.04,
      ),
      options: options,
    );
  }
  if (node is SqrtNodeModel) {
    final radicandOptions = options.forChildStyle(options.style.cramp());
    final indexOptions = options.forChildStyle(MathStyle.scriptscript);
    return LiteBuildResult(
      widget: LiteSqrt(
        radicand: buildLiteNode(
          node: node.base,
          options: radicandOptions,
        ).widget,
        index: node.index == null
            ? null
            : buildLiteNode(
                node: node.index!,
                options: indexOptions,
              ).widget,
        options: options,
      ),
      options: options,
    );
  }
  if (node is OverNodeModel) {
    final decorationOptions = options.forChildStyle(MathStyle.script);
    return LiteBuildResult(
      widget: LiteUnderOver(
        above: buildLiteNode(
          node: node.above,
          options: decorationOptions,
        ).widget,
        base: buildLiteNode(
          node: node.base,
          options: options,
        ).widget,
        gap: options.fontSize * 0.08,
      ),
      options: options,
    );
  }
  if (node is UnderNodeModel) {
    final decorationOptions = options.forChildStyle(MathStyle.script);
    return LiteBuildResult(
      widget: LiteUnderOver(
        base: buildLiteNode(
          node: node.base,
          options: options,
        ).widget,
        below: buildLiteNode(
          node: node.below,
          options: decorationOptions,
        ).widget,
        gap: options.fontSize * 0.08,
      ),
      options: options,
    );
  }
  if (node is StretchyOpNodeModel) {
    final decorationOptions = options.forChildStyle(MathStyle.script);
    return LiteBuildResult(
      widget: LiteUnderOver(
        above: node.above == null
            ? null
            : buildLiteNode(
                node: node.above!,
                options: decorationOptions,
              ).widget,
        base: LiteSymbol(
          symbol: node.symbol,
          options: options.copyWith(fontSize: options.fontSize * 1.1),
        ),
        below: node.below == null
            ? null
            : buildLiteNode(
                node: node.below!,
                options: decorationOptions,
              ).widget,
        gap: options.fontSize * 0.08,
      ),
      options: options,
    );
  }
  if (node is LeftRightNodeModel) {
    return LiteBuildResult(
      widget: LiteDelimited(
        leftDelimiter: node.leftDelim,
        rightDelimiter: node.rightDelim,
        middleDelimiters: node.middle,
        body: node.body
            .map(
              (part) => buildLiteNode(
                node: part,
                options: options,
              ).widget,
            )
            .toList(growable: false),
        options: options,
      ),
      options: options,
    );
  }
  if (node is RaiseBoxNodeModel) {
    return LiteBuildResult(
      widget: Transform.translate(
        offset: Offset(0, -node.dy.toLogicalPx(options)),
        child: buildLiteNode(
          node: node.body,
          options: options,
        ).widget,
      ),
      options: options,
    );
  }
  if (node is PhantomNodeModel) {
    final hidden = Opacity(
      opacity: 0,
      child: buildLiteNode(
        node: node.phantomChild,
        options: options,
      ).widget,
    );

    Widget widget = hidden;
    if (node.zeroWidth) {
      widget = Align(
        widthFactor: 0,
        alignment: Alignment.centerLeft,
        child: widget,
      );
    }
    if (node.zeroHeight || node.zeroDepth) {
      widget = Align(
        heightFactor: 0,
        alignment: Alignment.topLeft,
        child: widget,
      );
    }

    return LiteBuildResult(
      widget: widget,
      options: options,
    );
  }
  if (node is EquationArrayNodeModel) {
    return LiteBuildResult(
      widget: LiteEquationArray(
        rows: node.body
            .map(
              (row) => buildLiteNode(
                node: row,
                options: options,
              ).widget,
            )
            .toList(growable: false),
        options: options,
        hlines: node.hlines,
        rowSpacings: node.rowSpacings
            .map((spacing) => spacing.toLogicalPx(options))
            .toList(growable: false),
        addJot: node.addJot,
        arrayStretch: node.arrayStretch,
      ),
      options: options,
    );
  }
  if (node is MatrixNodeModel) {
    return LiteBuildResult(
      widget: LiteMatrix(
        body: node.body
            .map(
              (row) => row
                  .map(
                    (cell) => cell == null
                        ? null
                        : buildLiteNode(
                            node: cell,
                            options: options,
                          ).widget,
                  )
                  .toList(growable: false),
            )
            .toList(growable: false),
        options: options,
        columnAligns: node.columnAligns,
        vLines: node.vLines,
        hLines: node.hLines,
        rowSpacings: node.rowSpacings
            .map((spacing) => spacing.toLogicalPx(options))
            .toList(growable: false),
        isSmall: node.isSmall,
        hskipBeforeAndAfter: node.hskipBeforeAndAfter,
      ),
      options: options,
    );
  }
  if (node is SpaceNodeModel) {
    return LiteBuildResult(
      widget: _buildSpace(node, options),
      options: options,
    );
  }

  throw UnsupportedError(
    'flutter_math_render_lite does not support ${node.runtimeType} yet.',
  );
}

extension LiteSyntaxTreeRenderExt on SyntaxTree {
  Widget buildLiteWidget([
    LiteMathOptions options = LiteMathOptions.textOptions,
  ]) {
    return buildLiteSyntaxTree(
      syntaxTree: this,
      options: options,
    ).widget;
  }
}

LiteBuildResult _buildEquationRow(
  EquationRowNode node,
  LiteMathOptions options,
) {
  return _buildRowChildren(_expandLiteRowChildren(node.children), options);
}

LiteBuildResult _buildRowChildren(
  List<GreenNode> children,
  LiteMathOptions options,
) {
  final renderedChildren = <Widget>[];
  GreenNode? previousNonSpace;

  for (final child in children) {
    if (child.leftType != AtomType.spacing && previousNonSpace != null) {
      final spacing = getLiteSpacingPx(
        previousNonSpace.rightType,
        child.leftType,
        options,
      );
      if (spacing > 0) {
        renderedChildren.add(SizedBox(width: spacing));
      }
    }

    final built = buildLiteNode(node: child, options: options);
    renderedChildren.add(built.widget);

    if (child.leftType != AtomType.spacing &&
        child.rightType != AtomType.spacing) {
      previousNonSpace = child;
    }
  }

  return LiteBuildResult(
    widget: LiteLine(children: renderedChildren),
    options: options,
  );
}

Widget _buildSpace(SpaceNodeModel node, LiteMathOptions options) {
  if (node.fill || node.alignerOrSpacer) {
    return const SizedBox.shrink();
  }

  final width = node.width.toLogicalPx(options);
  final height = node.height.toLogicalPx(options);
  final depth = node.depth.toLogicalPx(options);
  final shift = node.shift.toLogicalPx(options);

  Widget widget = SizedBox(
    width: width,
    height: height + depth,
  );

  if (shift != 0) {
    widget = Transform.translate(
      offset: Offset(0, -shift),
      child: widget,
    );
  }

  return widget;
}

List<GreenNode> _expandLiteRowChildren(Iterable<GreenNode> children) {
  final expanded = <GreenNode>[];
  for (final child in children) {
    if (child is StyleNode) {
      expanded.add(child);
      continue;
    }
    if (child is TransparentNode) {
      expanded.addAll(_expandLiteRowChildren(child.children));
      continue;
    }
    expanded.add(child);
  }
  return expanded;
}
