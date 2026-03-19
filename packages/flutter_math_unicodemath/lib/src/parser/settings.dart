/// Parser settings for the UnicodeMath frontend.
class UnicodeMathParserSettings {
  final bool parseFunctionApplication;
  final bool parseNaryOperators;

  const UnicodeMathParserSettings({
    this.parseFunctionApplication = true,
    this.parseNaryOperators = true,
  });
}
