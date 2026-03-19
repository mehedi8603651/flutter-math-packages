import 'package:flutter/widgets.dart';

import '../ast/options.dart';

class BuildResult {
  final Widget widget;
  final MathOptions options;
  final double italic;
  final double skew;
  final List<BuildResult>? results;

  const BuildResult({
    required this.widget,
    required this.options,
    this.italic = 0.0,
    this.skew = 0.0,
    this.results,
  });
}
