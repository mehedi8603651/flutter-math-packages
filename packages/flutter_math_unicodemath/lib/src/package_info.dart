/// Immutable package metadata for bootstrap and migration tooling.
class FlutterMathUnicodeMathPackageInfo {
  final String name;
  final String version;
  final String summary;

  const FlutterMathUnicodeMathPackageInfo({
    required this.name,
    required this.version,
    required this.summary,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is FlutterMathUnicodeMathPackageInfo &&
        other.name == name &&
        other.version == version &&
        other.summary == summary;
  }

  @override
  int get hashCode => Object.hash(name, version, summary);
}

const flutterMathUnicodeMathPackageName = 'flutter_math_unicodemath';
const flutterMathUnicodeMathPackageVersion = '0.1.0';
const flutterMathUnicodeMathPackageSummary =
    'UnicodeMath frontend package for the flutter_math package family.';

const flutterMathUnicodeMathPackageInfo = FlutterMathUnicodeMathPackageInfo(
  name: flutterMathUnicodeMathPackageName,
  version: flutterMathUnicodeMathPackageVersion,
  summary: flutterMathUnicodeMathPackageSummary,
);
