import 'package:flutter/widgets.dart';
import 'package:flutter_math_model/ast.dart';

import '../../lite_math_options.dart';

class LiteEquationArray extends StatelessWidget {
  const LiteEquationArray({
    super.key,
    required this.rows,
    required this.options,
    required this.hlines,
    required this.rowSpacings,
    this.addJot = false,
    this.arrayStretch = 1.0,
  });

  final List<Widget> rows;
  final LiteMathOptions options;
  final List<MatrixSeparatorStyle> hlines;
  final List<double> rowSpacings;
  final bool addJot;
  final double arrayStretch;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final baseGap = options.fontSize * 0.12 * arrayStretch;
    final jotGap = addJot ? options.fontSize * 0.3 : 0.0;

    if (_hasLineStyle(hlines.first)) {
      children.add(_buildDivider());
    }

    for (var index = 0; index < rows.length; index++) {
      children.add(rows[index]);
      final spacing = index < rowSpacings.length ? rowSpacings[index] : 0.0;
      if (spacing > 0 || jotGap > 0 || index < rows.length - 1) {
        children.add(SizedBox(height: baseGap + jotGap + spacing));
      }
      if (index + 1 < hlines.length - 1 && _hasLineStyle(hlines[index + 1])) {
        children.add(_buildDivider());
      }
    }

    if (_hasLineStyle(hlines.last)) {
      children.add(_buildDivider());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildDivider() => Container(
        height: options.lineThickness,
        color: options.color,
      );

  static bool _hasLineStyle(MatrixSeparatorStyle style) =>
      style != MatrixSeparatorStyle.none;
}
