import 'package:flutter/widgets.dart';
import 'package:flutter_math_model/ast.dart';

import '../../lite_math_options.dart';

class LiteMatrix extends StatelessWidget {
  const LiteMatrix({
    super.key,
    required this.body,
    required this.options,
    required this.columnAligns,
    required this.vLines,
    required this.hLines,
    required this.rowSpacings,
    this.isSmall = false,
    this.hskipBeforeAndAfter = false,
  });

  final List<List<Widget?>> body;
  final LiteMathOptions options;
  final List<MatrixColumnAlign> columnAligns;
  final List<MatrixSeparatorStyle> vLines;
  final List<MatrixSeparatorStyle> hLines;
  final List<double> rowSpacings;
  final bool isSmall;
  final bool hskipBeforeAndAfter;

  @override
  Widget build(BuildContext context) {
    final cellPadding = EdgeInsets.symmetric(
      horizontal: options.fontSize * (isSmall ? 0.08 : 0.16),
      vertical: options.fontSize * (isSmall ? 0.04 : 0.08),
    );

    final table = Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: _buildBorder(),
      children: List<TableRow>.generate(
        body.length,
        (rowIndex) => TableRow(
          children: List<Widget>.generate(
            body[rowIndex].length,
            (columnIndex) => Padding(
              padding: cellPadding.add(
                EdgeInsets.symmetric(
                  vertical:
                      rowIndex < rowSpacings.length ? rowSpacings[rowIndex] : 0,
                ),
              ),
              child: Align(
                alignment: _mapAlignment(columnAligns[columnIndex]),
                child: body[rowIndex][columnIndex] ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        growable: false,
      ),
    );

    if (!hskipBeforeAndAfter) {
      return table;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: options.fontSize * 0.2),
      child: table,
    );
  }

  TableBorder? _buildBorder() {
    final color = options.color;
    final width = options.lineThickness;
    final hasVerticalInside =
        vLines.skip(1).take(vLines.length - 2).any(_hasLineStyle);
    final hasHorizontalInside =
        hLines.skip(1).take(hLines.length - 2).any(_hasLineStyle);

    return TableBorder(
      left: _hasLineStyle(vLines.first)
          ? BorderSide(color: color, width: width)
          : BorderSide.none,
      right: _hasLineStyle(vLines.last)
          ? BorderSide(color: color, width: width)
          : BorderSide.none,
      top: _hasLineStyle(hLines.first)
          ? BorderSide(color: color, width: width)
          : BorderSide.none,
      bottom: _hasLineStyle(hLines.last)
          ? BorderSide(color: color, width: width)
          : BorderSide.none,
      verticalInside: hasVerticalInside
          ? BorderSide(color: color, width: width)
          : BorderSide.none,
      horizontalInside: hasHorizontalInside
          ? BorderSide(color: color, width: width)
          : BorderSide.none,
    );
  }

  static Alignment _mapAlignment(MatrixColumnAlign align) {
    switch (align) {
      case MatrixColumnAlign.left:
        return Alignment.centerLeft;
      case MatrixColumnAlign.center:
        return Alignment.center;
      case MatrixColumnAlign.right:
        return Alignment.centerRight;
    }
  }

  static bool _hasLineStyle(MatrixSeparatorStyle style) =>
      style != MatrixSeparatorStyle.none;
}
