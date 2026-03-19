import 'package:flutter_math_katex/ast.dart' as katex_ast;
import 'package:flutter_math_tex/flutter_math_tex.dart' as tex_ast;

katex_ast.SyntaxTree toKatexSyntaxTree(tex_ast.SyntaxTree tree) =>
    katex_ast.SyntaxTree(
      greenRoot: toKatexGreenNode(tree.greenRoot) as katex_ast.EquationRowNode,
    );

tex_ast.SyntaxTree toTexSyntaxTree(katex_ast.SyntaxTree tree) =>
    tex_ast.SyntaxTree(
      greenRoot: toTexGreenNode(tree.greenRoot) as tex_ast.EquationRowNode,
    );

List<katex_ast.GreenNode> toKatexGreenNodes(Iterable<tex_ast.GreenNode> nodes) =>
    nodes.map(toKatexGreenNode).toList(growable: false);

List<tex_ast.GreenNode> toTexGreenNodes(Iterable<katex_ast.GreenNode> nodes) =>
    nodes.map(toTexGreenNode).toList(growable: false);

katex_ast.GreenNode toKatexGreenNode(tex_ast.GreenNode node) {
  if (node is tex_ast.EquationRowNode) {
    return katex_ast.EquationRowNode(
      children: toKatexGreenNodes(node.children),
      overrideType: node.overrideType,
    );
  }
  if (node is tex_ast.SymbolNode) {
    return katex_ast.SymbolNode(
      symbol: node.symbol,
      variantForm: node.variantForm,
      overrideAtomType: node.overrideAtomType,
      overrideFont: node.overrideFont,
      mode: node.mode,
    );
  }
  if (node is tex_ast.StyleNode) {
    return katex_ast.StyleNode(
      children: toKatexGreenNodes(node.children),
      optionsDiff: node.optionsDiff,
    );
  }
  if (node is tex_ast.AccentNode) {
    return katex_ast.AccentNode(
      base: toKatexGreenNode(node.base).wrapWithEquationRow(),
      label: node.label,
      isStretchy: node.isStretchy,
      isShifty: node.isShifty,
    );
  }
  if (node is tex_ast.AccentUnderNode) {
    return katex_ast.AccentUnderNode(
      base: toKatexGreenNode(node.base).wrapWithEquationRow(),
      label: node.label,
    );
  }
  if (node is tex_ast.EnclosureNode) {
    return katex_ast.EnclosureNode(
      base: toKatexGreenNode(node.base).wrapWithEquationRow(),
      hasBorder: node.hasBorder,
      bordercolor: node.bordercolor?.toFlutterColor(),
      backgroundcolor: node.backgroundcolor?.toFlutterColor(),
      notation: node.notation,
      horizontalPadding: node.horizontalPadding,
      verticalPadding: node.verticalPadding,
    );
  }
  if (node is tex_ast.FracNode) {
    return katex_ast.FracNode(
      numerator: toKatexGreenNode(node.numerator).wrapWithEquationRow(),
      denominator: toKatexGreenNode(node.denominator).wrapWithEquationRow(),
      barSize: node.barSize,
      continued: node.continued,
    );
  }
  if (node is tex_ast.FunctionNode) {
    return katex_ast.FunctionNode(
      functionName: toKatexGreenNode(node.functionName).wrapWithEquationRow(),
      argument: toKatexGreenNode(node.argument).wrapWithEquationRow(),
    );
  }
  if (node is tex_ast.LeftRightNode) {
    return katex_ast.LeftRightNode(
      leftDelim: node.leftDelim,
      rightDelim: node.rightDelim,
      body: node.body
          .map((child) => toKatexGreenNode(child).wrapWithEquationRow())
          .toList(growable: false),
      middle: node.middle,
    );
  }
  if (node is tex_ast.MatrixNode) {
    return katex_ast.MatrixNode(
      arrayStretch: node.arrayStretch,
      hskipBeforeAndAfter: node.hskipBeforeAndAfter,
      isSmall: node.isSmall,
      columnAligns: node.columnAligns,
      vLines: node.vLines,
      rowSpacings: node.rowSpacings,
      hLines: node.hLines,
      body: node.body
          .map(
            (row) => row
                .map((cell) => cell == null
                    ? null
                    : toKatexGreenNode(cell).wrapWithEquationRow())
                .toList(growable: false),
          )
          .toList(growable: false),
    );
  }
  if (node is tex_ast.MultiscriptsNode) {
    return katex_ast.MultiscriptsNode(
      alignPostscripts: node.alignPostscripts,
      base: toKatexGreenNode(node.base).wrapWithEquationRow(),
      sub: node.sub == null
          ? null
          : toKatexGreenNode(node.sub!).wrapWithEquationRow(),
      sup: node.sup == null
          ? null
          : toKatexGreenNode(node.sup!).wrapWithEquationRow(),
      presub: node.presub == null
          ? null
          : toKatexGreenNode(node.presub!).wrapWithEquationRow(),
      presup: node.presup == null
          ? null
          : toKatexGreenNode(node.presup!).wrapWithEquationRow(),
    );
  }
  if (node is tex_ast.NaryOperatorNode) {
    return katex_ast.NaryOperatorNode(
      operator: node.operator,
      lowerLimit: node.lowerLimit == null
          ? null
          : toKatexGreenNode(node.lowerLimit!).wrapWithEquationRow(),
      upperLimit: node.upperLimit == null
          ? null
          : toKatexGreenNode(node.upperLimit!).wrapWithEquationRow(),
      naryand: toKatexGreenNode(node.naryand).wrapWithEquationRow(),
      limits: node.limits,
      allowLargeOp: node.allowLargeOp,
    );
  }
  if (node is tex_ast.OverNode) {
    return katex_ast.OverNode(
      base: toKatexGreenNode(node.base).wrapWithEquationRow(),
      above: toKatexGreenNode(node.above).wrapWithEquationRow(),
      stackRel: node.stackRel,
    );
  }
  if (node is tex_ast.PhantomNode) {
    return katex_ast.PhantomNode(
      phantomChild: toKatexGreenNode(node.phantomChild).wrapWithEquationRow(),
      zeroWidth: node.zeroWidth,
      zeroHeight: node.zeroHeight,
      zeroDepth: node.zeroDepth,
    );
  }
  if (node is tex_ast.RaiseBoxNode) {
    return katex_ast.RaiseBoxNode(
      dy: node.dy,
      body: toKatexGreenNode(node.body).wrapWithEquationRow(),
    );
  }
  if (node is tex_ast.SpaceNode) {
    return katex_ast.SpaceNode(
      height: node.height,
      width: node.width,
      depth: node.depth,
      shift: node.shift,
      breakPenalty: node.breakPenalty,
      fill: node.fill,
      mode: node.mode,
      alignerOrSpacer: node.alignerOrSpacer,
    );
  }
  if (node is tex_ast.SqrtNode) {
    return katex_ast.SqrtNode(
      index:
          node.index == null ? null : toKatexGreenNode(node.index!).wrapWithEquationRow(),
      base: toKatexGreenNode(node.base).wrapWithEquationRow(),
    );
  }
  if (node is tex_ast.StretchyOpNode) {
    return katex_ast.StretchyOpNode(
      above:
          node.above == null ? null : toKatexGreenNode(node.above!).wrapWithEquationRow(),
      below:
          node.below == null ? null : toKatexGreenNode(node.below!).wrapWithEquationRow(),
      symbol: node.symbol,
    );
  }
  if (node is tex_ast.UnderNode) {
    return katex_ast.UnderNode(
      base: toKatexGreenNode(node.base).wrapWithEquationRow(),
      below: toKatexGreenNode(node.below).wrapWithEquationRow(),
    );
  }
  if (node is tex_ast.EquationArrayNode) {
    return katex_ast.EquationArrayNode(
      addJot: node.addJot,
      body: node.body
          .map((row) => toKatexGreenNode(row).wrapWithEquationRow())
          .toList(growable: false),
      arrayStretch: node.arrayStretch,
      hlines: node.hlines,
      rowSpacings: node.rowSpacings,
    );
  }
  throw UnsupportedError(
    'Unsupported flutter_math_tex node for KaTeX rendering: ${node.runtimeType}.',
  );
}

tex_ast.GreenNode toTexGreenNode(katex_ast.GreenNode node) {
  if (node is katex_ast.EquationRowNode) {
    return tex_ast.EquationRowNode(
      children: toTexGreenNodes(node.children),
      overrideType: node.overrideType,
    );
  }
  if (node is katex_ast.SymbolNode) {
    return tex_ast.SymbolNode(
      symbol: node.symbol,
      variantForm: node.variantForm,
      overrideAtomType: node.overrideAtomType,
      overrideFont: node.overrideFont,
      mode: node.mode,
    );
  }
  if (node is katex_ast.StyleNode) {
    return tex_ast.StyleNode(
      children: toTexGreenNodes(node.children),
      optionsDiff: node.optionsDiff,
    );
  }
  if (node is katex_ast.AccentNode) {
    return tex_ast.AccentNode(
      base: toTexGreenNode(node.base).wrapWithEquationRow(),
      label: node.label,
      isStretchy: node.isStretchy,
      isShifty: node.isShifty,
    );
  }
  if (node is katex_ast.AccentUnderNode) {
    return tex_ast.AccentUnderNode(
      base: toTexGreenNode(node.base).wrapWithEquationRow(),
      label: node.label,
    );
  }
  if (node is katex_ast.EnclosureNode) {
    return tex_ast.EnclosureNode(
      base: toTexGreenNode(node.base).wrapWithEquationRow(),
      hasBorder: node.hasBorder,
      bordercolor: node.bordercolor?.toMathColor(),
      backgroundcolor: node.backgroundcolor?.toMathColor(),
      notation: node.notation,
      horizontalPadding: node.horizontalPadding,
      verticalPadding: node.verticalPadding,
    );
  }
  if (node is katex_ast.FracNode) {
    return tex_ast.FracNode(
      numerator: toTexGreenNode(node.numerator).wrapWithEquationRow(),
      denominator: toTexGreenNode(node.denominator).wrapWithEquationRow(),
      barSize: node.barSize,
      continued: node.continued,
    );
  }
  if (node is katex_ast.FunctionNode) {
    return tex_ast.FunctionNode(
      functionName: toTexGreenNode(node.functionName).wrapWithEquationRow(),
      argument: toTexGreenNode(node.argument).wrapWithEquationRow(),
    );
  }
  if (node is katex_ast.LeftRightNode) {
    return tex_ast.LeftRightNode(
      leftDelim: node.leftDelim,
      rightDelim: node.rightDelim,
      body: node.body
          .map((child) => toTexGreenNode(child).wrapWithEquationRow())
          .toList(growable: false),
      middle: node.middle,
    );
  }
  if (node is katex_ast.MatrixNode) {
    return tex_ast.MatrixNode(
      arrayStretch: node.arrayStretch,
      hskipBeforeAndAfter: node.hskipBeforeAndAfter,
      isSmall: node.isSmall,
      columnAligns: node.columnAligns,
      vLines: node.vLines,
      rowSpacings: node.rowSpacings,
      hLines: node.hLines,
      body: node.body
          .map(
            (row) => row
                .map((cell) =>
                    cell == null ? null : toTexGreenNode(cell).wrapWithEquationRow())
                .toList(growable: false),
          )
          .toList(growable: false),
    );
  }
  if (node is katex_ast.MultiscriptsNode) {
    return tex_ast.MultiscriptsNode(
      alignPostscripts: node.alignPostscripts,
      base: toTexGreenNode(node.base).wrapWithEquationRow(),
      sub:
          node.sub == null ? null : toTexGreenNode(node.sub!).wrapWithEquationRow(),
      sup:
          node.sup == null ? null : toTexGreenNode(node.sup!).wrapWithEquationRow(),
      presub: node.presub == null
          ? null
          : toTexGreenNode(node.presub!).wrapWithEquationRow(),
      presup: node.presup == null
          ? null
          : toTexGreenNode(node.presup!).wrapWithEquationRow(),
    );
  }
  if (node is katex_ast.NaryOperatorNode) {
    return tex_ast.NaryOperatorNode(
      operator: node.operator,
      lowerLimit:
          node.lowerLimit == null ? null : toTexGreenNode(node.lowerLimit!).wrapWithEquationRow(),
      upperLimit:
          node.upperLimit == null ? null : toTexGreenNode(node.upperLimit!).wrapWithEquationRow(),
      naryand: toTexGreenNode(node.naryand).wrapWithEquationRow(),
      limits: node.limits,
      allowLargeOp: node.allowLargeOp,
    );
  }
  if (node is katex_ast.OverNode) {
    return tex_ast.OverNode(
      base: toTexGreenNode(node.base).wrapWithEquationRow(),
      above: toTexGreenNode(node.above).wrapWithEquationRow(),
      stackRel: node.stackRel,
    );
  }
  if (node is katex_ast.PhantomNode) {
    return tex_ast.PhantomNode(
      phantomChild: toTexGreenNode(node.phantomChild).wrapWithEquationRow(),
      zeroWidth: node.zeroWidth,
      zeroHeight: node.zeroHeight,
      zeroDepth: node.zeroDepth,
    );
  }
  if (node is katex_ast.RaiseBoxNode) {
    return tex_ast.RaiseBoxNode(
      dy: node.dy,
      body: toTexGreenNode(node.body).wrapWithEquationRow(),
    );
  }
  if (node is katex_ast.SpaceNode) {
    return tex_ast.SpaceNode(
      height: node.height,
      width: node.width,
      depth: node.depth,
      shift: node.shift,
      breakPenalty: node.breakPenalty,
      fill: node.fill,
      mode: node.mode,
      alignerOrSpacer: node.alignerOrSpacer,
    );
  }
  if (node is katex_ast.SqrtNode) {
    return tex_ast.SqrtNode(
      index:
          node.index == null ? null : toTexGreenNode(node.index!).wrapWithEquationRow(),
      base: toTexGreenNode(node.base).wrapWithEquationRow(),
    );
  }
  if (node is katex_ast.StretchyOpNode) {
    return tex_ast.StretchyOpNode(
      above:
          node.above == null ? null : toTexGreenNode(node.above!).wrapWithEquationRow(),
      below:
          node.below == null ? null : toTexGreenNode(node.below!).wrapWithEquationRow(),
      symbol: node.symbol,
    );
  }
  if (node is katex_ast.UnderNode) {
    return tex_ast.UnderNode(
      base: toTexGreenNode(node.base).wrapWithEquationRow(),
      below: toTexGreenNode(node.below).wrapWithEquationRow(),
    );
  }
  if (node is katex_ast.EquationArrayNode) {
    return tex_ast.EquationArrayNode(
      addJot: node.addJot,
      body: node.body
          .map((row) => toTexGreenNode(row).wrapWithEquationRow())
          .toList(growable: false),
      arrayStretch: node.arrayStretch,
      hlines: node.hlines,
      rowSpacings: node.rowSpacings,
    );
  }
  throw UnsupportedError(
    'Unsupported flutter_math_katex node for TeX encoding: ${node.runtimeType}.',
  );
}
