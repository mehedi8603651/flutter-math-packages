import 'package:flutter/widgets.dart';
import 'package:flutter_math_model/ast.dart' as math_model show SymbolNodeModel;

import '../../render/symbols/make_symbol.dart';
import '../../utils/unicode_literal.dart';
import '../options.dart';
import '../symbols/symbols.dart';
import '../symbols/symbols_composite.dart';
import '../symbols/symbols_extra.dart';
import '../symbols/symbols_unicode.dart';
import '../symbols/unicode_accents.dart';
import '../syntax_tree.dart';
import '../types.dart';
import 'accent.dart';

/// Node for an unbreakable symbol.
class SymbolNode extends LeafNode {
  final math_model.SymbolNodeModel _model;

  /// Effective atom type for this symbol;
  late final AtomType atomType = overrideAtomType ??
      getDefaultAtomTypeForSymbol(symbol, variantForm: variantForm, mode: mode);

  // bool get noBreak => symbol == '\u00AF';

  SymbolNode({
    required String symbol,
    bool variantForm = false,
    AtomType? overrideAtomType,
    FontOptions? overrideFont,
    Mode mode = Mode.math,
  }) : _model = math_model.SymbolNodeModel(
          symbol: symbol,
          variantForm: variantForm,
          overrideAtomType: overrideAtomType,
          overrideFont: overrideFont,
          mode: mode,
        );

  /// Unicode symbol.
  String get symbol => _model.symbol;

  /// Whether it is a varaint form.
  ///
  /// Refer to MathJaX's variantForm
  bool get variantForm => _model.variantForm;

  /// Overriding atom type;
  AtomType? get overrideAtomType => _model.overrideAtomType;

  /// Overriding atom font;
  FontOptions? get overrideFont => _model.overrideFont;

  @override
  Mode get mode => _model.mode;

  math_model.SymbolNodeModel get sharedModel => _model;

  @override
  BuildResult buildWidget(
      MathOptions options, List<BuildResult?> childBuildResults) {
    final expanded = symbol.runes.expand((code) {
      final ch = String.fromCharCode(code);
      return unicodeSymbols[ch]?.split('') ?? [ch];
    }).toList(growable: false);

    // If symbol is single code
    if (expanded.length == 1) {
      return makeBaseSymbol(
        symbol: expanded[0],
        variantForm: variantForm,
        atomType: atomType,
        overrideFont: overrideFont,
        mode: mode,
        options: options,
      );
    } else if (expanded.length > 1) {
      if (isCombiningMark(expanded[1])) {
        if (expanded[0] == 'i') {
          expanded[0] = '\u0131'; // dotless i, in math and text mode
        } else if (expanded[0] == 'j') {
          expanded[0] = '\u0237'; // dotless j, in math and text mode
        }
      }
      GreenNode res = this.withSymbol(expanded[0]);
      for (var ch in expanded.skip(1)) {
        final accent = unicodeAccents[ch];
        if (accent == null) {
          break;
        } else {
          res = AccentNode(
            base: res.wrapWithEquationRow(),
            label: accent,
            isStretchy: false,
            isShifty: true,
          );
        }
      }
      return SyntaxNode(parent: null, value: res, pos: 0).buildWidget(options);
    } else {
      //log a warning here.
      return BuildResult(
        widget: Container(
          height: 0,
          width: 0,
        ),
        options: options,
        italic: 0,
      );
    }
  }

  @override
  bool shouldRebuildWidget(MathOptions oldOptions, MathOptions newOptions) =>
      oldOptions.color != newOptions.color ||
      oldOptions.mathFontOptions != newOptions.mathFontOptions ||
      oldOptions.textFontOptions != newOptions.textFontOptions ||
      oldOptions.sizeMultiplier != newOptions.sizeMultiplier;

  @override
  AtomType get leftType => atomType;

  @override
  AtomType get rightType => atomType;

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll(_model.toJsonWith(
      modeValue: mode.toString(),
      symbolValue: unicodeLiteral(symbol),
      overrideAtomTypeValue: overrideAtomType?.toString(),
    ));

  SymbolNode withSymbol(String symbol) {
    if (symbol == this.symbol) return this;
    return SymbolNode(
      symbol: symbol,
      variantForm: variantForm,
      overrideAtomType: overrideAtomType,
      overrideFont: overrideFont,
      mode: mode,
    );
  }
}

EquationRowNode stringToNode(String string, [Mode mode = Mode.text]) =>
    EquationRowNode(
      children: string
          .split('')
          .map((ch) => SymbolNode(symbol: ch, mode: mode))
          .toList(growable: false),
    );

AtomType getDefaultAtomTypeForSymbol(
  String symbol, {
  bool variantForm = false,
  required Mode mode,
}) {
  var symbolRenderConfig = symbolRenderConfigs[symbol];
  if (variantForm) {
    symbolRenderConfig = symbolRenderConfig?.variantForm;
  }
  final renderConfig =
      mode == Mode.math ? symbolRenderConfig?.math : symbolRenderConfig?.text;
  if (renderConfig != null) {
    return renderConfig.defaultType ?? AtomType.ord;
  }
  if (variantForm == false && mode == Mode.math) {
    if (negatedOperatorSymbols.containsKey(symbol)) {
      return AtomType.rel;
    }
    if (compactedCompositeSymbols.containsKey(symbol)) {
      return compactedCompositeSymbolTypes[symbol]!;
    }
    if (decoratedEqualSymbols.contains(symbol)) {
      return AtomType.rel;
    }
  }
  return AtomType.ord;
}

bool isCombiningMark(String ch) {
  final code = ch.codeUnitAt(0);
  return code >= 0x0300 && code <= 0x036f;
}
