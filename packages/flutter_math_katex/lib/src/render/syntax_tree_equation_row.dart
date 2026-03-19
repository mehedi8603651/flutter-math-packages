part of '../ast/syntax_tree.dart';

mixin _EquationRowNodeRendering {
  List<GreenNode> get flattenedChildList;
  TextRange get range;
  int get pos;
  List<int> get caretPositions;
  List<GreenNode> get children;

  GlobalKey? _key;
  GlobalKey? get key => _key;

  BuildResult buildWidget(
    MathOptions options,
    List<BuildResult?> childBuildResults,
  ) {
    final flattenedBuildResults = childBuildResults
        .expand((result) => result!.results ?? <BuildResult>[result])
        .toList(growable: false);
    final renderedChildren = _collapseTextRunsForRendering(
      flattenedChildList,
      flattenedBuildResults,
    );
    final renderedNodes =
        renderedChildren.map((entry) => entry.node).toList(growable: false);
    final renderedBuildResults =
        renderedChildren.map((entry) => entry.result).toList(growable: false);
    final renderedChildOptions =
        renderedBuildResults.map((e) => e.options).toList(growable: false);

    final childSpacingConfs = List<_NodeSpacingConf>.generate(
      renderedNodes.length,
      (index) {
        final node = renderedNodes[index];
        return _NodeSpacingConf(
          node.leftType,
          node.rightType,
          renderedChildOptions[index],
          0.0,
        );
      },
      growable: false,
    );

    _traverseNonSpaceNodes(childSpacingConfs, (prev, curr) {
      if (prev?.rightType == AtomType.bin &&
          const <AtomType?>{
            AtomType.rel,
            AtomType.close,
            AtomType.punct,
            null,
          }.contains(curr?.leftType)) {
        prev!.rightType = AtomType.ord;
        if (prev.leftType == AtomType.bin) {
          prev.leftType = AtomType.ord;
        }
      } else if (curr?.leftType == AtomType.bin &&
          const <AtomType?>{
            AtomType.bin,
            AtomType.open,
            AtomType.rel,
            AtomType.op,
            AtomType.punct,
            null,
          }.contains(prev?.rightType)) {
        curr!.leftType = AtomType.ord;
        if (curr.rightType == AtomType.bin) {
          curr.rightType = AtomType.ord;
        }
      }
    });

    _traverseNonSpaceNodes(childSpacingConfs, (prev, curr) {
      if (prev != null && curr != null) {
        prev.spacingAfter = getSpacingSize(
          prev.rightType,
          curr.leftType,
          curr.options.style,
        ).toLpUnder(curr.options);
      }
    });

    _key = GlobalKey();

    final lineChildren = List<LineElement>.generate(
      renderedBuildResults.length,
      (index) => LineElement(
        child: renderedBuildResults[index].widget,
        canBreakBefore: false,
        alignerOrSpacer: renderedNodes[index] is SpaceNode &&
            (renderedNodes[index] as SpaceNode).alignerOrSpacer,
        trailingMargin: childSpacingConfs[index].spacingAfter,
      ),
      growable: false,
    );

    final widget = Consumer<FlutterMathMode>(builder: (context, mode, child) {
      if (mode == FlutterMathMode.view) {
        return EquationRowView(
          lineKey: _key,
          children: lineChildren,
        );
      }

      return ProxyProvider<MathController, TextSelection>(
        create: (_) => const TextSelection.collapsed(offset: -1),
        update: (context, controller, _) {
          final selection = controller.selection;
          return selection.copyWith(
            baseOffset:
                selection.baseOffset.clampInt(range.start - 1, range.end + 1),
            extentOffset:
                selection.extentOffset.clampInt(range.start - 1, range.end + 1),
          );
        },
        child: Selector2<TextSelection, Tuple2<LayerLink, LayerLink>,
            Tuple3<TextSelection, LayerLink?, LayerLink?>>(
          selector: (context, selection, handleLayerLinks) {
            final start = selection.start - pos;
            final end = selection.end - pos;

            final caretStart = caretPositions.slotFor(start).ceil();
            final caretEnd = caretPositions.slotFor(end).floor();

            final caretSelection = caretStart <= caretEnd
                ? selection.baseOffset <= selection.extentOffset
                    ? TextSelection(
                        baseOffset: caretStart,
                        extentOffset: caretEnd,
                      )
                    : TextSelection(
                        baseOffset: caretEnd,
                        extentOffset: caretStart,
                      )
                : const TextSelection.collapsed(offset: -1);

            final startHandleLayerLink =
                caretPositions.contains(start) ? handleLayerLinks.item1 : null;
            final endHandleLayerLink =
                caretPositions.contains(end) ? handleLayerLinks.item2 : null;

            return Tuple3<TextSelection, LayerLink?, LayerLink?>(
              caretSelection,
              startHandleLayerLink,
              endHandleLayerLink,
            );
          },
          builder: (context, conf, _) {
            final value = Provider.of<SelectionStyle>(context);
            return EditableLine(
              key: _key,
              children: lineChildren,
              devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
              basePosition: pos,
              caretPositions: caretPositions,
              preferredLineHeight: options.fontSize,
              cursorBlinkOpacityController:
                  Provider.of<Wrapper<AnimationController>>(context).value,
              selection: conf.item1,
              startHandleLayerLink: conf.item2,
              endHandleLayerLink: conf.item3,
              cursorColor: value.cursorColor,
              cursorOffset: value.cursorOffset,
              cursorRadius: value.cursorRadius,
              cursorWidth: value.cursorWidth,
              cursorHeight: value.cursorHeight,
              hintingColor: value.hintingColor,
              paintCursorAboveText: value.paintCursorAboveText,
              selectionColor: value.selectionColor,
              showCursor: value.showCursor,
            );
          },
        ),
      );
    });

    final italic =
        flattenedBuildResults.isEmpty ? 0.0 : flattenedBuildResults.last.italic;
    final skew = flattenedBuildResults.length == 1
        ? flattenedBuildResults.first.italic
        : 0.0;

    return BuildResult(
      options: options,
      italic: italic,
      skew: skew,
      widget: widget,
    );
  }

  List<MathOptions> computeChildOptions(MathOptions options) =>
      List<MathOptions>.filled(children.length, options, growable: false);

  bool shouldRebuildWidget(MathOptions oldOptions, MathOptions newOptions) =>
      false;
}

List<_RenderedNodeResult> _collapseTextRunsForRendering(
  List<GreenNode> nodes,
  List<BuildResult> buildResults,
) {
  assert(nodes.length == buildResults.length);

  final collapsed = <_RenderedNodeResult>[];
  final currentRun = <_RenderedNodeResult>[];
  var currentRunHasComplexShaping = false;

  void flushCurrentRun() {
    if (currentRun.isEmpty) {
      return;
    }

    if (currentRun.length > 1 && currentRunHasComplexShaping) {
      final firstNode = currentRun.first.node as SymbolNode;
      final lastNode = currentRun.last.node;
      final text = StringBuffer();
      for (final entry in currentRun) {
        text.write((entry.node as SymbolNode).symbol);
      }
      final textRunNode = TextRunNode(
        text: text.toString(),
        overrideFont: firstNode.overrideFont,
        leftType: firstNode.leftType,
        rightType: lastNode.rightType,
      );
      collapsed.add(
        _RenderedNodeResult(
          textRunNode,
          textRunNode.buildWidget(currentRun.first.result.options, const []),
        ),
      );
    } else {
      collapsed.addAll(currentRun);
    }

    currentRun.clear();
    currentRunHasComplexShaping = false;
  }

  for (var index = 0; index < nodes.length; index++) {
    final entry = _RenderedNodeResult(nodes[index], buildResults[index]);
    if (_canCollapseIntoTextRun(entry, currentRun)) {
      currentRun.add(entry);
      currentRunHasComplexShaping = currentRunHasComplexShaping ||
          _symbolUsesComplexShaping((entry.node as SymbolNode).symbol);
      continue;
    }

    flushCurrentRun();
    if (_isTextRunCandidate(entry)) {
      currentRun.add(entry);
      currentRunHasComplexShaping =
          _symbolUsesComplexShaping((entry.node as SymbolNode).symbol);
    } else {
      collapsed.add(entry);
    }
  }

  flushCurrentRun();
  return collapsed;
}

bool _canCollapseIntoTextRun(
  _RenderedNodeResult entry,
  List<_RenderedNodeResult> currentRun,
) {
  if (!_isTextRunCandidate(entry)) {
    return false;
  }
  final node = entry.node as SymbolNode;

  if (currentRun.isEmpty) {
    return true;
  }

  final firstNode = currentRun.first.node as SymbolNode;
  return firstNode.overrideFont == node.overrideFont &&
      firstNode.overrideAtomType == node.overrideAtomType &&
      _sameTextRunStyle(currentRun.first.result.options, entry.result.options);
}

bool _sameTextRunStyle(MathOptions left, MathOptions right) =>
    left.color == right.color &&
    left.sizeMultiplier == right.sizeMultiplier &&
    left.textFontOptions == right.textFontOptions &&
    left.textModeTextStyle == right.textModeTextStyle &&
    left.textLocale == right.textLocale;

bool _isTextRunCandidate(_RenderedNodeResult entry) {
  final node = entry.node;
  return node is SymbolNode && node.mode == Mode.text && !node.variantForm;
}

bool _symbolUsesComplexShaping(String text) =>
    text.runes.any(_isComplexShapingCodepoint);

bool _isComplexShapingCodepoint(int codepoint) =>
    _isBrahmicCodepoint(codepoint) || _isArabicCodepoint(codepoint);

bool _isBrahmicCodepoint(int codepoint) =>
    codepoint >= 0x0900 && codepoint <= 0x109F;

bool _isArabicCodepoint(int codepoint) =>
    (codepoint >= 0x0600 && codepoint <= 0x06FF) ||
    (codepoint >= 0x0750 && codepoint <= 0x077F) ||
    (codepoint >= 0x08A0 && codepoint <= 0x08FF) ||
    (codepoint >= 0xFB50 && codepoint <= 0xFDFF) ||
    (codepoint >= 0xFE70 && codepoint <= 0xFEFF);

void _traverseNonSpaceNodes(
  List<_NodeSpacingConf> childTypeList,
  void Function(_NodeSpacingConf? prev, _NodeSpacingConf? curr) callback,
) {
  _NodeSpacingConf? prev;
  for (final child in childTypeList) {
    if (child.leftType == AtomType.spacing ||
        child.rightType == AtomType.spacing) {
      continue;
    }
    callback(prev, child);
    prev = child;
  }
  if (prev != null) {
    callback(prev, null);
  }
}

class _NodeSpacingConf {
  AtomType leftType;
  AtomType rightType;
  MathOptions options;
  double spacingAfter;

  _NodeSpacingConf(
    this.leftType,
    this.rightType,
    this.options,
    this.spacingAfter,
  );
}

class _RenderedNodeResult {
  final GreenNode node;
  final BuildResult result;

  const _RenderedNodeResult(this.node, this.result);
}
