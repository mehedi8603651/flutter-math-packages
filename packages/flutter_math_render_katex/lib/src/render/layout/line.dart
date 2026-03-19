//ignore_for_file: lines_longer_than_80_chars
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../constants.dart';
import '../utils/render_box_offset.dart';
import '../utils/render_box_layout.dart';

class LineParentData extends ContainerBoxParentData<RenderBox> {
  bool canBreakBefore = false;

  BoxConstraints Function(double height, double depth)? customCrossSize;

  double trailingMargin = 0.0;

  bool alignerOrSpacer = false;

  @override
  String toString() =>
      '${super.toString()}; canBreakBefore = $canBreakBefore; customSize = ${customCrossSize != null}; trailingMargin = $trailingMargin; alignerOrSpacer = $alignerOrSpacer';
}

class LineElement extends ParentDataWidget<LineParentData> {
  final bool canBreakBefore;
  final BoxConstraints Function(double height, double depth)? customCrossSize;
  final double trailingMargin;
  final bool alignerOrSpacer;

  const LineElement({
    super.key,
    this.canBreakBefore = false,
    this.customCrossSize,
    this.trailingMargin = 0.0,
    this.alignerOrSpacer = false,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is LineParentData);
    final parentData = renderObject.parentData as LineParentData;
    var needsLayout = false;

    if (parentData.canBreakBefore != canBreakBefore) {
      parentData.canBreakBefore = canBreakBefore;
      needsLayout = true;
    }

    if (parentData.customCrossSize != customCrossSize) {
      parentData.customCrossSize = customCrossSize;
      needsLayout = true;
    }

    if (parentData.trailingMargin != trailingMargin) {
      parentData.trailingMargin = trailingMargin;
      needsLayout = true;
    }

    if (parentData.alignerOrSpacer != alignerOrSpacer) {
      parentData.alignerOrSpacer = alignerOrSpacer;
      needsLayout = true;
    }

    if (needsLayout) {
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('canBreakBefore',
        value: canBreakBefore, ifTrue: 'allow breaking before'));
    properties.add(FlagProperty('customSize',
        value: customCrossSize != null, ifTrue: 'using relative size'));
    properties.add(DoubleProperty('trailingMargin', trailingMargin));
    properties.add(FlagProperty('alignerOrSpacer',
        value: alignerOrSpacer, ifTrue: 'is a alignment symbol'));
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Line;
}

class Line extends MultiChildRenderObjectWidget {
  Line({
    super.key,
    this.crossAxisAlignment = CrossAxisAlignment.baseline,
    this.minDepth = 0.0,
    this.minHeight = 0.0,
    this.textBaseline = TextBaseline.alphabetic,
    this.textDirection,
    super.children = const [],
  });

  final CrossAxisAlignment crossAxisAlignment;
  final double minDepth;
  final double minHeight;
  final TextBaseline textBaseline;
  final TextDirection? textDirection;

  bool get _needTextDirection => true;

  @protected
  TextDirection? getEffectiveTextDirection(BuildContext context) =>
      textDirection ?? (_needTextDirection ? Directionality.of(context) : null);

  @override
  RenderLine createRenderObject(BuildContext context) => RenderLine(
        crossAxisAlignment: crossAxisAlignment,
        minDepth: minDepth,
        minHeight: minHeight,
        textBaseline: textBaseline,
        textDirection: getEffectiveTextDirection(context),
      );

  @override
  void updateRenderObject(BuildContext context, RenderLine renderObject) {
    renderObject
      ..crossAxisAlignment = crossAxisAlignment
      ..minDepth = minDepth
      ..minHeight = minHeight
      ..textBaseline = textBaseline
      ..textDirection = getEffectiveTextDirection(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<TextBaseline>('textBaseline', textBaseline,
        defaultValue: null));
    properties.add(EnumProperty<CrossAxisAlignment>(
        'crossAxisAlignment', crossAxisAlignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
  }
}

class RenderLine extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, LineParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, LineParentData>,
        DebugOverflowIndicatorMixin {
  RenderLine({
    List<RenderBox>? children,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.baseline,
    double minDepth = 0,
    double minHeight = 0,
    TextBaseline textBaseline = TextBaseline.alphabetic,
    TextDirection? textDirection = TextDirection.ltr,
  })  : _crossAxisAlignment = crossAxisAlignment,
        _minDepth = minDepth,
        _minHeight = minHeight,
        _textBaseline = textBaseline,
        _textDirection = textDirection {
    addAll(children);
  }

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment != value) {
      _crossAxisAlignment = value;
      markNeedsLayout();
    }
  }

  double get minDepth => _minDepth;
  double _minDepth;
  set minDepth(double value) {
    if (_minDepth != value) {
      _minDepth = value;
      markNeedsLayout();
    }
  }

  double get minHeight => _minHeight;
  double _minHeight;
  set minHeight(double value) {
    if (_minHeight != value) {
      _minHeight = value;
      markNeedsLayout();
    }
  }

  TextBaseline get textBaseline => _textBaseline;
  TextBaseline _textBaseline;
  set textBaseline(TextBaseline value) {
    if (_textBaseline != value) {
      _textBaseline = value;
      markNeedsLayout();
    }
  }

  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  bool get _debugHasNecessaryDirections {
    assert(textDirection != null,
        'Horizontal $runtimeType has a null textDirection, so the alignment cannot be resolved.');
    return true;
  }

  double? _overflow;
  bool get _hasOverflow => _overflow! > precisionErrorTolerance;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! LineParentData) {
      child.parentData = LineParentData();
    }
  }

  double _getIntrinsicSize({
    required Axis sizingDirection,
    required double extent,
    required double Function(RenderBox child, double extent) childSize,
  }) {
    if (sizingDirection == Axis.horizontal) {
      var inflexibleSpace = 0.0;
      var child = firstChild;
      while (child != null) {
        inflexibleSpace += childSize(child, extent);
        final childParentData = child.parentData as LineParentData;
        child = childParentData.nextSibling;
      }
      return inflexibleSpace;
    } else {
      var maxCrossSize = 0.0;
      var child = firstChild;
      while (child != null) {
        final childMainSize = child.getMaxIntrinsicWidth(double.infinity);
        final crossSize = childSize(child, childMainSize);
        maxCrossSize = math.max(maxCrossSize, crossSize);
        final childParentData = child.parentData as LineParentData;
        child = childParentData.nextSibling;
      }
      return maxCrossSize;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => _getIntrinsicSize(
        sizingDirection: Axis.horizontal,
        extent: height,
        childSize: (RenderBox child, double extent) =>
            child.getMinIntrinsicWidth(extent),
      );

  @override
  double computeMaxIntrinsicWidth(double height) => _getIntrinsicSize(
        sizingDirection: Axis.horizontal,
        extent: height,
        childSize: (RenderBox child, double extent) =>
            child.getMaxIntrinsicWidth(extent),
      );

  @override
  double computeMinIntrinsicHeight(double width) => _getIntrinsicSize(
        sizingDirection: Axis.vertical,
        extent: width,
        childSize: (RenderBox child, double extent) =>
            child.getMinIntrinsicHeight(extent),
      );

  @override
  double computeMaxIntrinsicHeight(double width) => _getIntrinsicSize(
        sizingDirection: Axis.vertical,
        extent: width,
        childSize: (RenderBox child, double extent) =>
            child.getMaxIntrinsicHeight(extent),
      );

  double maxHeightAboveBaseline = 0.0;
  double maxHeightAboveEndBaseline = 0.0;

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    assert(!debugNeedsLayout);
    return maxHeightAboveBaseline;
  }

  @protected
  late List<double> caretOffsets;

  List<double>? alignColWidth;

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
    assert(_debugHasNecessaryDirections);

    var maxHeightAboveBaseline = 0.0;
    var maxDepthBelowBaseline = 0.0;
    var child = firstChild;
    final relativeChildren = <RenderBox>[];
    final alignerAndSpacers = <RenderBox>[];
    final sizeMap = <RenderBox, Size>{};
    while (child != null) {
      final childParentData = child.parentData as LineParentData;
      if (childParentData.customCrossSize != null) {
        relativeChildren.add(child);
      } else if (childParentData.alignerOrSpacer) {
        alignerAndSpacers.add(child);
      } else {
        final childSize = child.getLayoutSize(infiniteConstraint, dry: dry);
        sizeMap[child] = childSize;
        final distance = dry ? 0.0 : child.getDistanceToBaseline(textBaseline)!;
        maxHeightAboveBaseline = math.max(maxHeightAboveBaseline, distance);
        maxDepthBelowBaseline =
            math.max(maxDepthBelowBaseline, childSize.height - distance);
      }
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }

    for (final child in relativeChildren) {
      final childParentData = child.parentData as LineParentData;
      assert(childParentData.customCrossSize != null);
      final childConstraints = childParentData.customCrossSize!(
          maxHeightAboveBaseline, maxDepthBelowBaseline);
      final childSize = child.getLayoutSize(childConstraints, dry: dry);
      sizeMap[child] = childSize;
      final distance = dry ? 0.0 : child.getDistanceToBaseline(textBaseline)!;
      maxHeightAboveBaseline = math.max(maxHeightAboveBaseline, distance);
      maxDepthBelowBaseline =
          math.max(maxDepthBelowBaseline, childSize.height - distance);
    }

    maxHeightAboveBaseline = math.max(maxHeightAboveBaseline, minHeight);
    maxDepthBelowBaseline = math.max(maxDepthBelowBaseline, minDepth);

    child = firstChild;
    var mainPos = 0.0;
    var lastColPosition = mainPos;
    final colWidths = <double>[];
    final localCaretOffsets = [mainPos];
    while (child != null) {
      final childParentData = child.parentData as LineParentData;
      var childSize = sizeMap[child] ?? Size.zero;
      if (childParentData.alignerOrSpacer) {
        final childConstraints = BoxConstraints.tightFor(width: 0.0);
        childSize = child.getLayoutSize(childConstraints, dry: dry);

        colWidths.add(mainPos - lastColPosition);
        lastColPosition = mainPos;
      }
      if (!dry) {
        childParentData.offset =
            Offset(mainPos, maxHeightAboveBaseline - child.layoutHeight);
      }
      mainPos += childSize.width + childParentData.trailingMargin;

      localCaretOffsets.add(mainPos);
      child = childParentData.nextSibling;
    }
    colWidths.add(mainPos - lastColPosition);

    var resultSize = constraints.constrain(
        Size(mainPos, maxHeightAboveBaseline + maxDepthBelowBaseline));

    if (!dry) {
      caretOffsets = localCaretOffsets;
      _overflow = mainPos - resultSize.width;
      this.maxHeightAboveBaseline = maxHeightAboveBaseline;
    } else {
      return resultSize;
    }

    if (alignerAndSpacers.isEmpty) {
      return resultSize;
    }

    if (alignColWidth == null) {
      alignColWidth = colWidths;
      return resultSize;
    }

    final resolvedAlignColWidth =
        List<double>.of(alignColWidth!, growable: false)..[0] = colWidths.first;
    alignColWidth = resolvedAlignColWidth;

    var aligner = true;
    var index = 0;
    for (final alignerOrSpacer in alignerAndSpacers) {
      if (aligner) {
        alignerOrSpacer.layout(BoxConstraints.tightFor(width: 0.0),
            parentUsesSize: true);
      } else {
        alignerOrSpacer.layout(
          BoxConstraints.tightFor(
            width: resolvedAlignColWidth[index] +
                (index + 1 < resolvedAlignColWidth.length - 1
                    ? resolvedAlignColWidth[index + 1]
                    : 0) -
                colWidths[index] -
                (index + 1 < colWidths.length - 1 ? colWidths[index + 1] : 0),
          ),
          parentUsesSize: true,
        );
      }
      aligner = !aligner;
      index++;
    }

    child = firstChild;
    mainPos = 0.0;
    caretOffsets
      ..clear()
      ..add(mainPos);
    while (child != null) {
      final childParentData = child.parentData as LineParentData;
      childParentData.offset =
          Offset(mainPos, maxHeightAboveBaseline - child.layoutHeight);
      mainPos += child.size.width + childParentData.trailingMargin;

      caretOffsets.add(mainPos);
      child = childParentData.nextSibling;
    }

    resultSize = constraints.constrain(
        Size(mainPos, maxHeightAboveBaseline + maxDepthBelowBaseline));
    _overflow = mainPos - resultSize.width;

    return resultSize;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_hasOverflow) {
      defaultPaint(context, offset);
      return;
    }

    if (size.isEmpty) {
      return;
    }

    context.pushClipRect(
        needsCompositing, offset, Offset.zero & size, defaultPaint);
    assert(() {
      final debugOverflowHints = <DiagnosticsNode>[
        ErrorDescription(
          'The edge of the $runtimeType that is overflowing has been marked '
          'in the rendering with a yellow and black striped pattern. This is '
          'usually caused by the contents being too big for the $runtimeType.',
        ),
        ErrorHint(
          'Consider applying a flex factor (e.g. using an Expanded widget) to '
          'force the children of the $runtimeType to fit within the available '
          'space instead of being sized to their natural size.',
        ),
        ErrorHint(
          'This is considered an error condition because it indicates that there '
          'is content that cannot be seen. If the content is legitimately bigger '
          'than the available space, consider clipping it with a ClipRect widget '
          'before putting it in the flex, or using a scrollable container rather '
          'than a Flex, like a ListView.',
        ),
      ];

      final overflowChildRect =
          Rect.fromLTWH(0.0, 0.0, size.width + _overflow!, 0.0);

      paintOverflowIndicator(
          context, offset, Offset.zero & size, overflowChildRect,
          overflowHints: debugOverflowHints);
      return true;
    }());
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) =>
      _hasOverflow ? Offset.zero & size : null;

  @override
  String toStringShort() {
    var header = super.toStringShort();
    if (_overflow != null && _hasOverflow) {
      header += ' OVERFLOWING';
    }
    return header;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<CrossAxisAlignment>(
        'crossAxisAlignment', crossAxisAlignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties.add(EnumProperty<TextBaseline>('textBaseline', textBaseline,
        defaultValue: null));
  }
}
