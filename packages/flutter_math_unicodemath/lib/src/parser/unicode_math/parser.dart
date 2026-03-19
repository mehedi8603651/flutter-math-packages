import 'package:flutter_math_model/ast.dart';

import '../../ast.dart' show EnclosureNode, SymbolNode;
import '../../encoder/unicode_math/style_mapping.dart'
    show decodeMathAlphabetStyle;
import '../parse_exception.dart';
import '../settings.dart';

const _sqrtSymbol = '\u221A';

const _openToClose = <String, String>{
  '(': ')',
  '[': ']',
  '{': '}',
};

const _functionNames = <String>{
  'arccos',
  'arcsin',
  'arctan',
  'cos',
  'cosh',
  'cot',
  'coth',
  'csc',
  'deg',
  'det',
  'dim',
  'exp',
  'gcd',
  'hom',
  'inf',
  'ker',
  'lg',
  'lim',
  'liminf',
  'limsup',
  'ln',
  'log',
  'max',
  'min',
  'mod',
  'Pr',
  'sec',
  'sin',
  'sinh',
  'sup',
  'tan',
  'tanh',
};

const _naryOperators = <String>{
  '\u2211', // sum
  '\u220F', // prod
  '\u2210', // coprod
  '\u222B', // int
  '\u222C', // iint
  '\u222D', // iiint
  '\u222E', // contour int
  '\u22C0', // bigwedge
  '\u22C1', // bigvee
  '\u22C2', // bigcap
  '\u22C3', // bigcup
};

const _accentLabelByCombining = <String, String>{
  '\u0302': '^',
  '\u0303': '~',
  '\u0304': '\u00AF',
  '\u0306': '\u02D8',
  '\u0307': '\u02D9',
  '\u0308': '\u00A8',
  '\u030A': '\u02DA',
  '\u030B': '\u02DD',
  '\u030C': '\u02C7',
};

const _underAccentLabelByCombining = <String, String>{
  '\u0332': '_',
  '\u0331': '\u00AF',
  '\u0330': '~',
};

EquationRowNode parseUnicodeMath(
  String input, {
  UnicodeMathParserSettings settings = const UnicodeMathParserSettings(),
}) =>
    UnicodeMathParser(input, settings: settings).parse();

extension StringUnicodeMathParseExt on String {
  EquationRowNode parseUnicodeMath({
    UnicodeMathParserSettings settings = const UnicodeMathParserSettings(),
  }) =>
      UnicodeMathParser(this, settings: settings).parse();
}

class UnicodeMathParser {
  final String input;
  final UnicodeMathParserSettings settings;

  late final List<String> _chars =
      input.runes.map(String.fromCharCode).toList(growable: false);

  int _index = 0;

  UnicodeMathParser(
    this.input, {
    this.settings = const UnicodeMathParserSettings(),
  });

  EquationRowNode parse() {
    final result = _parseSequence(const <String>{});
    _skipWhitespace();
    if (!_isAtEnd) {
      throw _error('Unexpected trailing input.');
    }
    return result;
  }

  EquationRowNode _parseSequence(Set<String> stopChars) {
    final children = <GreenNode>[];

    while (true) {
      _skipWhitespace();
      final char = _peek();
      if (char == null || stopChars.contains(char)) {
        break;
      }
      if (char == '&') {
        _advance();
        children.add(SpaceNodeModel.alignerOrSpacer());
        continue;
      }
      if (char == '@') {
        throw _error('Unexpected row separator.');
      }
      children.add(_parseFraction());
    }

    return EquationRowNode(children: children);
  }

  GreenNode _parseFraction() {
    var left = _parsePostfix();

    while (true) {
      _skipWhitespace();
      if (_peek() != '/') {
        break;
      }
      _advance();
      _skipWhitespace();
      final right = _parsePostfix();
      left = FracNodeModel(
        numerator: left.wrapWithEquationRow(),
        denominator: right.wrapWithEquationRow(),
      );
    }

    return left;
  }

  GreenNode _parsePostfix() {
    var node = _parsePrimary();

    while (true) {
      _skipWhitespace();
      final char = _peek();
      if (char == '_' || char == '^') {
        _advance();
        final operand = _parseScriptOperand();
        node = _applyScript(
          node,
          sub: char == '_' ? operand : null,
          sup: char == '^' ? operand : null,
        );
        continue;
      }

      final accentLabel = _accentLabelByCombining[char];
      if (accentLabel != null) {
        _advance();
        node = AccentNodeModel(
          base: node.wrapWithEquationRow(),
          label: accentLabel,
          isStretchy: false,
          isShifty: true,
        );
        continue;
      }

      final underAccentLabel = _underAccentLabelByCombining[char];
      if (underAccentLabel != null) {
        _advance();
        node = AccentUnderNodeModel(
          base: node.wrapWithEquationRow(),
          label: underAccentLabel,
        );
        continue;
      }

      break;
    }

    final hadWhitespace = _skipWhitespace();
    if (hadWhitespace &&
        settings.parseNaryOperators &&
        _canStartImplicitArgument(_peek())) {
      final naryData = _extractNaryData(node);
      if (naryData != null) {
        final argument = _parseFraction();
        return NaryOperatorNodeModel(
          operator: naryData.operator,
          lowerLimit: naryData.lowerLimit,
          upperLimit: naryData.upperLimit,
          naryand: argument.wrapWithEquationRow(),
        );
      }
    }

    if (hadWhitespace &&
        settings.parseFunctionApplication &&
        _canStartImplicitArgument(_peek())) {
      final functionName = _extractFunctionName(node);
      if (functionName != null && _functionNames.contains(functionName)) {
        final argument = _parseFraction();
        return FunctionNodeModel(
          functionName: node.wrapWithEquationRow(),
          argument: argument.wrapWithEquationRow(),
        );
      }
    }

    return node;
  }

  GreenNode _parseScriptOperand() {
    _skipWhitespace();
    final char = _peek();
    if (char == null) {
      throw _error('Expected script operand.');
    }
    if (_openToClose.containsKey(char) || char == '\\' || char == _sqrtSymbol) {
      return _parsePrimary();
    }
    return _parseWordOrSymbolRun();
  }

  GreenNode _parsePrimary() {
    final char = _peek();
    if (char == null) {
      throw _error('Unexpected end of input.');
    }
    if (_openToClose.containsKey(char)) {
      return _parseDelimitedGroup(char);
    }
    if (char == '\\') {
      return _parseCommand();
    }
    if (char == _sqrtSymbol) {
      return _parseRoot();
    }
    return _parseWordOrSymbolRun();
  }

  GreenNode _parseDelimitedGroup(String open) {
    final close = _openToClose[open]!;
    _expect(open);
    final body = _parseSequence(<String>{close});
    _expect(close);
    return LeftRightNodeModel(
      leftDelim: open,
      rightDelim: close,
      body: <EquationRowNode>[body],
    );
  }

  GreenNode _parseRoot() {
    _expect(_sqrtSymbol);
    _skipWhitespace();

    if (_peek() == '(') {
      final segments = _parseParenthesizedSegments(
        allowedSeparators: const <String>{'&'},
      );
      if (segments.length == 1) {
        return SqrtNodeModel(
          index: null,
          base: segments.first,
        );
      }
      if (segments.length == 2) {
        return SqrtNodeModel(
          index: segments[1],
          base: segments[0],
        );
      }
      throw _error('Root syntax allows at most one index separator.');
    }

    final base = _parsePostfix();
    return SqrtNodeModel(
      index: null,
      base: base.wrapWithEquationRow(),
    );
  }

  GreenNode _parseCommand() {
    _expect('\\');
    final buffer = StringBuffer();
    while (true) {
      final char = _peek();
      if (char == null || !_isAsciiLetter(char)) {
        break;
      }
      buffer.write(_advance());
    }

    final command = buffer.toString();
    if (command.isEmpty) {
      throw _error('Expected command name after \\.');
    }

    switch (command) {
      case 'accent':
        final label = _parseRawParenthesizedText();
        final body = _parseParenthesizedBody();
        return AccentNodeModel(
          base: body,
          label: label,
          isStretchy: false,
          isShifty: true,
        );
      case 'color':
        final colorText = _parseBraceText();
        final body = _parseParenthesizedBody();
        return StyleNode(
          children: <GreenNode>[body],
          optionsDiff: OptionsDiff(
            color: _parseColor(colorText),
          ),
        );
      case 'enclose':
        final notationText = _parseRawParenthesizedText();
        final body = _parseParenthesizedBody();
        final notation = notationText
            .split(',')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList(growable: false);
        return EnclosureNode(
          base: body,
          hasBorder: notation.contains('box'),
          notation: notation,
        );
      case 'eqarray':
        return _parseEquationArrayCommand();
      case 'hphantom':
        return PhantomNodeModel(
          phantomChild: _parseParenthesizedBody(),
          zeroWidth: true,
        );
      case 'matrix':
        return _parseMatrixCommand();
      case 'overset':
        final above = _parseParenthesizedBody();
        final base = _parseParenthesizedBody();
        return OverNodeModel(
          base: base,
          above: above,
        );
      case 'phantom':
        return PhantomNodeModel(
          phantomChild: _parseParenthesizedBody(),
        );
      case 'raise':
        final dyText = _parseRawParenthesizedText();
        final body = _parseParenthesizedBody();
        return RaiseBoxNodeModel(
          body: body,
          dy: _parseMeasurement(dyText),
        );
      case 'size':
        final sizeText = _parseRawParenthesizedText();
        final body = _parseParenthesizedBody();
        return StyleNode(
          children: <GreenNode>[body],
          optionsDiff: OptionsDiff(
            size: _parseMathSize(sizeText),
          ),
        );
      case 'style':
        final styleText = _parseRawParenthesizedText();
        final body = _parseParenthesizedBody();
        final style = parseMathStyle(styleText.trim());
        if (style == null) {
          throw _error('Unknown math style "$styleText".');
        }
        return StyleNode(
          children: <GreenNode>[body],
          optionsDiff: OptionsDiff(style: style),
        );
      case 'underaccent':
        final label = _parseRawParenthesizedText();
        final body = _parseParenthesizedBody();
        return AccentUnderNodeModel(
          base: body,
          label: label,
        );
      case 'underset':
        final below = _parseParenthesizedBody();
        final base = _parseParenthesizedBody();
        return UnderNodeModel(
          base: base,
          below: below,
        );
      case 'vphantom':
        return PhantomNodeModel(
          phantomChild: _parseParenthesizedBody(),
          zeroHeight: true,
          zeroDepth: true,
        );
      default:
        throw _error('Unsupported UnicodeMath command \\$command.');
    }
  }

  MatrixNodeModel _parseMatrixCommand() {
    _expect('(');
    final rows = <List<EquationRowNode?>>[];
    var currentRow = <EquationRowNode?>[];

    while (true) {
      _skipWhitespace();
      final char = _peek();
      if (char == null) {
        throw _error('Unterminated \\matrix command.');
      }
      if (char == ')') {
        _advance();
        rows.add(currentRow);
        return MatrixNodeModel(body: rows);
      }

      final cell = _parseSequence(const <String>{'&', '@', ')'});
      currentRow.add(cell.children.isEmpty ? null : cell);

      final separator = _peek();
      if (separator == '&') {
        _advance();
        continue;
      }
      if (separator == '@') {
        _advance();
        rows.add(currentRow);
        currentRow = <EquationRowNode?>[];
        continue;
      }
      if (separator == ')') {
        continue;
      }
      throw _error('Unexpected matrix separator.');
    }
  }

  EquationArrayNodeModel _parseEquationArrayCommand() {
    _expect('(');
    final rows = <EquationRowNode>[];

    while (true) {
      _skipWhitespace();
      final char = _peek();
      if (char == null) {
        throw _error('Unterminated \\eqarray command.');
      }
      if (char == ')') {
        _advance();
        return EquationArrayNodeModel(body: rows);
      }

      rows.add(_parseSequence(const <String>{'@', ')'}));

      final separator = _peek();
      if (separator == '@') {
        _advance();
        continue;
      }
      if (separator == ')') {
        continue;
      }
      throw _error('Unexpected equation-array separator.');
    }
  }

  EquationRowNode _parseParenthesizedBody() {
    _expect('(');
    final body = _parseSequence(const <String>{')'});
    _expect(')');
    return body;
  }

  List<EquationRowNode> _parseParenthesizedSegments({
    required Set<String> allowedSeparators,
  }) {
    _expect('(');
    final segments = <EquationRowNode>[];

    while (true) {
      segments.add(_parseSequence({...allowedSeparators, ')'}));
      final separator = _peek();
      if (separator == ')') {
        _advance();
        return segments;
      }
      if (separator != null && allowedSeparators.contains(separator)) {
        _advance();
        continue;
      }
      throw _error('Unexpected separator inside parenthesized group.');
    }
  }

  String _parseRawParenthesizedText() {
    _expect('(');
    final buffer = StringBuffer();
    while (true) {
      final char = _peek();
      if (char == null) {
        throw _error('Unterminated parenthesized argument.');
      }
      if (char == ')') {
        _advance();
        return buffer.toString();
      }
      buffer.write(_advance());
    }
  }

  String _parseBraceText() {
    _expect('{');
    final buffer = StringBuffer();
    while (true) {
      final char = _peek();
      if (char == null) {
        throw _error('Unterminated brace argument.');
      }
      if (char == '}') {
        _advance();
        return buffer.toString();
      }
      buffer.write(_advance());
    }
  }

  GreenNode _parseWordOrSymbolRun() {
    final first = _peek();
    if (first == null) {
      throw _error('Unexpected end of input.');
    }

    if (_isWordLike(first)) {
      final children = <GreenNode>[];
      while (true) {
        final char = _peek();
        if (char == null || !_isWordLike(char)) {
          break;
        }
        children.add(_parseSymbolToken(_advance()));
      }
      return children.length == 1
          ? children.first
          : EquationRowNode(children: children);
    }

    return _parseSymbolToken(_advance());
  }

  GreenNode _parseSymbolToken(String char) {
    final decoded = decodeMathAlphabetStyle(char);
    if (decoded != null) {
      return SymbolNode(
        symbol: decoded.symbol,
        overrideFont: decoded.font,
      );
    }

    return SymbolNode(symbol: char);
  }

  GreenNode _applyScript(
    GreenNode base, {
    GreenNode? sub,
    GreenNode? sup,
  }) {
    if (base is MultiscriptsNodeModel) {
      return base.copyWith(
        sub: sub?.wrapWithEquationRow() ?? base.sub,
        sup: sup?.wrapWithEquationRow() ?? base.sup,
      );
    }

    return MultiscriptsNodeModel(
      base: base.wrapWithEquationRow(),
      sub: sub?.wrapWithEquationRow(),
      sup: sup?.wrapWithEquationRow(),
    );
  }

  _NaryData? _extractNaryData(GreenNode node) {
    final symbol = _extractSingleSymbol(node);
    if (symbol != null && _naryOperators.contains(symbol)) {
      return _NaryData(operator: symbol);
    }

    if (node is MultiscriptsNodeModel &&
        node.presub == null &&
        node.presup == null) {
      final baseSymbol = _extractSingleSymbol(node.base);
      if (baseSymbol != null && _naryOperators.contains(baseSymbol)) {
        return _NaryData(
          operator: baseSymbol,
          lowerLimit: node.sub,
          upperLimit: node.sup,
        );
      }
    }

    return null;
  }

  String? _extractFunctionName(GreenNode node) {
    if (node is SymbolNode &&
        node.overrideFont == null &&
        node.symbol.length == 1 &&
        _isAsciiLetter(node.symbol)) {
      return node.symbol;
    }
    if (node is EquationRowNode) {
      final buffer = StringBuffer();
      for (final child in node.children) {
        if (child is! SymbolNode ||
            child.overrideFont != null ||
            child.symbol.length != 1 ||
            !_isAsciiLetter(child.symbol)) {
          return null;
        }
        buffer.write(child.symbol);
      }
      return buffer.isEmpty ? null : buffer.toString();
    }
    return null;
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

  bool _canStartImplicitArgument(String? char) {
    if (char == null) {
      return false;
    }
    if (_openToClose.containsKey(char)) {
      return true;
    }
    if (char == '\\' || char == _sqrtSymbol) {
      return true;
    }
    return _isWordLike(char);
  }

  bool _isWordLike(String char) {
    if (decodeMathAlphabetStyle(char) != null) {
      return true;
    }
    if (_isAsciiLetter(char) || _isAsciiDigit(char)) {
      return true;
    }
    return char.codeUnitAt(0) > 127 &&
        !_isCombiningAccent(char) &&
        !const <String>{'_', '^', '/', '&', '@', '\\'}.contains(char) &&
        !_openToClose.containsKey(char) &&
        !_openToClose.containsValue(char) &&
        char != _sqrtSymbol;
  }

  bool _isCombiningAccent(String char) =>
      _accentLabelByCombining.containsKey(char) ||
      _underAccentLabelByCombining.containsKey(char);

  MathColor _parseColor(String raw) {
    final normalized = raw.trim().replaceFirst(RegExp(r'^0x'), '');
    if (normalized.length != 8) {
      throw _error('Expected 8-digit ARGB color, got "$raw".');
    }
    return MathColor(int.parse(normalized, radix: 16));
  }

  MathSize _parseMathSize(String raw) {
    final normalized = raw.trim();
    for (final size in MathSize.values) {
      if (size.name == normalized) {
        return size;
      }
    }
    throw _error('Unknown math size "$raw".');
  }

  Measurement _parseMeasurement(String raw) {
    final match = RegExp(
      r'^\s*([+-]?(?:\d+(?:\.\d+)?|\.\d+))\s*([A-Za-z]+)\s*$',
    ).firstMatch(raw);
    if (match == null) {
      throw _error('Invalid measurement "$raw".');
    }
    final value = double.parse(match.group(1)!);
    final unit = match.group(2)!.parseUnit();
    if (unit == null) {
      throw _error('Unknown measurement unit "${match.group(2)}".');
    }
    return Measurement(value: value, unit: unit);
  }

  String _advance() {
    final char = _peek();
    if (char == null) {
      throw _error('Unexpected end of input.');
    }
    _index++;
    return char;
  }

  void _expect(String expected) {
    final actual = _advance();
    if (actual != expected) {
      throw _error('Expected "$expected" but found "$actual".');
    }
  }

  String? _peek([int offset = 0]) {
    final target = _index + offset;
    if (target < 0 || target >= _chars.length) {
      return null;
    }
    return _chars[target];
  }

  bool _skipWhitespace() {
    final start = _index;
    while (true) {
      final char = _peek();
      if (char == null || !_isWhitespace(char)) {
        break;
      }
      _index++;
    }
    return _index != start;
  }

  bool get _isAtEnd => _index >= _chars.length;

  UnicodeMathParseException _error(String message) =>
      UnicodeMathParseException(message: message, position: _index);
}

class _NaryData {
  final String operator;
  final EquationRowNode? lowerLimit;
  final EquationRowNode? upperLimit;

  const _NaryData({
    required this.operator,
    this.lowerLimit,
    this.upperLimit,
  });
}

bool _isWhitespace(String char) =>
    char == ' ' || char == '\n' || char == '\r' || char == '\t';

bool _isAsciiLetter(String char) {
  if (char.length != 1) {
    return false;
  }
  final codeUnit = char.codeUnitAt(0);
  return (codeUnit >= 0x41 && codeUnit <= 0x5A) ||
      (codeUnit >= 0x61 && codeUnit <= 0x7A);
}

bool _isAsciiDigit(String char) {
  if (char.length != 1) {
    return false;
  }
  final codeUnit = char.codeUnitAt(0);
  return codeUnit >= 0x30 && codeUnit <= 0x39;
}
