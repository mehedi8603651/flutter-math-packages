import 'token.dart';

/// Exception thrown by the TeX front-end.
class ParseException implements Exception {
  int? position;
  String message;
  final Token? token;

  ParseException(String message, [this.token]) : message = message {
    final loc = token?.loc;
    if (loc != null && loc.start <= loc.end) {
      final input = loc.lexer.input;
      final start = loc.start;
      position = start;
      final end = loc.end;

      var resolvedMessage = start == input.length
          ? '$message at end of input: '
          : '$message at position ${start + 1}: ';
      final underlined = input
          .substring(start, end)
          .replaceAllMapped(RegExp(r'[^]'), (match) => '${match[0]}\u0332');

      if (start > 15) {
        resolvedMessage =
            '$resolvedMessage...${input.substring(start - 15, start)}$underlined';
      } else {
        resolvedMessage =
            '$resolvedMessage${input.substring(0, start)}$underlined';
      }
      if (end + 15 < input.length) {
        resolvedMessage =
            '$resolvedMessage${input.substring(end, end + 15)}...';
      } else {
        resolvedMessage = '$resolvedMessage${input.substring(end)}';
      }
      this.message = resolvedMessage;
    }
  }

  String get messageWithType => 'Parser Error: $message';

  @override
  String toString() => messageWithType;
}
