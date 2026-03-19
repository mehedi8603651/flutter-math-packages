/// Thrown when MathML parsing fails.
class MathMLParseException implements Exception {
  final String message;
  final String? elementName;

  const MathMLParseException({
    required this.message,
    this.elementName,
  });

  @override
  String toString() => elementName == null
      ? 'MathMLParseException: $message'
      : 'MathMLParseException($elementName): $message';
}
