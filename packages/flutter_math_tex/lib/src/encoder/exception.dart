class EncoderException implements Exception {
  final String message;
  final dynamic token;

  const EncoderException(this.message, [this.token]);

  String get messageWithType => 'Encoder Exception: $message';

  @override
  String toString() => messageWithType;
}
