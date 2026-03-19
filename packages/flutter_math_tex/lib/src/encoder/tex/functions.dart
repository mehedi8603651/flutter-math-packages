library tex_encoder_functions;

import 'package:collection/collection.dart';

import '../../ast.dart';
import '../../parser/tex/font.dart';
import '../../parser/tex/functions.dart';
import '../../parser/tex/functions/katex_base.dart';
import '../../parser/tex/symbols_composite.dart';
import '../../parser/tex/symbols.dart';
import '../../utils/alpha_numeric.dart';
import '../../utils/unicode_literal.dart';
import '../encoder.dart';
import '../matcher.dart';
import '../optimization.dart';
import 'encoder.dart';

part 'functions/accent.dart';
part 'functions/accent_under.dart';
part 'functions/frac.dart';
part 'functions/function.dart';
part 'functions/left_right.dart';
part 'functions/multiscripts.dart';
part 'functions/nary.dart';
part 'functions/sqrt.dart';
part 'functions/stretchy_op.dart';
part 'functions/style.dart';
part 'functions/symbol.dart';

const Map<Type, EncoderFun> encoderFunctions = {
  EquationRowNode: _equationRowNodeEncoderFun,
  AccentNode: _accentEncoder,
  AccentUnderNode: _accentUnderEncoder,
  FracNode: _fracEncoder,
  FunctionNode: _functionEncoder,
  LeftRightNode: _leftRightEncoder,
  MultiscriptsNode: _multisciprtsEncoder,
  NaryOperatorNode: _naryEncoder,
  SqrtNode: _sqrtEncoder,
  StretchyOpNode: _stretchyOpEncoder,
  SymbolNode: _symbolEncoder,
  StyleNode: _styleEncoder,
};

EncodeResult _equationRowNodeEncoderFun(GreenNode node) =>
    EquationRowTexEncodeResult((node as EquationRowNode)
        .children
        .map(encodeTex)
        .toList(growable: false));

final optimizationEntries = [
  ..._fracOptimizationEntries,
  ..._functionOptimizationEntries,
]..sortBy<num>((entry) => -entry.priority);
