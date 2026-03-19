/// Exception thrown when UnicodeMath parsing fails.
class UnicodeMathParseException implements Exception {
  final String message;
  final int position;

  const UnicodeMathParseException({
    required this.message,
    required this.position,
  });

  @override
  String toString() => 'UnicodeMathParseException($position): $message';
}
