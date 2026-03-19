import '../../widgets/exception.dart';

class ParseException implements FlutterMathException {
  ParseException(
    this.message, {
    this.position,
    this.cause,
  });

  factory ParseException.fromTex(Object cause, {int? position}) {
    if (cause is ParseException) {
      return cause;
    }
    return ParseException(
      cause is Exception ? cause.toString() : '$cause',
      position: position,
      cause: cause,
    );
  }

  final int? position;
  final String message;
  final Object? cause;

  @override
  String get messageWithType => 'Parser Error: $message';
}
