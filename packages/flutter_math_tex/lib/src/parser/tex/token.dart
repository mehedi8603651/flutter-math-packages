import 'source_location.dart';

/// Token emitted by the TeX lexer.
class Token {
  String text;
  SourceLocation? loc;
  bool noexpand = false;
  bool treatAsRelax = false;

  Token(this.text, [this.loc]);

  static Token range(Token startToken, Token endToken, String text) =>
      Token(text, SourceLocation.range(startToken, endToken));
}
