import 'package:flutter_math_model/flutter_math_model.dart' show Mode;

/// Lookup contract used by the TeX front-end to ask whether names are defined.
abstract interface class TexDefinitionLookup {
  bool hasFunction(String name);

  bool hasSymbol(Mode mode, String name);
}

/// Default no-op lookup used while the parser AST layer is still migrating.
class EmptyTexDefinitionLookup implements TexDefinitionLookup {
  const EmptyTexDefinitionLookup();

  @override
  bool hasFunction(String name) => false;

  @override
  bool hasSymbol(Mode mode, String name) => false;
}
