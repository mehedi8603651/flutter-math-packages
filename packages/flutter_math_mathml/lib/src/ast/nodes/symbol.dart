import 'package:flutter_math_model/ast.dart' as math_model;

/// MathML-side concrete symbol node.
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

  math_model.SymbolNodeModel get sharedModel => _model;

  math_model.AtomType get atomType =>
      overrideAtomType ?? math_model.AtomType.ord;

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
}

math_model.EquationRowNode stringToNode(
  String string, [
  math_model.Mode mode = math_model.Mode.text,
]) =>
    math_model.EquationRowNode(
      children: string
          .runes
          .map(
            (rune) => SymbolNode(
              symbol: String.fromCharCode(rune),
              mode: mode,
            ),
          )
          .toList(growable: false),
    );
