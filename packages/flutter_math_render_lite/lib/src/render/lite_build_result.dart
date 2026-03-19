import 'package:flutter/widgets.dart';

import '../lite_math_options.dart';

@immutable
class LiteBuildResult {
  const LiteBuildResult({
    required this.widget,
    required this.options,
  });

  final Widget widget;
  final LiteMathOptions options;
}
