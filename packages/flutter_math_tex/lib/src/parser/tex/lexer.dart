import 'parse_error.dart';
import 'settings.dart';
import 'source_location.dart';
import 'token.dart';

const String spaceRegexString = r'[ \r\n\t]';
const String controlWordRegexString = r'\\[a-zA-Z@]+';
const String controlSymbolRegexString = '\\\\[^\\uD800-\\uDFFF]';
const String controlWordWhitespaceRegexString =
    '$controlWordRegexString$spaceRegexString*';
final RegExp controlWordWhitespaceRegex = RegExp(
  '^($controlWordRegexString)$spaceRegexString*\$',
);
const String combiningDiacriticalMarkString = r'[\u0300-\u036f]';
final RegExp combiningDiacriticalMarksEndRegex = RegExp(
  '$combiningDiacriticalMarkString+\$',
);
const String tokenRegexString =
    '($spaceRegexString+)|'
    '([!-\\[\\]-\u2027\u202A-\uD7FF\uF900-\uFFFF]'
    '$combiningDiacriticalMarkString*'
    '|[\uD800-\uDBFF][\uDC00-\uDFFF]'
    '$combiningDiacriticalMarkString*'
    r'|\\verb\*([^]).*?\3'
    r'|\\verb([^*a-zA-Z]).*?\4'
    r'|\\operatorname\*'
    '|$controlWordWhitespaceRegexString'
    '|$controlSymbolRegexString)';

/// Public lexer interface used by source-location objects.
abstract class LexerInterface {
  String get input;

  static final RegExp tokenRegex = RegExp(tokenRegexString, multiLine: true);
}

/// Lexer that tokenizes TeX input.
class Lexer implements LexerInterface {
  static final RegExp tokenRegex = RegExp(tokenRegexString, multiLine: true);

  Lexer(this.input, this.settings) : it = tokenRegex.allMatches(input).iterator;

  @override
  final String input;
  final TexParserSettings settings;
  final Map<String, int> catCodes = <String, int>{'%': 14};
  int pos = 0;
  final Iterator<RegExpMatch> it;

  Token lex() {
    if (pos == input.length) {
      return Token('EOF', SourceLocation(this, pos, pos));
    }

    final hasMatch = it.moveNext();
    if (!hasMatch) {
      throw ParseException(
        "Unexpected character: '${input[pos]}'",
        Token(input[pos], SourceLocation(this, pos, pos + 1)),
      );
    }

    final match = it.current;
    if (match.start != pos) {
      throw ParseException(
        "Unexpected character: '${input[pos]}'",
        Token(input[pos], SourceLocation(this, pos, pos + 1)),
      );
    }
    pos = match.end;

    var text = match[2] ?? ' ';
    if (text == '%') {
      final nlIndex = input.indexOf('\n', it.current.end);
      if (nlIndex == -1) {
        pos = input.length;
        while (it.moveNext()) {
          pos = it.current.end;
        }
        settings.reportNonstrict(
          'commentAtEnd',
          '% comment has no terminating newline; LaTeX would fail because '
              r'of commenting the end of math mode (e.g. $)',
        );
      } else {
        while (it.current.end < nlIndex + 1) {
          final canMoveNext = it.moveNext();
          if (!canMoveNext) {
            break;
          }
          pos = it.current.end;
        }
      }
      return lex();
    }

    final controlMatch = controlWordWhitespaceRegex.firstMatch(text);
    if (controlMatch != null) {
      text = controlMatch.group(1)!;
    }
    return Token(text, SourceLocation(this, match.start, match.end));
  }
}
