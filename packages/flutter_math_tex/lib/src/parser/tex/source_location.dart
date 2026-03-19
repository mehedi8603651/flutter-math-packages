import 'lexer.dart';
import 'token.dart';

/// Source range within the lexer input.
class SourceLocation {
  final LexerInterface lexer;
  final int start;
  final int end;

  SourceLocation(this.lexer, this.start, this.end);

  static SourceLocation? range(Token first, [Token? second]) {
    if (second == null) {
      return first.loc;
    }
    if (first.loc == null ||
        second.loc == null ||
        first.loc!.lexer != second.loc!.lexer) {
      return null;
    }
    return SourceLocation(first.loc!.lexer, first.loc!.start, second.loc!.end);
  }
}
