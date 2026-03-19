/// Parser configuration for MathML import.
class MathMLParserSettings {
  /// If true, allow fragment parsing without a `<math>` root wrapper.
  final bool allowRootlessFragment;

  /// If true, parse `<mtable>` with all-left column alignment as equation
  /// arrays when possible. Otherwise tables always parse as matrices.
  final bool preferEquationArrays;

  const MathMLParserSettings({
    this.allowRootlessFragment = true,
    this.preferEquationArrays = true,
  });
}
