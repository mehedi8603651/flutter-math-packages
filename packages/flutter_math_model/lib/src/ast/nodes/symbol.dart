import '../options.dart';
import '../syntax_tree.dart' show AtomType;
import '../types.dart' show Mode;

/// Generic parser-facing model for a single symbol token.
class SymbolNodeModel {
  final String symbol;
  final bool variantForm;
  final AtomType? overrideAtomType;
  final FontOptions? overrideFont;
  final Mode mode;

  const SymbolNodeModel({
    required this.symbol,
    this.variantForm = false,
    this.overrideAtomType,
    this.overrideFont,
    this.mode = Mode.math,
  }) : assert(symbol != '');

  SymbolNodeModel copyWith({
    String? symbol,
    bool? variantForm,
    AtomType? overrideAtomType,
    FontOptions? overrideFont,
    Mode? mode,
  }) =>
      SymbolNodeModel(
        symbol: symbol ?? this.symbol,
        variantForm: variantForm ?? this.variantForm,
        overrideAtomType: overrideAtomType ?? this.overrideAtomType,
        overrideFont: overrideFont ?? this.overrideFont,
        mode: mode ?? this.mode,
      );

  SymbolNodeModel withSymbol(String symbol) {
    if (symbol == this.symbol) {
      return this;
    }
    return copyWith(symbol: symbol);
  }

  Map<String, Object?> toJsonWith({
    required Object? symbolValue,
    required Object? modeValue,
    Object? overrideAtomTypeValue,
    Object? overrideFontValue,
  }) =>
      <String, Object?>{
        'mode': modeValue,
        'symbol': symbolValue,
        if (variantForm) 'variantForm': variantForm,
        if (overrideAtomType != null) 'atomType': overrideAtomTypeValue,
        if (overrideFont != null && overrideFontValue != null)
          'overrideFont': overrideFontValue,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymbolNodeModel &&
          other.symbol == symbol &&
          other.variantForm == variantForm &&
          other.overrideAtomType == overrideAtomType &&
          other.overrideFont == overrideFont &&
          other.mode == mode;

  @override
  int get hashCode =>
      Object.hash(symbol, variantForm, overrideAtomType, overrideFont, mode);
}
