/// Immutable package metadata for bootstrap and migration tooling.
class FlutterMathModelPackageInfo {
  final String name;
  final String version;
  final String summary;

  const FlutterMathModelPackageInfo({
    required this.name,
    required this.version,
    required this.summary,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is FlutterMathModelPackageInfo &&
        other.name == name &&
        other.version == version &&
        other.summary == summary;
  }

  @override
  int get hashCode => Object.hash(name, version, summary);
}

const flutterMathModelPackageName = 'flutter_math_model';
const flutterMathModelPackageVersion = '0.1.0';
const flutterMathModelPackageSummary =
    'Shared AST and editing model layer for the flutter_math package family.';

const flutterMathModelPackageInfo = FlutterMathModelPackageInfo(
  name: flutterMathModelPackageName,
  version: flutterMathModelPackageVersion,
  summary: flutterMathModelPackageSummary,
);
