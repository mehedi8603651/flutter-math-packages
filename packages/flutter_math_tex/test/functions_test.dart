import 'package:flutter_math_tex/flutter_math_tex.dart';
import 'package:test/test.dart';

int _identityHandler(
  Object parser,
  FunctionContext<int, String> context,
) =>
    context.infixExistingArguments.length;

void main() {
  test('FunctionSpec exposes total argument count', () {
    const spec = FunctionSpec<Object, int, String>(
      numArgs: 2,
      numOptionalArgs: 1,
      argModes: <Mode?>[Mode.math, Mode.text, null],
      handler: _identityHandler,
    );

    expect(spec.totalArgs, 3);
    expect(spec.argModes, <Mode?>[Mode.math, Mode.text, null]);
  });

  test('registerFunctionEntries expands command aliases', () {
    const spec = FunctionSpec<Object, int, String>(
      numArgs: 0,
      handler: _identityHandler,
    );
    final registry = <String, FunctionSpec<Object, int, String>>{};

    registerFunctionEntries<Object, int, String,
        FunctionSpec<Object, int, String>>(registry, <List<String>,
        FunctionSpec<Object, int, String>>{
      <String>[r'\foo', r'\bar']: spec,
    });

    expect(registry[r'\foo'], same(spec));
    expect(registry[r'\bar'], same(spec));
  });
}
