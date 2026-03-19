import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_math_model/ast.dart' show MatrixSeparatorStyle;

import '../constants.dart';
import '../utils/render_box_offset.dart';
import '../utils/render_box_layout.dart';
import 'line.dart';

class EqnArrayParentData extends ContainerBoxParentData<RenderBox> {}

class EqnArray extends MultiChildRenderObjectWidget {
  final double ruleThickness;
  final double jotSize;
  final double arrayskip;
  final List<MatrixSeparatorStyle> hlines;
  final List<double> rowSpacings;

  EqnArray({
    super.key,
    required this.ruleThickness,
    required this.jotSize,
    required this.arrayskip,
    required this.hlines,
    required this.rowSpacings,
    required super.children,
  });

  @override
  RenderEqnArray createRenderObject(BuildContext context) => RenderEqnArray(
        ruleThickness: ruleThickness,
        jotSize: jotSize,
        arrayskip: arrayskip,
        hlines: hlines,
        rowSpacings: rowSpacings,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderEqnArray renderObject,
  ) {
    renderObject
      ..ruleThickness = ruleThickness
      ..jotSize = jotSize
      ..arrayskip = arrayskip
      ..hlines = hlines
      ..rowSpacings = rowSpacings;
  }
}

class RenderEqnArray extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, EqnArrayParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, EqnArrayParentData>,
        DebugOverflowIndicatorMixin {
  RenderEqnArray({
    List<RenderBox>? children,
    required double ruleThickness,
    required double jotSize,
    required double arrayskip,
    required List<MatrixSeparatorStyle> hlines,
    required List<double> rowSpacings,
  })  : _ruleThickness = ruleThickness,
        _jotSize = jotSize,
        _arrayskip = arrayskip,
        _hlines = hlines,
        _rowSpacings = rowSpacings {
    addAll(children);
  }

  double get ruleThickness => _ruleThickness;
  double _ruleThickness;
  set ruleThickness(double value) {
    if (_ruleThickness != value) {
      _ruleThickness = value;
      markNeedsLayout();
    }
  }

  double get jotSize => _jotSize;
  double _jotSize;
  set jotSize(double value) {
    if (_jotSize != value) {
      _jotSize = value;
      markNeedsLayout();
    }
  }

  double get arrayskip => _arrayskip;
  double _arrayskip;
  set arrayskip(double value) {
    if (_arrayskip != value) {
      _arrayskip = value;
      markNeedsLayout();
    }
  }

  List<MatrixSeparatorStyle> get hlines => _hlines;
  List<MatrixSeparatorStyle> _hlines;
  set hlines(List<MatrixSeparatorStyle> value) {
    if (_hlines != value) {
      _hlines = value;
      markNeedsLayout();
    }
  }

  List<double> get rowSpacings => _rowSpacings;
  List<double> _rowSpacings;
  set rowSpacings(List<double> value) {
    if (_rowSpacings != value) {
      _rowSpacings = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! EqnArrayParentData) {
      child.parentData = EqnArrayParentData();
    }
  }

  List<double> hlinePos = const <double>[];
  double width = 0.0;

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _computeLayout(constraints);

  @override
  void performLayout() {
    size = _computeLayout(constraints, dry: false);
  }

  Size _computeLayout(
    BoxConstraints constraints, {
    bool dry = true,
  }) {
    final nonAligningSizes = <Size>[];
    var child = firstChild;
    var resolvedWidth = 0.0;
    final colWidths = <double>[];
    final sizeMap = <RenderBox, Size>{};
    while (child != null) {
      late final Size childSize;
      if (child is RenderLine) {
        child.alignColWidth = null;
        childSize = child.getLayoutSize(infiniteConstraint, dry: dry);
        final childColWidth = child.alignColWidth;
        if (childColWidth != null) {
          for (var i = 0; i < childColWidth.length; i++) {
            if (i >= colWidths.length) {
              colWidths.add(childColWidth[i]);
            } else {
              colWidths[i] = math.max(colWidths[i], childColWidth[i]);
            }
          }
        } else {
          nonAligningSizes.add(childSize);
        }
      } else {
        childSize = child.getLayoutSize(infiniteConstraint, dry: dry);
        if (colWidths.isEmpty) {
          colWidths.add(childSize.width);
        } else {
          colWidths[0] = math.max(colWidths[0], childSize.width);
        }
      }
      sizeMap[child] = childSize;
      child = (child.parentData as EqnArrayParentData).nextSibling;
    }

    final nonAligningChildrenWidth = _maxWidth(nonAligningSizes);
    final aligningChildrenWidth =
        colWidths.fold<double>(0.0, (sum, width) => sum + width);
    resolvedWidth = math.max(nonAligningChildrenWidth, aligningChildrenWidth);

    var index = 0;
    var vPos = 0.0;
    if (!dry) {
      hlinePos = <double>[vPos];
    }
    index++;
    child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as EqnArrayParentData;
      var hPos = 0.0;
      final childSize = sizeMap[child] ?? Size.zero;
      if (child is RenderLine && child.alignColWidth != null) {
        child.alignColWidth = colWidths;
        child.layout(
          BoxConstraints(maxWidth: aligningChildrenWidth),
          parentUsesSize: true,
        );
        hPos = (resolvedWidth - aligningChildrenWidth) / 2 +
            colWidths[0] -
            child.alignColWidth![0];
      } else {
        hPos = (resolvedWidth - childSize.width) / 2;
      }
      final layoutHeight = dry ? 0 : child.layoutHeight;
      final layoutDepth = dry ? childSize.height : child.layoutDepth;

      vPos += math.max(layoutHeight, 0.7 * arrayskip);
      if (!dry) {
        childParentData.offset = Offset(hPos, vPos - child.layoutHeight);
      }
      vPos += math.max(layoutDepth, 0.3 * arrayskip) +
          jotSize +
          rowSpacings[index - 1];
      if (!dry) {
        hlinePos = <double>[...hlinePos, vPos];
      }
      vPos += hlines[index] != MatrixSeparatorStyle.none ? ruleThickness : 0.0;
      index++;

      child = childParentData.nextSibling;
    }

    if (!dry) {
      width = resolvedWidth;
    }

    return Size(resolvedWidth, vPos);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
    for (var i = 0; i < hlines.length; i++) {
      if (hlines[i] != MatrixSeparatorStyle.none) {
        context.canvas.drawLine(
          Offset(0, hlinePos[i] + ruleThickness / 2),
          Offset(width, hlinePos[i] + ruleThickness / 2),
          Paint()..strokeWidth = ruleThickness,
        );
      }
    }
  }
}

double _maxWidth(List<Size> sizes) {
  var maxWidth = 0.0;
  for (final size in sizes) {
    maxWidth = math.max(maxWidth, size.width);
  }
  return maxWidth;
}
