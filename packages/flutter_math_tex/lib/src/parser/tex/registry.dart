import 'package:flutter_math_model/flutter_math_model.dart' show Mode;

/// Parsing context passed to TeX function handlers.
class FunctionContext<TNode, TToken> {
  final String funcName;
  final TToken? token;
  final String? breakOnTokenText;
  final List<TNode> infixExistingArguments;

  const FunctionContext({
    required this.funcName,
    this.token,
    required this.breakOnTokenText,
    this.infixExistingArguments = const [],
  });
}

/// Signature of a TeX function handler.
typedef FunctionHandler<TParser, TNode, TToken> =
    TNode Function(TParser parser, FunctionContext<TNode, TToken> context);

/// Shared parser function metadata.
class FunctionSpec<TParser, TNode, TToken> {
  final int numArgs;
  final int greediness;
  final bool allowedInText;
  final bool allowedInMath;
  final int numOptionalArgs;
  final bool infix;
  final FunctionHandler<TParser, TNode, TToken> handler;

  // Serves as hint during encoding.
  final List<Mode?>? argModes;

  const FunctionSpec({
    required this.numArgs,
    this.greediness = 1,
    this.allowedInText = false,
    this.allowedInMath = true,
    this.numOptionalArgs = 0,
    this.infix = false,
    required this.handler,
    this.argModes,
  });

  int get totalArgs => numArgs + numOptionalArgs;
}

/// Registers multiple command aliases against a function spec.
void registerFunctionEntries<TParser, TNode, TToken,
    TSpec extends FunctionSpec<TParser, TNode, TToken>>(
  Map<String, TSpec> registry,
  Map<List<String>, TSpec> entries,
) {
  entries.forEach((names, spec) {
    for (final name in names) {
      registry[name] = spec;
    }
  });
}
