import '../../ast.dart';
import 'functions/katex_base.dart';
import 'functions/katex_ext.dart';
import 'parser.dart';
import 'registry.dart' as shared;
import 'token.dart';

typedef FunctionContext = shared.FunctionContext<GreenNode, Token>;

typedef FunctionHandler<T extends GreenNode> = T Function(
  TexParser parser,
  FunctionContext context,
);

class FunctionSpec<T extends GreenNode>
    extends shared.FunctionSpec<TexParser, T, Token> {
  const FunctionSpec({
    required this.numArgs,
    this.greediness = 1,
    this.allowedInText = false,
    this.allowedInMath = true,
    this.numOptionalArgs = 0,
    this.infix = false,
    required this.handler,
    this.argModes,
  }) : super(
         numArgs: numArgs,
         greediness: greediness,
         allowedInText: allowedInText,
         allowedInMath: allowedInMath,
         numOptionalArgs: numOptionalArgs,
         infix: infix,
         handler: handler,
         argModes: argModes,
       );

  @override
  final int numArgs;

  @override
  final int greediness;

  @override
  final bool allowedInText;

  @override
  final bool allowedInMath;

  @override
  final int numOptionalArgs;

  @override
  final bool infix;

  @override
  final FunctionHandler<T> handler;

  @override
  final List<Mode?>? argModes;
}

extension RegisterFunctionExt on Map<String, FunctionSpec> {
  void registerFunctions(Map<List<String>, FunctionSpec> entries) {
    shared.registerFunctionEntries(this, entries);
  }
}

final Map<String, FunctionSpec> functions = <String, FunctionSpec>{}
  ..registerFunctions(katexBaseFunctionEntries)
  ..registerFunctions(katexExtFunctionEntries);
