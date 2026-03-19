import 'parse_error.dart';

/// TeX-style scoped namespace with group push/pop semantics.
class Namespace<T> {
  Namespace(this.builtins, Map<String, T> current)
    : current = Map<String, T>.from(current);

  final Map<String, T> current;
  final Map<String, T> builtins;
  final List<Map<String, T?>> undefStack = <Map<String, T?>>[];

  T? get(String name) => current[name] ?? builtins[name];

  void set(String name, T value, {bool global = false}) {
    if (global) {
      for (final undef in undefStack) {
        undef.remove(name);
      }
      if (undefStack.isNotEmpty) {
        undefStack.last[name] = value;
      }
    } else if (undefStack.isNotEmpty) {
      undefStack.last[name] = current[name];
    }
    current[name] = value;
  }

  bool has(String name) =>
      current.containsKey(name) || builtins.containsKey(name);

  void beginGroup() {
    undefStack.add(<String, T?>{});
  }

  void endGroup() {
    if (undefStack.isEmpty) {
      throw ParseException(
        'Unbalanced namespace destruction: attempt to pop global namespace.',
      );
    }
    final undefs = undefStack.removeLast();
    undefs.forEach((key, value) {
      if (value == null) {
        current.remove(key);
      } else {
        current[key] = value;
      }
    });
  }
}
