import 'package:flutter_math_model/ast.dart';

import '../encoder.dart';
import 'style_mapping.dart';

extension GreenNodeUnicodeMathEncodeExt on GreenNode {
  /// Encode this AST node into a UnicodeMath string.
  String encodeUnicodeMath({
    UnicodeMathEncodeConf conf = const UnicodeMathEncodeConf(),
  }) =>
      encodeUnicodeMathNode(this, conf: conf);
}

extension SyntaxTreeUnicodeMathEncodeExt on SyntaxTree {
  /// Encode the syntax tree root into a UnicodeMath string.
  String encodeUnicodeMath({
    UnicodeMathEncodeConf conf = const UnicodeMathEncodeConf(),
  }) =>
      greenRoot.encodeUnicodeMath(conf: conf);
}

String encodeUnicodeMath(
  GreenNode node, {
  UnicodeMathEncodeConf conf = const UnicodeMathEncodeConf(),
}) =>
    _UnicodeMathStringifier(conf).encode(node);

String encodeUnicodeMathNode(
  GreenNode node, {
  UnicodeMathEncodeConf conf = const UnicodeMathEncodeConf(),
}) =>
    _UnicodeMathStringifier(conf).encode(node);

class _UnicodeMathStringifier {
  final UnicodeMathEncodeConf conf;

  const _UnicodeMathStringifier(this.conf);

  String encode(GreenNode node) {
    final symbolNode = _tryReadSymbolNode(node);
    if (symbolNode != null) {
      return _encodeSymbolLike(symbolNode);
    }

    final enclosureNode = _tryReadEnclosureNode(node);
    if (enclosureNode != null) {
      return _encodeEnclosureLike(enclosureNode);
    }

    if (node is EquationRowNode) {
      return _encodeEquationRow(node);
    }
    if (node is StyleNode) {
      return _encodeStyle(node);
    }
    if (node is FracNodeModel) {
      return '${_wrapOperand(node.numerator)}/${_wrapOperand(node.denominator)}';
    }
    if (node is SqrtNodeModel) {
      return node.index == null
          ? '√${_wrapOperand(node.base)}'
          : '√(${encode(node.base)}&${encode(node.index!)})';
    }
    if (node is MultiscriptsNodeModel) {
      return _encodeMultiscripts(node);
    }
    if (node is FunctionNodeModel) {
      return '${encode(node.functionName)} ${_wrapOperand(node.argument)}';
    }
    if (node is LeftRightNodeModel) {
      return _encodeLeftRight(node);
    }
    if (node is NaryOperatorNodeModel) {
      return _encodeNary(node);
    }
    if (node is OverNodeModel) {
      return r'\overset('
          '${encode(node.above)})(${encode(node.base)})';
    }
    if (node is UnderNodeModel) {
      return r'\underset('
          '${encode(node.below)})(${encode(node.base)})';
    }
    if (node is StretchyOpNodeModel) {
      return _encodeStretchyOp(node);
    }
    if (node is AccentNodeModel) {
      return _encodeAccent(node);
    }
    if (node is AccentUnderNodeModel) {
      return _encodeAccentUnder(node);
    }
    if (node is SpaceNodeModel) {
      return _encodeSpace(node);
    }
    if (node is MatrixNodeModel) {
      return _encodeMatrix(node);
    }
    if (node is EquationArrayNodeModel) {
      return _encodeEquationArray(node);
    }
    if (node is RaiseBoxNodeModel) {
      return r'\raise('
          '${node.dy})(${encode(node.body)})';
    }
    if (node is PhantomNodeModel) {
      final command = node.zeroWidth && !node.zeroHeight && !node.zeroDepth
          ? r'\hphantom'
          : !node.zeroWidth && node.zeroHeight && node.zeroDepth
              ? r'\vphantom'
              : r'\phantom';
      return '$command(${encode(node.phantomChild)})';
    }

    return _handleUnsupported(
      'Unsupported node type ${node.runtimeType} during UnicodeMath encoding.',
    );
  }

  String _encodeEquationRow(EquationRowNode node) =>
      node.children.map(encode).join();

  String _encodeStyle(StyleNode node) {
    final mergedConf = conf.mergeStyle(node.optionsDiff);
    var result =
        _UnicodeMathStringifier(mergedConf)._encodeNodes(node.children);

    if (node.optionsDiff.color != null) {
      result = '\\color{${_hexColor(node.optionsDiff.color!)}}($result)';
    }
    if (node.optionsDiff.size != null) {
      result = '\\size(${node.optionsDiff.size!.name})($result)';
    }
    if (node.optionsDiff.style != null) {
      result = '\\style(${node.optionsDiff.style!.name})($result)';
    }

    return result;
  }

  String _encodeNodes(List<GreenNode> nodes) => nodes.map(encode).join();

  String _encodeSymbolLike(_SymbolLikeNode node) {
    final scopedConf = conf.forMode(node.mode);
    final effectiveFont = node.overrideFont ??
        (node.mode == Mode.math
            ? scopedConf.mathFontOptions
            : scopedConf.textFontOptions);
    if (!scopedConf.preferUnicodeStylePlane) {
      return node.symbol;
    }
    return applyMathAlphabetStyle(node.symbol, effectiveFont);
  }

  String _encodeMultiscripts(MultiscriptsNodeModel node) {
    final buffer = StringBuffer();
    if (node.presub != null) {
      buffer.write('_${_wrapScriptOperand(node.presub!)}');
    }
    if (node.presup != null) {
      buffer.write('^${_wrapScriptOperand(node.presup!)}');
    }
    buffer.write(_wrapOperand(node.base));
    if (node.sub != null) {
      buffer.write('_${_wrapScriptOperand(node.sub!)}');
    }
    if (node.sup != null) {
      buffer.write('^${_wrapScriptOperand(node.sup!)}');
    }
    return buffer.toString();
  }

  String _encodeLeftRight(LeftRightNodeModel node) {
    final buffer = StringBuffer();
    final left = _normalizeDelimiter(node.leftDelim);
    final right = _normalizeDelimiter(node.rightDelim);
    if (left != null) {
      buffer.write(left);
    }
    for (var i = 0; i < node.body.length; i++) {
      buffer.write(encode(node.body[i]));
      if (i < node.middle.length) {
        final middle = _normalizeDelimiter(node.middle[i]);
        if (middle != null) {
          buffer.write(middle);
        }
      }
    }
    if (right != null) {
      buffer.write(right);
    }
    return buffer.toString();
  }

  String _encodeNary(NaryOperatorNodeModel node) {
    final buffer = StringBuffer(node.operator);
    if (node.lowerLimit != null) {
      buffer.write('_${_wrapScriptOperand(node.lowerLimit!)}');
    }
    if (node.upperLimit != null) {
      buffer.write('^${_wrapScriptOperand(node.upperLimit!)}');
    }
    final naryand = encode(node.naryand);
    if (naryand.isNotEmpty) {
      buffer.write(' ');
      buffer.write(naryand);
    }
    return buffer.toString();
  }

  String _encodeStretchyOp(StretchyOpNodeModel node) {
    var result = node.symbol;
    if (node.above != null) {
      result = '\\overset(${encode(node.above!)})($result)';
    }
    if (node.below != null) {
      result = '\\underset(${encode(node.below!)})($result)';
    }
    return result;
  }

  String _encodeAccent(AccentNodeModel node) {
    final combining = _combiningAccentByLabel[node.label];
    if (combining != null && _isSimpleOperand(node.base)) {
      return '${encode(node.base)}$combining';
    }
    return '\\accent(${node.label})(${encode(node.base)})';
  }

  String _encodeAccentUnder(AccentUnderNodeModel node) {
    final combining = _combiningUnderAccentByLabel[node.label];
    if (combining != null && _isSimpleOperand(node.base)) {
      return '${encode(node.base)}$combining';
    }
    return '\\underaccent(${node.label})(${encode(node.base)})';
  }

  String _encodeSpace(SpaceNodeModel node) {
    if (node.alignerOrSpacer) {
      return '&';
    }
    if (node.fill ||
        !node.width.isZero ||
        !node.height.isZero ||
        !node.depth.isZero) {
      return ' ';
    }
    return '';
  }

  String _encodeMatrix(MatrixNodeModel node) {
    final rows = node.body
        .map(
          (row) =>
              row.map((cell) => cell == null ? '' : encode(cell)).join('&'),
        )
        .join('@');
    return '\\matrix($rows)';
  }

  String _encodeEquationArray(EquationArrayNodeModel node) =>
      '\\eqarray(${node.body.map(encode).join('@')})';

  String _encodeEnclosureLike(_EnclosureLikeNode node) {
    final notation = node.notation.isEmpty
        ? (node.hasBorder ? 'box' : 'enclose')
        : node.notation.join(',');
    return '\\enclose($notation)(${encode(node.base)})';
  }

  String _wrapOperand(
    GreenNode node, {
    bool wrapSimpleRows = true,
  }) {
    final encoded = encode(node);
    if (encoded.isEmpty) {
      return '()';
    }
    if (_isSimpleOperand(node, wrapSimpleRows: wrapSimpleRows)) {
      return encoded;
    }
    return '($encoded)';
  }

  String _wrapScriptOperand(GreenNode node) {
    final encoded = encode(node);
    if (encoded.isEmpty) {
      return '()';
    }
    return _isSimpleOperand(node) ? encoded : '($encoded)';
  }

  bool _isSimpleOperand(
    GreenNode node, {
    bool wrapSimpleRows = true,
  }) {
    if (_tryReadSymbolNode(node) != null) {
      return true;
    }
    if (node is EquationRowNode) {
      return wrapSimpleRows &&
          node.children.length == 1 &&
          _isSimpleOperand(node.children.first);
    }
    if (node is LeftRightNodeModel) {
      return true;
    }
    if (node is StyleNode) {
      return node.children.length == 1 &&
          node.optionsDiff.color == null &&
          node.optionsDiff.size == null &&
          node.optionsDiff.style == null &&
          _isSimpleOperand(node.children.first);
    }
    return false;
  }

  String _handleUnsupported(String message, [String fallback = '']) {
    switch (conf.unsupportedBehavior) {
      case UnicodeMathEncodeUnsupportedBehavior.preserve:
        return fallback;
      case UnicodeMathEncodeUnsupportedBehavior.omit:
        return '';
      case UnicodeMathEncodeUnsupportedBehavior.error:
        throw UnicodeMathEncoderException(message);
    }
  }
}

String _hexColor(MathColor color) =>
    color.value.toRadixString(16).padLeft(8, '0');

String? _normalizeDelimiter(String? delimiter) {
  if (delimiter == null || delimiter == '.') {
    return null;
  }
  return delimiter;
}

class _SymbolLikeNode {
  final String symbol;
  final bool variantForm;
  final AtomType? overrideAtomType;
  final FontOptions? overrideFont;
  final Mode mode;

  const _SymbolLikeNode({
    required this.symbol,
    required this.variantForm,
    required this.overrideAtomType,
    required this.overrideFont,
    required this.mode,
  });
}

_SymbolLikeNode? _tryReadSymbolNode(GreenNode node) {
  final dynamic dynamicNode = node;
  try {
    final sharedModel = dynamicNode.sharedModel;
    if (sharedModel is SymbolNodeModel) {
      return _SymbolLikeNode(
        symbol: sharedModel.symbol,
        variantForm: sharedModel.variantForm,
        overrideAtomType: sharedModel.overrideAtomType,
        overrideFont: sharedModel.overrideFont,
        mode: sharedModel.mode,
      );
    }
  } on Object {
    // Ignore and fall back to direct property probing.
  }

  try {
    final symbol = dynamicNode.symbol;
    final mode = dynamicNode.mode;
    if (symbol is! String || mode is! Mode) {
      return null;
    }
    final dynamic variantForm = dynamicNode.variantForm;
    final dynamic overrideAtomType = dynamicNode.overrideAtomType;
    final dynamic overrideFont = dynamicNode.overrideFont;
    return _SymbolLikeNode(
      symbol: symbol,
      variantForm: variantForm is bool ? variantForm : false,
      overrideAtomType: overrideAtomType is AtomType ? overrideAtomType : null,
      overrideFont: overrideFont is FontOptions ? overrideFont : null,
      mode: mode,
    );
  } on Object {
    return null;
  }
}

class _EnclosureLikeNode {
  final EquationRowNode base;
  final bool hasBorder;
  final List<String> notation;

  const _EnclosureLikeNode({
    required this.base,
    required this.hasBorder,
    required this.notation,
  });
}

_EnclosureLikeNode? _tryReadEnclosureNode(GreenNode node) {
  final dynamic dynamicNode = node;
  try {
    final base = dynamicNode.base;
    final hasBorder = dynamicNode.hasBorder;
    final notation = dynamicNode.notation;
    if (base is EquationRowNode &&
        hasBorder is bool &&
        notation is List<String>) {
      return _EnclosureLikeNode(
        base: base,
        hasBorder: hasBorder,
        notation: notation,
      );
    }
  } on Object {
    return null;
  }
  return null;
}

const _combiningAccentByLabel = <String, String>{
  '^': '\u0302',
  '~': '\u0303',
  '¯': '\u0304',
  '˘': '\u0306',
  '˙': '\u0307',
  '¨': '\u0308',
  '˚': '\u030A',
  '˝': '\u030B',
  'ˇ': '\u030C',
};

const _combiningUnderAccentByLabel = <String, String>{
  '_': '\u0332',
  '¯': '\u0331',
  '~': '\u0330',
};
