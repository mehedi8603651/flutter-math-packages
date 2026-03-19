String fixedHex(int number, int length) {
  var str = number.toRadixString(16).toUpperCase();
  str = str.padLeft(length, '0');
  return str;
}

String unicodeLiteral(String str, {bool escape = false}) =>
    str.split('').map((char) {
      if (char.codeUnitAt(0) > 126 || char.codeUnitAt(0) < 32) {
        return '\\u${fixedHex(char.codeUnitAt(0), 4)}';
      }
      if (escape && (char == '\'' || char == r'$')) {
        return '\\$char';
      }
      return char;
    }).join();
