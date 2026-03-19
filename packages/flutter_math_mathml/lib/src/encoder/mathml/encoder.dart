import 'package:flutter_math_model/ast.dart';

import '../../ast/nodes/enclosure.dart';
import '../encoder.dart';

extension GreenNodeMathMLEncodeExt on GreenNode {
  /// Encode this AST node into a MathML string.
  String encodeMathML({
    MathMLEncodeConf conf = const MathMLEncodeConf(),
  }) =>
      encodeMathMLNode(this, conf: conf);
}

extension SyntaxTreeMathMLEncodeExt on SyntaxTree {
  /// Encode the syntax tree root into a MathML string.
  String encodeMathML({
    MathMLEncodeConf conf = const MathMLEncodeConf(),
  }) =>
      greenRoot.encodeMathML(conf: conf);
}

String encodeMathMLNode(
  GreenNode node, {
  MathMLEncodeConf conf = const MathMLEncodeConf(),
}) {
  final body = _MathMLStringifier(conf).encode(node);
  if (!conf.includeMathTag) {
    return body;
  }
  final attrs = <String, String>{
    if (conf.includeXmlNamespace)
      'xmlns': 'http://www.w3.org/1998/Math/MathML',
    'display': conf.displayMode ? 'block' : 'inline',
  };
  return _element('math', attrs: attrs, children: <String>[body]);
}

class _MathMLStringifier {
  final MathMLEncodeConf conf;

  const _MathMLStringifier(this.conf);

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
      return _element('mfrac', children: <String>[
        encode(node.numerator),
        encode(node.denominator),
      ]);
    }
    if (node is SqrtNodeModel) {
      return node.index == null
          ? _element('msqrt', children: <String>[encode(node.base)])
          : _element('mroot', children: <String>[
              encode(node.base),
              encode(node.index!),
            ]);
    }
    if (node is MultiscriptsNodeModel) {
      return _encodeMultiscripts(node);
    }
    if (node is FunctionNodeModel) {
      return _element('mrow', children: <String>[
        encode(node.functionName),
        _operatorToken('\u2061'),
        encode(node.argument),
      ]);
    }
    if (node is LeftRightNodeModel) {
      return _encodeLeftRight(node);
    }
    if (node is NaryOperatorNodeModel) {
      return _encodeNary(node);
    }
    if (node is OverNodeModel) {
      return _element('mover', children: <String>[
        encode(node.base),
        encode(node.above),
      ]);
    }
    if (node is UnderNodeModel) {
      return _element('munder', children: <String>[
        encode(node.base),
        encode(node.below),
      ]);
    }
    if (node is StretchyOpNodeModel) {
      return _encodeStretchyOp(node);
    }
    if (node is AccentNodeModel) {
      return _element(
        'mover',
        attrs: const <String, String>{'accent': 'true'},
        children: <String>[
          encode(node.base),
          _operatorToken(
            node.label,
            extraAttrs: <String, String>{
              if (node.isStretchy) 'stretchy': 'true',
            },
          ),
        ],
      );
    }
    if (node is AccentUnderNodeModel) {
      return _element(
        'munder',
        attrs: const <String, String>{'accentunder': 'true'},
        children: <String>[
          encode(node.base),
          _operatorToken(node.label),
        ],
      );
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
      return _element(
        'mpadded',
        attrs: <String, String>{'voffset': _measurementToCss(node.dy)},
        children: <String>[encode(node.body)],
      );
    }
    if (node is PhantomNodeModel) {
      return _encodePhantom(node);
    }

    return _handleUnsupported(
      'Unsupported node type ${node.runtimeType} during MathML encoding.',
      _element(
        'mtext',
        attrs: <String, String>{'data-unsupported': '${node.runtimeType}'},
        text: '',
      ),
    );
  }

  String _encodeEquationRow(EquationRowNode node) => _element(
        'mrow',
        children: node.children.map(encode).toList(growable: false),
      );

  String _encodeStyle(StyleNode node) {
    final attrs = <String, String>{};
    if (node.optionsDiff.color != null) {
      attrs['mathcolor'] = _mathColorToCss(node.optionsDiff.color!);
    }
    if (node.optionsDiff.size != null) {
      attrs['mathsize'] = _mathSizeToCss(node.optionsDiff.size!);
    }
    if (node.optionsDiff.style != null) {
      attrs.addAll(_mathStyleAttrs(node.optionsDiff.style!));
    }

    final fontVariant = _mathVariantForOptionsDiff(node.optionsDiff);
    if (fontVariant != null) {
      attrs['mathvariant'] = fontVariant;
    }

    if (attrs.isEmpty) {
      return _encodeNodes(node.children);
    }
    return _element(
      'mstyle',
      attrs: attrs,
      children: <String>[_encodeNodes(node.children)],
    );
  }

  String _encodeNodes(List<GreenNode> nodes) => nodes.map(encode).join();

  String _encodeSymbolLike(_SymbolLikeNode node) {
    final tag = _tokenTagFor(node);
    final attrs = <String, String>{};
    final variant = _mathVariantForFont(node.overrideFont);
    if (variant != null) {
      attrs['mathvariant'] = variant;
    }
    if (tag == 'mo' && _isDelimiter(node.symbol)) {
      attrs['fence'] = 'true';
    }
    return _element(tag, attrs: attrs, text: node.symbol);
  }

  String _encodeMultiscripts(MultiscriptsNodeModel node) {
    if (node.presub != null || node.presup != null) {
      return _element('mmultiscripts', children: <String>[
        encode(node.base),
        node.sub == null ? _element('none') : encode(node.sub!),
        node.sup == null ? _element('none') : encode(node.sup!),
        _element('mprescripts'),
        node.presub == null ? _element('none') : encode(node.presub!),
        node.presup == null ? _element('none') : encode(node.presup!),
      ]);
    }
    if (node.sub != null && node.sup != null) {
      return _element('msubsup', children: <String>[
        encode(node.base),
        encode(node.sub!),
        encode(node.sup!),
      ]);
    }
    if (node.sub != null) {
      return _element('msub', children: <String>[
        encode(node.base),
        encode(node.sub!),
      ]);
    }
    if (node.sup != null) {
      return _element('msup', children: <String>[
        encode(node.base),
        encode(node.sup!),
      ]);
    }
    return encode(node.base);
  }

  String _encodeLeftRight(LeftRightNodeModel node) {
    final children = <String>[
      if (_normalizeDelimiter(node.leftDelim) != null)
        _operatorToken(
          _normalizeDelimiter(node.leftDelim)!,
          extraAttrs: const <String, String>{'fence': 'true'},
        ),
    ];
    for (var i = 0; i < node.body.length; i++) {
      children.add(encode(node.body[i]));
      if (i < node.middle.length && _normalizeDelimiter(node.middle[i]) != null) {
        children.add(
          _operatorToken(
            _normalizeDelimiter(node.middle[i])!,
            extraAttrs: const <String, String>{'separator': 'true'},
          ),
        );
      }
    }
    final right = _normalizeDelimiter(node.rightDelim);
    if (right != null) {
      children.add(
        _operatorToken(right, extraAttrs: const <String, String>{'fence': 'true'}),
      );
    }
    return _element('mrow', children: children);
  }

  String _encodeNary(NaryOperatorNodeModel node) {
    final operator = _operatorToken(
      node.operator,
      extraAttrs: <String, String>{
        if (node.allowLargeOp) 'largeop': 'true',
        if (node.limits != null) 'movablelimits': node.limits! ? 'false' : 'true',
      },
    );
    String head = operator;
    if (node.lowerLimit != null && node.upperLimit != null) {
      head = _element('munderover', children: <String>[
        operator,
        encode(node.lowerLimit!),
        encode(node.upperLimit!),
      ]);
    } else if (node.lowerLimit != null) {
      head = _element('munder', children: <String>[
        operator,
        encode(node.lowerLimit!),
      ]);
    } else if (node.upperLimit != null) {
      head = _element('mover', children: <String>[
        operator,
        encode(node.upperLimit!),
      ]);
    }

    if (node.naryand.children.isEmpty) {
      return head;
    }
    return _element('mrow', children: <String>[head, encode(node.naryand)]);
  }

  String _encodeStretchyOp(StretchyOpNodeModel node) {
    final operator = _operatorToken(
      node.symbol,
      extraAttrs: const <String, String>{'stretchy': 'true'},
    );
    if (node.above != null && node.below != null) {
      return _element('munderover', children: <String>[
        operator,
        encode(node.below!),
        encode(node.above!),
      ]);
    }
    if (node.above != null) {
      return _element('mover', children: <String>[
        operator,
        encode(node.above!),
      ]);
    }
    return _element('munder', children: <String>[
      operator,
      encode(node.below!),
    ]);
  }

  String _encodeSpace(SpaceNodeModel node) {
    final attrs = <String, String>{};
    if (node.alignerOrSpacer) {
      attrs['width'] = '0em';
      attrs['data-aligner'] = 'true';
    } else {
      attrs['width'] = node.fill ? '1em' : _measurementToCss(node.width);
      if (!node.height.isZero) {
        attrs['height'] = _measurementToCss(node.height);
      }
      if (!node.depth.isZero) {
        attrs['depth'] = _measurementToCss(node.depth);
      }
      if (!node.shift.isZero) {
        attrs['voffset'] = _measurementToCss(node.shift);
      }
    }
    return _element('mspace', attrs: attrs);
  }

  String _encodeMatrix(MatrixNodeModel node) {
    final frame = _tableFrameValue(
      top: node.hLines.first,
      bottom: node.hLines.last,
      left: node.vLines.first,
      right: node.vLines.last,
    );
    final attrs = <String, String>{
      if (node.columnAligns.isNotEmpty)
        'columnalign': node.columnAligns.map(_matrixColumnAlignToMathML).join(' '),
      if (node.rows > 1)
        'rowspacing': node.rowSpacings
            .take(node.rows - 1)
            .map(_measurementToCss)
            .join(' '),
      if (node.cols > 1)
        'columnlines': node.vLines
            .skip(1)
            .take(node.cols - 1)
            .map(_separatorStyleToMathML)
            .join(' '),
      if (node.rows > 1)
        'rowlines': node.hLines
            .skip(1)
            .take(node.rows - 1)
            .map(_separatorStyleToMathML)
            .join(' '),
      if (frame != null) 'frame': frame,
      if (node.isSmall) 'displaystyle': 'false',
    };

    return _element(
      'mtable',
      attrs: attrs,
      children: List<String>.generate(
        node.rows,
        (row) => _element(
          'mtr',
          children: List<String>.generate(
            node.cols,
            (col) => _element(
              'mtd',
              children: <String>[
                encode(node.body[row][col] ?? EquationRowNode.empty()),
              ],
            ),
            growable: false,
          ),
        ),
        growable: false,
      ),
    );
  }

  String _encodeEquationArray(EquationArrayNodeModel node) {
    final splitRows = node.body.map(_splitEquationArrayRow).toList(growable: false);
    final columnCount = splitRows.fold<int>(
      0,
      (current, row) => row.length > current ? row.length : current,
    );
    final frame = _tableFrameValue(
      top: node.hlines.first,
      bottom: node.hlines.last,
    );
    final attrs = <String, String>{
      if (node.body.length > 1)
        'rowspacing': node.rowSpacings
            .take(node.body.length - 1)
            .map(_measurementToCss)
            .join(' '),
      if (node.body.length > 1)
        'rowlines': node.hlines
            .skip(1)
            .take(node.body.length - 1)
            .map(_separatorStyleToMathML)
            .join(' '),
      if (frame != null) 'frame': frame,
      if (columnCount > 1)
        'columnalign': List<String>.filled(columnCount, 'left', growable: false)
            .join(' '),
    };

    return _element(
      'mtable',
      attrs: attrs,
      children: splitRows
          .map(
            (row) => _element(
              'mtr',
              children: row
                  .map(
                    (cell) => _element(
                      'mtd',
                      children: <String>[encode(cell)],
                    ),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
    );
  }

  String _encodeEnclosureLike(_EnclosureLikeNode node) {
    final notation = node.notation.isEmpty
        ? (node.hasBorder ? 'box' : null)
        : node.notation.join(' ');
    var content = encode(node.base);

    if (node.backgroundColor != null) {
      content = _element(
        'mstyle',
        attrs: <String, String>{
          'mathbackground': _mathColorToCss(node.backgroundColor!),
        },
        children: <String>[content],
      );
    }

    return _element(
      'menclose',
      attrs: <String, String>{
        if (notation != null) 'notation': notation,
        if (node.borderColor != null)
          'style': 'border-color:${_mathColorToCss(node.borderColor!)};',
      },
      children: <String>[content],
    );
  }

  String _encodePhantom(PhantomNodeModel node) {
    final content =
        _element('mphantom', children: <String>[encode(node.phantomChild)]);
    if (!node.zeroWidth && !node.zeroHeight && !node.zeroDepth) {
      return content;
    }

    return _element(
      'mpadded',
      attrs: <String, String>{
        if (node.zeroWidth) 'width': '0em',
        if (node.zeroHeight) 'height': '0em',
        if (node.zeroDepth) 'depth': '0em',
      },
      children: <String>[content],
    );
  }

  String _handleUnsupported(String message, [String fallback = '']) {
    switch (conf.unsupportedBehavior) {
      case MathMLEncodeUnsupportedBehavior.preserve:
        return fallback;
      case MathMLEncodeUnsupportedBehavior.omit:
        return '';
      case MathMLEncodeUnsupportedBehavior.error:
        throw MathMLEncoderException(message);
    }
  }
}

String _element(
  String name, {
  Map<String, String> attrs = const <String, String>{},
  String? text,
  List<String> children = const <String>[],
}) {
  final buffer = StringBuffer()..write('<$name');
  attrs.forEach((key, value) {
    buffer.write(' $key="${_escapeXml(value)}"');
  });
  if (text == null && children.isEmpty) {
    buffer.write('/>');
    return buffer.toString();
  }
  buffer.write('>');
  if (text != null) {
    buffer.write(_escapeXml(text));
  }
  for (final child in children) {
    buffer.write(child);
  }
  buffer.write('</$name>');
  return buffer.toString();
}

String _escapeXml(String input) => input
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');

String _operatorToken(
  String symbol, {
  Map<String, String> extraAttrs = const <String, String>{},
}) =>
    _element('mo', attrs: extraAttrs, text: symbol);

String _mathColorToCss(MathColor color) {
  final argb = color.value;
  final a = (argb >> 24) & 0xff;
  final r = (argb >> 16) & 0xff;
  final g = (argb >> 8) & 0xff;
  final b = argb & 0xff;
  if (a == 0xff) {
    return '#'
        '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }
  return 'rgba($r, $g, $b, ${a / 255})';
}

String _mathSizeToCss(MathSize size) =>
    '${(size.sizeMultiplier * 100).toStringAsFixed(1)}%';

Map<String, String> _mathStyleAttrs(MathStyle style) {
  switch (style) {
    case MathStyle.display:
    case MathStyle.displayCramped:
      return const <String, String>{'displaystyle': 'true', 'scriptlevel': '0'};
    case MathStyle.text:
    case MathStyle.textCramped:
      return const <String, String>{'displaystyle': 'false', 'scriptlevel': '0'};
    case MathStyle.script:
    case MathStyle.scriptCramped:
      return const <String, String>{'displaystyle': 'false', 'scriptlevel': '1'};
    case MathStyle.scriptscript:
    case MathStyle.scriptscriptCramped:
      return const <String, String>{'displaystyle': 'false', 'scriptlevel': '2'};
  }
}

String? _mathVariantForOptionsDiff(OptionsDiff diff) {
  if (diff.mathFontOptions != null) {
    return _mathVariantForFont(diff.mathFontOptions);
  }
  if (diff.textFontOptions != null) {
    return _mathVariantForFont(
      const FontOptions().mergeWith(diff.textFontOptions),
    );
  }
  return null;
}

String? _mathVariantForFont(FontOptions? font) {
  if (font == null) {
    return null;
  }

  switch (font.fontFamily) {
    case 'Main':
    case 'Math':
      if (font.fontWeight == MathFontWeight.bold &&
          font.fontShape == MathFontStyle.italic) {
        return 'bold-italic';
      }
      if (font.fontWeight == MathFontWeight.bold) {
        return 'bold';
      }
      if (font.fontShape == MathFontStyle.italic) {
        return 'italic';
      }
      return null;
    case 'SansSerif':
      if (font.fontWeight == MathFontWeight.bold &&
          font.fontShape == MathFontStyle.italic) {
        return 'sans-serif-bold-italic';
      }
      if (font.fontWeight == MathFontWeight.bold) {
        return 'bold-sans-serif';
      }
      if (font.fontShape == MathFontStyle.italic) {
        return 'sans-serif-italic';
      }
      return 'sans-serif';
    case 'Typewriter':
      return 'monospace';
    case 'Fraktur':
      return font.fontWeight == MathFontWeight.bold
          ? 'bold-fraktur'
          : 'fraktur';
    case 'Script':
    case 'Caligraphic':
      return font.fontWeight == MathFontWeight.bold
          ? 'bold-script'
          : 'script';
    case 'AMS':
      return 'double-struck';
  }

  return null;
}

String _measurementToCss(Measurement measurement) {
  switch (measurement.unit) {
    case Unit.pt:
      return '${measurement.value}pt';
    case Unit.mm:
      return '${measurement.value}mm';
    case Unit.cm:
      return '${measurement.value}cm';
    case Unit.inches:
      return '${measurement.value}in';
    case Unit.bp:
    case Unit.pc:
    case Unit.dd:
    case Unit.cc:
    case Unit.nd:
    case Unit.nc:
    case Unit.sp:
    case Unit.lp:
      final pt = measurement.unit.toPt == null
          ? measurement.value
          : measurement.value * measurement.unit.toPt!;
      return '${pt}pt';
    case Unit.px:
      return '${measurement.value}px';
    case Unit.ex:
      return '${measurement.value}ex';
    case Unit.em:
    case Unit.cssEm:
      return '${measurement.value}em';
    case Unit.mu:
      return '${measurement.value / 18}em';
  }
}

String _matrixColumnAlignToMathML(MatrixColumnAlign align) {
  switch (align) {
    case MatrixColumnAlign.left:
      return 'left';
    case MatrixColumnAlign.center:
      return 'center';
    case MatrixColumnAlign.right:
      return 'right';
  }
}

String _separatorStyleToMathML(MatrixSeparatorStyle style) {
  switch (style) {
    case MatrixSeparatorStyle.none:
      return 'none';
    case MatrixSeparatorStyle.solid:
      return 'solid';
    case MatrixSeparatorStyle.dashed:
      return 'dashed';
  }
}

String? _tableFrameValue({
  MatrixSeparatorStyle? top,
  MatrixSeparatorStyle? bottom,
  MatrixSeparatorStyle? left,
  MatrixSeparatorStyle? right,
}) {
  final values = <MatrixSeparatorStyle>[
    if (top != null) top,
    if (bottom != null) bottom,
    if (left != null) left,
    if (right != null) right,
  ].where((value) => value != MatrixSeparatorStyle.none).toList(growable: false);
  if (values.isEmpty) {
    return null;
  }
  if (values.contains(MatrixSeparatorStyle.solid)) {
    return 'solid';
  }
  return 'dashed';
}

String? _normalizeDelimiter(String? delimiter) {
  if (delimiter == null || delimiter == '.') {
    return null;
  }
  return delimiter;
}

bool _isDelimiter(String symbol) => const <String>{
      '(',
      ')',
      '[',
      ']',
      '{',
      '}',
      '|',
      '‖',
      '⌈',
      '⌉',
      '⌊',
      '⌋',
      '⟨',
      '⟩',
    }.contains(symbol);

String _tokenTagFor(_SymbolLikeNode node) {
  if (node.mode == Mode.text) {
    return 'mtext';
  }
  final atom = node.overrideAtomType;
  if (atom == AtomType.bin ||
      atom == AtomType.rel ||
      atom == AtomType.open ||
      atom == AtomType.close ||
      atom == AtomType.punct ||
      atom == AtomType.spacing) {
    return 'mo';
  }
  if (_isOperatorLike(node.symbol)) {
    return 'mo';
  }
  if (_isNumericToken(node.symbol)) {
    return 'mn';
  }
  return 'mi';
}

bool _isOperatorLike(String value) {
  if (value.isEmpty) {
    return false;
  }
  return const <String>{
        '+',
        '-',
        '=',
        '<',
        '>',
        '≤',
        '≥',
        '≠',
        '≈',
        '∈',
        '∉',
        '∑',
        '∫',
        '∏',
        '∐',
        '∮',
        '⋂',
        '⋃',
        ':',
        ';',
        ',',
        '!',
        '?',
        '/',
        '*',
        '·',
        '×',
        '÷',
      }.contains(value) ||
      _isDelimiter(value);
}

bool _isNumericToken(String value) =>
    value.isNotEmpty &&
    value.runes.every((rune) => rune >= 0x30 && rune <= 0x39);

List<EquationRowNode> _splitEquationArrayRow(EquationRowNode row) {
  final cells = <EquationRowNode>[];
  var current = <GreenNode>[];
  for (final child in row.children) {
    if (child is SpaceNodeModel && child.alignerOrSpacer) {
      cells.add(EquationRowNode(children: List<GreenNode>.from(current)));
      current = <GreenNode>[];
      continue;
    }
    current.add(child);
  }
  cells.add(EquationRowNode(children: List<GreenNode>.from(current)));
  return cells;
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
  final MathColor? borderColor;
  final MathColor? backgroundColor;
  final List<String> notation;

  const _EnclosureLikeNode({
    required this.base,
    required this.hasBorder,
    required this.borderColor,
    required this.backgroundColor,
    required this.notation,
  });
}

_EnclosureLikeNode? _tryReadEnclosureNode(GreenNode node) {
  if (node is EnclosureNode) {
    return _EnclosureLikeNode(
      base: node.base,
      hasBorder: node.hasBorder,
      borderColor: node.borderColor,
      backgroundColor: node.backgroundColor,
      notation: node.notation,
    );
  }

  final dynamic dynamicNode = node;
  try {
    final base = dynamicNode.base;
    final hasBorder = dynamicNode.hasBorder;
    final notation = dynamicNode.notation;
    final borderColor = dynamicNode.borderColor;
    final backgroundColor = dynamicNode.backgroundColor;
    if (base is EquationRowNode &&
        hasBorder is bool &&
        notation is List<String>) {
      return _EnclosureLikeNode(
        base: base,
        hasBorder: hasBorder,
        borderColor: borderColor is MathColor ? borderColor : null,
        backgroundColor: backgroundColor is MathColor ? backgroundColor : null,
        notation: notation,
      );
    }
  } on Object {
    return null;
  }
  return null;
}
