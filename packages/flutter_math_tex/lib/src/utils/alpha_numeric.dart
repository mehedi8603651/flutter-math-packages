final int _code0 = '0'.codeUnitAt(0);
final int _code9 = '9'.codeUnitAt(0);
final int _codeA = 'A'.codeUnitAt(0);
final int _codeZ = 'Z'.codeUnitAt(0);
final int _codea = 'a'.codeUnitAt(0);
final int _codez = 'z'.codeUnitAt(0);

bool isAlphaNumericUnit(String symbol) {
  assert(symbol.length == 1);
  final code = symbol.codeUnitAt(0);
  return (code >= _code0 && code <= _code9) ||
      (code >= _codeA && code <= _codeZ) ||
      (code >= _codea && code <= _codez);
}
