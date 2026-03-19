import 'package:flutter_math_model/ast.dart' as math_model;

class LiteSymbolNode extends math_model.LeafNode {
  LiteSymbolNode({
    required String symbol,
    bool variantForm = false,
    math_model.AtomType? overrideAtomType,
    math_model.FontOptions? overrideFont,
    math_model.Mode mode = math_model.Mode.math,
  }) : _model = math_model.SymbolNodeModel(
         symbol: symbol,
         variantForm: variantForm,
         overrideAtomType: overrideAtomType,
         overrideFont: overrideFont,
         mode: mode,
       );

  final math_model.SymbolNodeModel _model;

  String get symbol => _model.symbol;

  bool get variantForm => _model.variantForm;

  math_model.AtomType? get overrideAtomType => _model.overrideAtomType;

  math_model.FontOptions? get overrideFont => _model.overrideFont;

  @override
  math_model.Mode get mode => _model.mode;

  late final math_model.AtomType atomType =
      overrideAtomType ?? _inferAtomType(symbol);

  math_model.SymbolNodeModel get sharedModel => _model;

  @override
  math_model.AtomType get leftType => atomType;

  @override
  math_model.AtomType get rightType => atomType;

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll(
      _model.toJsonWith(
        symbolValue: symbol,
        modeValue: mode.toString(),
        overrideAtomTypeValue: overrideAtomType?.toString(),
        overrideFontValue: overrideFont?.toString(),
      ),
    );

  LiteSymbolNode withSymbol(String symbol) {
    if (symbol == this.symbol) {
      return this;
    }
    return LiteSymbolNode(
      symbol: symbol,
      variantForm: variantForm,
      overrideAtomType: overrideAtomType,
      overrideFont: overrideFont,
      mode: mode,
    );
  }

  static math_model.AtomType _inferAtomType(String symbol) {
    if (_openSymbols.contains(symbol)) {
      return math_model.AtomType.open;
    }
    if (_closeSymbols.contains(symbol)) {
      return math_model.AtomType.close;
    }
    if (_punctuationSymbols.contains(symbol)) {
      return math_model.AtomType.punct;
    }
    if (_relationSymbols.contains(symbol)) {
      return math_model.AtomType.rel;
    }
    if (_binarySymbols.contains(symbol)) {
      return math_model.AtomType.bin;
    }
    return math_model.AtomType.ord;
  }
}

math_model.EquationRowNode stringToLiteRow(
  String string, [
  math_model.Mode mode = math_model.Mode.text,
]) =>
    math_model.EquationRowNode(
      children: string
          .split('')
          .map((char) => LiteSymbolNode(symbol: char, mode: mode))
          .toList(growable: false),
    );

const Set<String> _openSymbols = <String>{'(', '[', '{', '|', '⌈', '⌊'};
const Set<String> _closeSymbols = <String>{')', ']', '}', '|', '⌉', '⌋'};
const Set<String> _punctuationSymbols = <String>{',', ';', ':'};
const Set<String> _binarySymbols = <String>{
  '+',
  '-',
  '*',
  '×',
  '÷',
  '±',
  '∓',
  '∪',
  '∩',
  '⊕',
  '⊗',
  '⋅',
};
const Set<String> _relationSymbols = <String>{
  '=',
  '<',
  '>',
  '≤',
  '≥',
  '≈',
  '≅',
  '≃',
  '∈',
  '∉',
  '⊂',
  '⊆',
  '⊃',
  '⊇',
};
