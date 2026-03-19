/// Shared model layer for the `flutter_math` package family.
///
/// This package is intended to hold renderer-agnostic structures such as the
/// AST, editing model, and shared semantic helpers used by TeX, UnicodeMath,
/// MathML, and renderer packages.
library;

export 'src/package_info.dart'
    show
        FlutterMathModelPackageInfo,
        flutterMathModelPackageInfo,
        flutterMathModelPackageName,
        flutterMathModelPackageSummary,
        flutterMathModelPackageVersion;
export 'ast.dart';
