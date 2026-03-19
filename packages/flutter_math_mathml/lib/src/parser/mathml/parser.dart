import 'package:flutter_math_model/ast.dart';
import 'package:xml/xml.dart';

import '../../ast.dart' show EnclosureNode, SymbolNode, stringToNode;
import '../parse_exception.dart';
import '../settings.dart';

const _openDelimiters = <String>{'(', '[', '{', '|', '‖', '⌈', '⌊', '⟨'};
const _closeDelimiters = <String>{')', ']', '}', '|', '‖', '⌉', '⌋', '⟩'};
const _relationSymbols = <String>{
  '=',
  '<',
  '>',
  '≤',
  '≥',
  '≠',
  '≈',
  '∈',
  '∉',
};
const _binarySymbols = <String>{
  '+',
  '-',
  '*',
  '·',
  '×',
  '÷',
  '∪',
  '∩',
  '∧',
  '∨',
};
const _punctuationSymbols = <String>{',', ';', ':', '!', '?'};
const _largeOperatorSymbols = <String>{
  '∑',
  '∏',
  '∐',
  '∫',
  '∬',
  '∭',
  '∮',
  '⋀',
  '⋁',
  '⋂',
  '⋃',
};

EquationRowNode parseMathML(
  String input, {
  MathMLParserSettings settings = const MathMLParserSettings(),
}) =>
    MathMLParser(input, settings: settings).parse();

extension StringMathMLParseExt on String {
  EquationRowNode parseMathML({
    MathMLParserSettings settings = const MathMLParserSettings(),
  }) =>
      MathMLParser(this, settings: settings).parse();
}

class MathMLParser {
  final String input;
  final MathMLParserSettings settings;

  const MathMLParser(
    this.input, {
    this.settings = const MathMLParserSettings(),
  });

  EquationRowNode parse() {
    final document = _parseDocument();
    final root = document.rootElement;
    if (_localName(root) == 'math') {
      final parsed = _parseContainer(root);
      if (parsed.children.length == 1 && parsed.children.first is EquationRowNode) {
        return parsed.children.first as EquationRowNode;
      }
      return parsed;
    }
    if (!settings.allowRootlessFragment) {
      throw const MathMLParseException(
        message: 'Expected a <math> root element.',
        elementName: 'document',
      );
    }
    return _parseElement(root).wrapWithEquationRow();
  }

  XmlDocument _parseDocument() {
    try {
      return XmlDocument.parse(input);
    } on XmlParserException catch (error) {
      throw MathMLParseException(message: error.message);
    }
  }

  EquationRowNode _parseContainer(XmlElement element) {
    final children = <GreenNode>[];

    for (final child in element.children) {
      if (child is XmlText) {
        final value = child.value;
        if (value.trim().isEmpty) {
          continue;
        }
        children.addAll(_textToNodes(value, mode: Mode.text));
        continue;
      }
      if (child is! XmlElement) {
        continue;
      }
      children.add(_parseElement(child));
    }

    return EquationRowNode(children: children);
  }

  GreenNode _parseElement(XmlElement element) {
    switch (_localName(element)) {
      case 'math':
      case 'mrow':
        return _parseContainer(element);
      case 'mi':
      case 'mn':
      case 'mo':
      case 'mtext':
        return _parseToken(element);
      case 'mfrac':
        return _parseFrac(element);
      case 'msqrt':
        return _parseSqrt(element);
      case 'mroot':
        return _parseRoot(element);
      case 'msub':
        return _parseScripts(element, hasSub: true, hasSup: false);
      case 'msup':
        return _parseScripts(element, hasSub: false, hasSup: true);
      case 'msubsup':
        return _parseScripts(element, hasSub: true, hasSup: true);
      case 'mmultiscripts':
        return _parseMultiscripts(element);
      case 'mover':
        return _parseMoverLike(element, hasBelow: false, hasAbove: true);
      case 'munder':
        return _parseMoverLike(element, hasBelow: true, hasAbove: false);
      case 'munderover':
        return _parseMoverLike(element, hasBelow: true, hasAbove: true);
      case 'mstyle':
        return _parseStyle(element);
      case 'mspace':
        return _parseSpace(element);
      case 'mtable':
        return _parseTable(element);
      case 'menclose':
        return _parseEnclosure(element);
      case 'mpadded':
        return _parsePadded(element);
      case 'mphantom':
        return _parsePhantom(element);
      case 'none':
        return EquationRowNode.empty();
      default:
        throw MathMLParseException(
          message: 'Unsupported MathML element <${_localName(element)}>.',
          elementName: _localName(element),
        );
    }
  }

  GreenNode _parseToken(XmlElement element) {
    final tag = _localName(element);
    final mode = tag == 'mtext' ? Mode.text : Mode.math;
    final text = element.innerText;
    if (text.isEmpty) {
      return EquationRowNode.empty();
    }

    final overrideFont = _parseMathVariant(element.getAttribute('mathvariant'));
    final overrideAtomType = tag == 'mo' ? _inferOperatorAtomType(element, text) : null;

    final children = text.runes
        .map(
          (rune) => SymbolNode(
            symbol: String.fromCharCode(rune),
            mode: mode,
            overrideFont: overrideFont,
            overrideAtomType: overrideAtomType,
          ),
        )
        .toList(growable: false);

    return children.length == 1
        ? children.first
        : EquationRowNode(children: children);
  }

  GreenNode _parseFrac(XmlElement element) {
    final children = _childElements(element);
    _expectChildCount(element, children, 2);
    return FracNodeModel(
      numerator: _parseElement(children[0]).wrapWithEquationRow(),
      denominator: _parseElement(children[1]).wrapWithEquationRow(),
    );
  }

  GreenNode _parseSqrt(XmlElement element) {
    final children = _childElements(element);
    _expectChildCount(element, children, 1);
    return SqrtNodeModel(
      index: null,
      base: _parseElement(children[0]).wrapWithEquationRow(),
    );
  }

  GreenNode _parseRoot(XmlElement element) {
    final children = _childElements(element);
    _expectChildCount(element, children, 2);
    return SqrtNodeModel(
      index: _parseElement(children[1]).wrapWithEquationRow(),
      base: _parseElement(children[0]).wrapWithEquationRow(),
    );
  }

  GreenNode _parseScripts(
    XmlElement element, {
    required bool hasSub,
    required bool hasSup,
  }) {
    final children = _childElements(element);
    final expected = 1 + (hasSub ? 1 : 0) + (hasSup ? 1 : 0);
    _expectChildCount(element, children, expected);

    return MultiscriptsNodeModel(
      base: _parseElement(children[0]).wrapWithEquationRow(),
      sub: hasSub ? _parseElement(children[1]).wrapWithEquationRow() : null,
      sup: hasSup
          ? _parseElement(children[hasSub ? 2 : 1]).wrapWithEquationRow()
          : null,
    );
  }

  GreenNode _parseMultiscripts(XmlElement element) {
    final children = _childElements(element);
    if (children.isEmpty) {
      throw MathMLParseException(
        message: '<mmultiscripts> requires at least a base child.',
        elementName: 'mmultiscripts',
      );
    }

    final mprescriptsIndex =
        children.indexWhere((child) => _localName(child) == 'mprescripts');

    final base = _parseElement(children.first).wrapWithEquationRow();

    EquationRowNode? sub;
    EquationRowNode? sup;
    EquationRowNode? presub;
    EquationRowNode? presup;

    if (mprescriptsIndex == -1) {
      if (children.length > 1 && _localName(children[1]) != 'none') {
        sub = _parseElement(children[1]).wrapWithEquationRow();
      }
      if (children.length > 2 && _localName(children[2]) != 'none') {
        sup = _parseElement(children[2]).wrapWithEquationRow();
      }
    } else {
      if (mprescriptsIndex > 1 && _localName(children[1]) != 'none') {
        sub = _parseElement(children[1]).wrapWithEquationRow();
      }
      if (mprescriptsIndex > 2 && _localName(children[2]) != 'none') {
        sup = _parseElement(children[2]).wrapWithEquationRow();
      }
      if (children.length > mprescriptsIndex + 1 &&
          _localName(children[mprescriptsIndex + 1]) != 'none') {
        presub = _parseElement(children[mprescriptsIndex + 1]).wrapWithEquationRow();
      }
      if (children.length > mprescriptsIndex + 2 &&
          _localName(children[mprescriptsIndex + 2]) != 'none') {
        presup = _parseElement(children[mprescriptsIndex + 2]).wrapWithEquationRow();
      }
    }

    return MultiscriptsNodeModel(
      base: base,
      sub: sub,
      sup: sup,
      presub: presub,
      presup: presup,
    );
  }

  GreenNode _parseMoverLike(
    XmlElement element, {
    required bool hasBelow,
    required bool hasAbove,
  }) {
    final children = _childElements(element);
    final expected = 1 + (hasBelow ? 1 : 0) + (hasAbove ? 1 : 0);
    _expectChildCount(element, children, expected);

    final baseElement = children[0];
    final baseNode = _parseElement(baseElement);
    final belowNode = hasBelow ? _parseElement(children[1]) : null;
    final aboveNode = hasAbove ? _parseElement(children[hasBelow ? 2 : 1]) : null;
    final baseSymbol = _extractSingleSymbol(baseNode);

    if (element.getAttribute('accent') == 'true') {
      return AccentNodeModel(
        base: baseNode.wrapWithEquationRow(),
        label: _extractOperatorLabel(aboveNode),
        isStretchy: _isTruthy(_childAttribute(children[hasBelow ? 2 : 1], 'stretchy')),
        isShifty: true,
      );
    }

    if (element.getAttribute('accentunder') == 'true') {
      return AccentUnderNodeModel(
        base: baseNode.wrapWithEquationRow(),
        label: _extractOperatorLabel(belowNode),
      );
    }

    final baseChildStretchy = _isTruthy(_childAttribute(baseElement, 'stretchy'));
    final baseChildLargeOp = _isTruthy(_childAttribute(baseElement, 'largeop'));

    if (baseSymbol != null && baseChildLargeOp) {
      return NaryOperatorNodeModel(
        operator: baseSymbol,
        lowerLimit: belowNode?.wrapWithEquationRow(),
        upperLimit: aboveNode?.wrapWithEquationRow(),
        naryand: EquationRowNode.empty(),
      );
    }

    if (baseSymbol != null && _largeOperatorSymbols.contains(baseSymbol)) {
      return NaryOperatorNodeModel(
        operator: baseSymbol,
        lowerLimit: belowNode?.wrapWithEquationRow(),
        upperLimit: aboveNode?.wrapWithEquationRow(),
        naryand: EquationRowNode.empty(),
      );
    }

    if (baseSymbol != null && baseChildStretchy) {
      return StretchyOpNodeModel(
        symbol: baseSymbol,
        below: belowNode?.wrapWithEquationRow(),
        above: aboveNode?.wrapWithEquationRow(),
      );
    }

    if (hasBelow && hasAbove) {
      return OverNodeModel(
        base: UnderNodeModel(
          base: baseNode.wrapWithEquationRow(),
          below: belowNode!.wrapWithEquationRow(),
        ).wrapWithEquationRow(),
        above: aboveNode!.wrapWithEquationRow(),
      );
    }
    if (hasBelow) {
      return UnderNodeModel(
        base: baseNode.wrapWithEquationRow(),
        below: belowNode!.wrapWithEquationRow(),
      );
    }
    return OverNodeModel(
      base: baseNode.wrapWithEquationRow(),
      above: aboveNode!.wrapWithEquationRow(),
    );
  }

  GreenNode _parseStyle(XmlElement element) {
    final optionsDiff = _parseOptionsDiff(element);
    final children = _parseContainer(element).children;
    if (optionsDiff.isEmpty) {
      return children.wrapWithEquationRow();
    }
    return StyleNode(
      children: children,
      optionsDiff: optionsDiff,
    );
  }

  GreenNode _parseSpace(XmlElement element) {
    if (_isTruthy(element.getAttribute('data-aligner'))) {
      return SpaceNodeModel.alignerOrSpacer();
    }

    return SpaceNodeModel(
      height: _parseMeasurementOrZero(element.getAttribute('height')),
      width: _parseMeasurementOrZero(element.getAttribute('width')),
      depth: _parseMeasurementOrZero(element.getAttribute('depth')),
      shift: _parseMeasurementOrZero(element.getAttribute('voffset')),
      mode: Mode.math,
    );
  }

  GreenNode _parseTable(XmlElement element) {
    final rowElements = _childElements(element).where((row) => _localName(row) == 'mtr').toList(growable: false);
    final List<List<EquationRowNode?>> body =
        rowElements.map(_parseTableRow).toList(growable: false);

    final columnAligns = _parseColumnAligns(element.getAttribute('columnalign'));
    final rowSpacings = _parseMeasurementList(element.getAttribute('rowspacing'));
    final rowLines = _parseSeparatorStyleList(element.getAttribute('rowlines'));
    final columnLines = _parseSeparatorStyleList(element.getAttribute('columnlines'));
    final frameStyle = _parseSeparatorStyle(element.getAttribute('frame'));

    if (settings.preferEquationArrays &&
        columnAligns.isNotEmpty &&
        columnAligns.every((align) => align == MatrixColumnAlign.left)) {
      return EquationArrayNodeModel(
        body: body.map(_tableRowToEquationArrayRow).toList(growable: false),
        rowSpacings: rowSpacings,
        hlines: _expandWithOuterFrame(
          rowLines,
          body.length,
          frameStyle,
        ),
      );
    }

    final cols = body.fold<int>(
      0,
      (current, row) => row.length > current ? row.length : current,
    );
    return MatrixNodeModel(
      body: body,
      columnAligns: columnAligns.isEmpty
          ? List<MatrixColumnAlign>.filled(cols, MatrixColumnAlign.center, growable: false)
          : columnAligns,
      rowSpacings: rowSpacings,
      hLines: _expandWithOuterFrame(
        rowLines,
        body.length,
        frameStyle,
      ),
      vLines: _expandWithOuterFrame(
        columnLines,
        cols,
        frameStyle,
      ),
    );
  }

  List<EquationRowNode?> _parseTableRow(XmlElement rowElement) {
    final cellElements = _childElements(rowElement)
        .where((cell) => _localName(cell) == 'mtd')
        .toList(growable: false);
    return cellElements
        .map(
          (cell) => _parseContainer(cell),
        )
        .toList(growable: false);
  }

  GreenNode _parseEnclosure(XmlElement element) {
    final notation = (element.getAttribute('notation') ?? '')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    final style = element.getAttribute('style');
    final borderColor = _parseBorderColorFromStyle(style);

    final children = _childElements(element);
    if (children.length != 1) {
      throw MathMLParseException(
        message: '<menclose> requires exactly one child.',
        elementName: 'menclose',
      );
    }

    final child = children.single;
    MathColor? backgroundColor;
    GreenNode baseNode;
    if (_localName(child) == 'mstyle' && child.getAttribute('mathbackground') != null) {
      backgroundColor = _parseColor(child.getAttribute('mathbackground')!);
      baseNode = _parseContainer(child);
    } else {
      baseNode = _parseElement(child);
    }

    return EnclosureNode(
      base: baseNode.wrapWithEquationRow(),
      hasBorder: notation.contains('box') || borderColor != null,
      borderColor: borderColor,
      backgroundColor: backgroundColor,
      notation: notation,
    );
  }

  GreenNode _parsePadded(XmlElement element) {
    final children = _childElements(element);
    if (children.length != 1) {
      throw MathMLParseException(
        message: '<mpadded> requires exactly one child.',
        elementName: 'mpadded',
      );
    }

    final childElement = children.single;
    final childNode = _parseElement(childElement);
    final width = element.getAttribute('width');
    final height = element.getAttribute('height');
    final depth = element.getAttribute('depth');
    final voffset = element.getAttribute('voffset');

    if (_localName(childElement) == 'mphantom') {
      return PhantomNodeModel(
        phantomChild: _extractPhantomBody(childNode),
        zeroWidth: width == '0em',
        zeroHeight: height == '0em',
        zeroDepth: depth == '0em',
      );
    }

    if (voffset != null) {
      return RaiseBoxNodeModel(
        body: childNode.wrapWithEquationRow(),
        dy: _parseMeasurement(voffset),
      );
    }

    return childNode;
  }

  GreenNode _parsePhantom(XmlElement element) {
    final children = _childElements(element);
    if (children.length != 1) {
      throw MathMLParseException(
        message: '<mphantom> requires exactly one child.',
        elementName: 'mphantom',
      );
    }
    return PhantomNodeModel(
      phantomChild: _parseElement(children.single).wrapWithEquationRow(),
    );
  }

  OptionsDiff _parseOptionsDiff(XmlElement element) {
    MathStyle? style;
    final displayStyle = element.getAttribute('displaystyle');
    final scriptLevel = element.getAttribute('scriptlevel');
    if (displayStyle != null || scriptLevel != null) {
      final level = int.tryParse(scriptLevel ?? '0') ?? 0;
      if (_isTruthy(displayStyle)) {
        style = MathStyle.display;
      } else if (level <= 0) {
        style = MathStyle.text;
      } else if (level == 1) {
        style = MathStyle.script;
      } else {
        style = MathStyle.scriptscript;
      }
    }

    MathSize? size;
    final mathSize = element.getAttribute('mathsize');
    if (mathSize != null) {
      size = _parseMathSize(mathSize);
    }

    MathColor? color;
    final mathColor = element.getAttribute('mathcolor');
    if (mathColor != null) {
      color = _parseColor(mathColor);
    }

    final mathVariant = element.getAttribute('mathvariant');
    final font = _parseMathVariant(mathVariant);

    return OptionsDiff(
      style: style,
      size: size,
      color: color,
      mathFontOptions: font,
    );
  }

  List<GreenNode> _textToNodes(String text, {required Mode mode}) =>
      stringToNode(text, mode).children;
}

String _localName(XmlElement element) => element.name.local;

List<XmlElement> _childElements(XmlElement element) =>
    element.children.whereType<XmlElement>().toList(growable: false);

void _expectChildCount(
  XmlElement element,
  List<XmlElement> children,
  int expected,
) {
  if (children.length != expected) {
    throw MathMLParseException(
      message:
          'Expected $expected child elements but found ${children.length}.',
      elementName: _localName(element),
    );
  }
}

AtomType? _inferOperatorAtomType(XmlElement element, String symbol) {
  if (_isTruthy(element.getAttribute('separator'))) {
    return AtomType.punct;
  }
  if (_isTruthy(element.getAttribute('fence'))) {
    if (_openDelimiters.contains(symbol)) {
      return AtomType.open;
    }
    if (_closeDelimiters.contains(symbol)) {
      return AtomType.close;
    }
    return AtomType.open;
  }
  if (_isTruthy(element.getAttribute('largeop')) || _largeOperatorSymbols.contains(symbol)) {
    return AtomType.op;
  }
  if (_relationSymbols.contains(symbol)) {
    return AtomType.rel;
  }
  if (_binarySymbols.contains(symbol)) {
    return AtomType.bin;
  }
  if (_punctuationSymbols.contains(symbol)) {
    return AtomType.punct;
  }
  return AtomType.ord;
}

String? _extractSingleSymbol(GreenNode node) {
  if (node is SymbolNode) {
    return node.symbol;
  }
  if (node is EquationRowNode &&
      node.children.length == 1 &&
      node.children.first is SymbolNode) {
    return (node.children.first as SymbolNode).symbol;
  }
  return null;
}

String _extractOperatorLabel(GreenNode? node) {
  final symbol = node == null ? null : _extractSingleSymbol(node);
  if (symbol == null) {
    throw const MathMLParseException(
      message: 'Expected a single-symbol operator label.',
      elementName: 'mo',
    );
  }
  return symbol;
}

String? _childAttribute(XmlElement element, String name) => element.getAttribute(name);

bool _isTruthy(String? value) =>
    value != null && (value == 'true' || value == '1');

FontOptions? _parseMathVariant(String? value) {
  switch (value) {
    case null:
    case '':
      return null;
    case 'normal':
      return const FontOptions(fontFamily: 'Main');
    case 'bold':
      return const FontOptions(
        fontFamily: 'Main',
        fontWeight: MathFontWeight.bold,
      );
    case 'italic':
      return const FontOptions(
        fontFamily: 'Main',
        fontShape: MathFontStyle.italic,
      );
    case 'bold-italic':
      return const FontOptions(
        fontFamily: 'Main',
        fontWeight: MathFontWeight.bold,
        fontShape: MathFontStyle.italic,
      );
    case 'double-struck':
      return const FontOptions(fontFamily: 'AMS');
    case 'fraktur':
      return const FontOptions(fontFamily: 'Fraktur');
    case 'bold-fraktur':
      return const FontOptions(
        fontFamily: 'Fraktur',
        fontWeight: MathFontWeight.bold,
      );
    case 'script':
      return const FontOptions(fontFamily: 'Script');
    case 'bold-script':
      return const FontOptions(
        fontFamily: 'Script',
        fontWeight: MathFontWeight.bold,
      );
    case 'sans-serif':
      return const FontOptions(fontFamily: 'SansSerif');
    case 'bold-sans-serif':
      return const FontOptions(
        fontFamily: 'SansSerif',
        fontWeight: MathFontWeight.bold,
      );
    case 'sans-serif-italic':
      return const FontOptions(
        fontFamily: 'SansSerif',
        fontShape: MathFontStyle.italic,
      );
    case 'sans-serif-bold-italic':
      return const FontOptions(
        fontFamily: 'SansSerif',
        fontWeight: MathFontWeight.bold,
        fontShape: MathFontStyle.italic,
      );
    case 'monospace':
      return const FontOptions(fontFamily: 'Typewriter');
    default:
      throw MathMLParseException(
        message: 'Unsupported mathvariant "$value".',
        elementName: 'mathvariant',
      );
  }
}

MathColor _parseColor(String value) {
  final normalized = value.trim();
  if (normalized.startsWith('#')) {
    final hex = normalized.substring(1);
    if (hex.length == 6) {
      return MathColor(int.parse('ff$hex', radix: 16));
    }
    if (hex.length == 8) {
      return MathColor(int.parse(hex, radix: 16));
    }
  }
  final rgbaMatch = RegExp(
    r'^rgba\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*([0-9.]+)\s*\)$',
  ).firstMatch(normalized);
  if (rgbaMatch != null) {
    final alpha = (double.parse(rgbaMatch.group(4)!) * 255).round().clamp(0, 255);
    return MathColor.fromARGB(
      alpha,
      int.parse(rgbaMatch.group(1)!),
      int.parse(rgbaMatch.group(2)!),
      int.parse(rgbaMatch.group(3)!),
    );
  }
  throw MathMLParseException(
    message: 'Unsupported color value "$value".',
    elementName: 'color',
  );
}

MathSize _parseMathSize(String value) {
  final normalized = value.trim();
  if (!normalized.endsWith('%')) {
    throw MathMLParseException(
      message: 'Unsupported mathsize "$value".',
      elementName: 'mathsize',
    );
  }
  final number = double.parse(normalized.substring(0, normalized.length - 1));
  var bestSize = MathSize.normalsize;
  var bestDiff = double.infinity;
  for (final size in MathSize.values) {
    final diff = (size.sizeMultiplier * 100 - number).abs();
    if (diff < bestDiff) {
      bestDiff = diff;
      bestSize = size;
    }
  }
  return bestSize;
}

Measurement _parseMeasurement(String value) {
  final match = RegExp(
    r'^\s*([+-]?(?:\d+(?:\.\d+)?|\.\d+))\s*([A-Za-z%]+)\s*$',
  ).firstMatch(value);
  if (match == null) {
    throw MathMLParseException(
      message: 'Invalid measurement "$value".',
      elementName: 'measurement',
    );
  }
  final rawUnit = match.group(2)!;
  final unit = switch (rawUnit) {
    'in' => Unit.inches,
    '%' => Unit.cssEm,
    _ => rawUnit.parseUnit(),
  };
  if (unit == null) {
    throw MathMLParseException(
      message: 'Unknown measurement unit "$rawUnit".',
      elementName: 'measurement',
    );
  }
  final rawValue = double.parse(match.group(1)!);
  if (rawUnit == '%') {
    return Measurement(value: rawValue / 100, unit: Unit.cssEm);
  }
  return Measurement(value: rawValue, unit: unit);
}

Measurement _parseMeasurementOrZero(String? value) =>
    value == null ? Measurement.zero : _parseMeasurement(value);

List<Measurement> _parseMeasurementList(String? value) {
  if (value == null || value.trim().isEmpty) {
    return const <Measurement>[];
  }
  return value
      .trim()
      .split(RegExp(r'\s+'))
      .map(_parseMeasurement)
      .toList(growable: false);
}

MatrixSeparatorStyle _parseSeparatorStyle(String? value) {
  switch (value) {
    case null:
    case '':
    case 'none':
      return MatrixSeparatorStyle.none;
    case 'solid':
      return MatrixSeparatorStyle.solid;
    case 'dashed':
      return MatrixSeparatorStyle.dashed;
    default:
      throw MathMLParseException(
        message: 'Unsupported separator style "$value".',
        elementName: 'separator',
      );
  }
}

List<MatrixSeparatorStyle> _parseSeparatorStyleList(String? value) {
  if (value == null || value.trim().isEmpty) {
    return const <MatrixSeparatorStyle>[];
  }
  return value
      .trim()
      .split(RegExp(r'\s+'))
      .map(_parseSeparatorStyle)
      .toList(growable: false);
}

List<MatrixColumnAlign> _parseColumnAligns(String? value) {
  if (value == null || value.trim().isEmpty) {
    return const <MatrixColumnAlign>[];
  }
  return value
      .trim()
      .split(RegExp(r'\s+'))
      .map((token) {
        switch (token) {
          case 'left':
            return MatrixColumnAlign.left;
          case 'center':
            return MatrixColumnAlign.center;
          case 'right':
            return MatrixColumnAlign.right;
          default:
            throw MathMLParseException(
              message: 'Unsupported column alignment "$token".',
              elementName: 'mtable',
            );
        }
      })
      .toList(growable: false);
}

List<MatrixSeparatorStyle> _expandWithOuterFrame(
  List<MatrixSeparatorStyle> innerValues,
  int slotCount,
  MatrixSeparatorStyle frameStyle,
) {
  if (slotCount <= 0) {
    return const <MatrixSeparatorStyle>[];
  }
  final list = <MatrixSeparatorStyle>[
    frameStyle,
    ...innerValues,
    frameStyle,
  ];
  if (list.length >= slotCount + 1) {
    return list.take(slotCount + 1).toList(growable: false);
  }
  return List<MatrixSeparatorStyle>.generate(
    slotCount + 1,
    (index) => index < list.length ? list[index] : MatrixSeparatorStyle.none,
    growable: false,
  );
}

EquationRowNode _tableRowToEquationArrayRow(List<EquationRowNode?> cells) {
  final children = <GreenNode>[];
  for (var index = 0; index < cells.length; index++) {
    final cell = cells[index];
    if (cell != null) {
      children.addAll(cell.children);
    }
    if (index != cells.length - 1) {
      children.add(SpaceNodeModel.alignerOrSpacer());
    }
  }
  return EquationRowNode(children: children);
}

MathColor? _parseBorderColorFromStyle(String? style) {
  if (style == null || style.trim().isEmpty) {
    return null;
  }
  final match = RegExp(r'border-color\s*:\s*([^;]+)').firstMatch(style);
  if (match == null) {
    return null;
  }
  return _parseColor(match.group(1)!.trim());
}

EquationRowNode _extractPhantomBody(GreenNode node) {
  if (node is PhantomNodeModel) {
    return node.phantomChild;
  }
  return node.wrapWithEquationRow();
}
