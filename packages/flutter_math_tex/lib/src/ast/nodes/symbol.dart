import 'package:flutter_math_model/ast.dart' as math_model
    show AtomType, EquationRowNode, FontOptions, LeafNode, Mode, SymbolNodeModel;

import '../../parser/tex/symbols.dart';
import '../../utils/unicode_literal.dart';

class SymbolNode extends math_model.LeafNode {
  final math_model.SymbolNodeModel _model;

  SymbolNode({
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

  String get symbol => _model.symbol;

  bool get variantForm => _model.variantForm;

  math_model.AtomType? get overrideAtomType => _model.overrideAtomType;

  math_model.FontOptions? get overrideFont => _model.overrideFont;

  @override
  math_model.Mode get mode => _model.mode;

  late final math_model.AtomType atomType =
      overrideAtomType ?? _inferAtomTypeForSymbol();

  math_model.SymbolNodeModel get sharedModel => _model;

  @override
  math_model.AtomType get leftType => atomType;

  @override
  math_model.AtomType get rightType => atomType;

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll(
      _model.toJsonWith(
        modeValue: mode.toString(),
        symbolValue: unicodeLiteral(symbol),
        overrideAtomTypeValue: overrideAtomType?.toString(),
        overrideFontValue: overrideFont?.toString(),
      ),
    );

  SymbolNode withSymbol(String symbol) {
    if (symbol == this.symbol) {
      return this;
    }
    return SymbolNode(
      symbol: symbol,
      variantForm: variantForm,
      overrideAtomType: overrideAtomType,
      overrideFont: overrideFont,
      mode: mode,
    );
  }

  math_model.AtomType _inferAtomTypeForSymbol() {
    final configs = texSymbolCommandConfigs[mode];
    if (configs == null) {
      return math_model.AtomType.ord;
    }

    math_model.AtomType? bestMatch;
    var bestScore = -1;
    for (final entry in configs.entries) {
      final config = entry.value;
      if (config.symbol != symbol ||
          config.variantForm != variantForm ||
          config.type == null) {
        continue;
      }

      var score = 0;
      if (entry.key == symbol) {
        score += 100;
      }
      if (!entry.key.startsWith(r'\')) {
        score += 50;
      }
      if (config.font == overrideFont) {
        score += 10;
      }
      if (score > bestScore) {
        bestScore = score;
        bestMatch = config.type;
      }
    }
    return bestMatch ?? math_model.AtomType.ord;
  }
}

math_model.EquationRowNode stringToNode(
  String string, [
  math_model.Mode mode = math_model.Mode.text,
]) =>
    math_model.EquationRowNode(
      children: string
          .split('')
          .map((char) => SymbolNode(symbol: char, mode: mode))
          .toList(growable: false),
    );
