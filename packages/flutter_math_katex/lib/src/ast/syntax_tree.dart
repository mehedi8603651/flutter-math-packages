import 'dart:math' as math;

import 'package:flutter_math_model/ast.dart' as model show AtomType;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'nodes/space.dart';
import 'nodes/symbol.dart';
import 'nodes/text_run.dart';
import 'options.dart';
import 'size.dart';
import 'spacing.dart';
import '../render/build_result.dart';
import '../render/layout/equation_row_view.dart';
import '../render/layout/line.dart';
import '../render/layout/line_editable.dart';
import '../utils/iterable_extensions.dart';
import '../utils/num_extension.dart';
import '../utils/wrapper.dart';
import '../widgets/controller.dart';
import '../widgets/mode.dart';
import '../widgets/selectable.dart';
import 'types.dart';

export '../render/build_result.dart' show BuildResult;

part '../render/syntax_tree_render.dart';
part '../render/syntax_tree_equation_row.dart';

typedef AtomType = model.AtomType;

/// Roslyn's Red-Green Tree
///
/// [Description of Roslyn's Red-Green Tree](https://docs.microsoft.com/en-us/archive/blogs/ericlippert/persistence-facades-and-roslyns-red-green-trees)
class SyntaxTree {
  /// Root of the green tree
  final EquationRowNode greenRoot;

  SyntaxTree({
    required this.greenRoot,
  });

  /// Root of the red tree
  late final SyntaxNode root = SyntaxNode(
    parent: null,
    value: greenRoot,
    pos: -1, // Important
  );

  /// Replace node at [pos] with [newNode]
  SyntaxTree replaceNode(SyntaxNode pos, GreenNode newNode) {
    if (identical(pos.value, newNode)) {
      return this;
    }
    if (identical(pos, root)) {
      return SyntaxTree(greenRoot: newNode.wrapWithEquationRow());
    }
    final posParent = pos.parent;
    if (posParent == null) {
      throw ArgumentError(
          'The replaced node is not the root of this tree but has no parent');
    }
    return replaceNode(
        posParent,
        posParent.value.updateChildren(posParent.children
            .map((child) => identical(child, pos) ? newNode : child?.value)
            .toList(growable: false)));
  }

  List<SyntaxNode> findNodesAtPosition(int position) {
    var curr = root;
    final res = <SyntaxNode>[];
    while (true) {
      res.add(curr);
      final next = curr.children.firstWhereOrNull(
        (child) => child != null && child.managesPosition(position),
      );
      if (next == null) break;
      curr = next;
    }
    return res;
  }

  EquationRowNode findNodeManagesPosition(int position) {
    var curr = root;
    var lastEqRow = root.value as EquationRowNode;
    while (true) {
      final next = curr.children.firstWhereOrNull(
        (child) => child != null && child.managesPosition(position),
      );
      if (next == null) break;
      if (next.value is EquationRowNode) {
        lastEqRow = next.value as EquationRowNode;
      }
      curr = next;
    }
    // assert(curr.value is EquationRowNode);
    return lastEqRow;
  }

  EquationRowNode findLowestCommonRowNode(int position1, int position2) {
    final redNodes1 = findNodesAtPosition(position1);
    final redNodes2 = findNodesAtPosition(position2);
    for (var index = math.min(redNodes1.length, redNodes2.length) - 1;
        index >= 0;
        index--) {
      final node1 = redNodes1[index].value;
      final node2 = redNodes2[index].value;
      if (node1 == node2 && node1 is EquationRowNode) {
        return node1;
      }
    }
    return greenRoot;
  }

  List<GreenNode> findSelectedNodes(int position1, int position2) {
    final rowNode = findLowestCommonRowNode(position1, position2);

    final localPos1 = position1 - rowNode.pos;
    final localPos2 = position2 - rowNode.pos;
    return rowNode.clipChildrenBetween(localPos1, localPos2).children;
  }
}

/// Red Node. Immutable facade for math nodes.
///
/// [Description of Roslyn's Red-Green Tree](https://docs.microsoft.com/en-us/archive/blogs/ericlippert/persistence-facades-and-roslyns-red-green-trees).
///
/// [SyntaxNode] is an immutable facade over [GreenNode]. It stores absolute
/// information and context parameters of an abstract syntax node which cannot
/// be stored inside [GreenNode]. Every node of the red tree is evaluated
/// top-down on demand.
class SyntaxNode {
  final SyntaxNode? parent;
  final GreenNode value;
  final int pos;
  SyntaxNode({
    required this.parent,
    required this.value,
    required this.pos,
  });

  /// Lazily evaluated children of current [SyntaxNode]
  late final List<SyntaxNode?> children = List.generate(
      value.children.length,
      (index) => value.children[index] != null
          ? SyntaxNode(
              parent: this,
              value: value.children[index]!,
              pos: this.pos + value.childPositions[index],
            )
          : null,
      growable: false);

  /// [GreenNode.getRange]
  late final TextRange range = value.getRange(pos);

  /// [GreenNode.editingWidth]
  int get width => value.editingWidth;

  /// [GreenNode.capturedCursor]
  int get capturedCursor => value.capturedCursor;

  /// Whether this syntax node manages [position] in editing coordinates.
  bool managesPosition(int position) =>
      position >= pos && position < pos + value.editingWidth;
}

/// Node of Roslyn's Green Tree. Base class of any math nodes.
///
/// [Description of Roslyn's Red-Green Tree](https://docs.microsoft.com/en-us/archive/blogs/ericlippert/persistence-facades-and-roslyns-red-green-trees).
///
/// [GreenNode] stores any context-free information of a node and is
/// constructed bottom-up. It needs to indicate or store:
/// - Necessary parameters for this math node.
/// - Strutural information of the tree ([children])
/// - Context-free properties for other purposes. ([editingWidth], etc.)
///
/// Due to their context-free property, [GreenNode] can be canonicalized and
/// deduplicated.
abstract class GreenNode with _RenderableNode {
  /// Children of this node.
  ///
  /// [children] stores structural information of the Red-Green Tree.
  /// Used for green tree updates. The order of children should strictly
  /// adheres to the cursor-visiting order in editing mode, in order to get a
  /// correct cursor range in the editing mode. For example, for [SqrtNode],
  /// when moving cursor from left to right, the cursor first enters the index,
  /// then the base, so it should return `index` before `base`.
  ///
  /// Please ensure [children] works in the same order as [updateChildren].
  List<GreenNode?> get children;

  /// Return a copy of this node with new children.
  ///
  /// Subclasses should override this method. This method provides a general
  /// interface to perform structural updates for the green tree (node
  /// replacement, insertion, etc).
  ///
  /// Please ensure [children] works in the same order as [updateChildren].
  GreenNode updateChildren(covariant List<GreenNode?> newChildren);

  /// Minimum number of "right" keystrokes needed to move the cursor pass
  /// through this node (from the rightmost of the previous node, to the
  /// leftmost of the next node)
  ///
  /// Used only for editing functionalities.
  ///
  /// [editingWidth] stores intrinsic width in the editing mode.
  ///
  /// Please calculate (and cache) the width based on [children]'s widths.
  /// Note that it should strictly simulate the movement of the curosr.
  int get editingWidth;

  /// Number of cursor positions that can be captured within this node.
  ///
  /// By definition, [capturedCursor] = [editingWidth] - 1.
  /// By definition, [TextRange.end] - [TextRange.start] = capturedCursor - 1.
  int get capturedCursor => editingWidth - 1;

  /// [TextRange]
  TextRange getRange(int pos) =>
      TextRange(start: pos + 1, end: pos + capturedCursor);

  /// Position of child nodes.
  ///
  /// Used only for editing functionalities.
  ///
  /// This method stores the layout strucuture for cursor in the editing mode.
  /// You should return positions of children assume this current node is placed
  /// at the starting position. It should be no shorter than [children]. It's
  /// entirely optional to add extra hinting elements.
  List<int> get childPositions;

  /// [AtomType] observed from the left side.
  AtomType get leftType;

  /// [AtomType] observed from the right side.
  AtomType get rightType;

  Map<String, Object?> toJson() => {
        'type': runtimeType.toString(),
      };
}

/// [GreenNode] that can have children
abstract class ParentableNode<T extends GreenNode?> extends GreenNode {
  @override
  List<T> get children;

  @override
  late final int editingWidth = computeWidth();

  /// Compute width from children. Abstract.
  int computeWidth();

  @override
  late final List<int> childPositions = computeChildPositions();

  /// Compute children positions. Abstract.
  List<int> computeChildPositions();

  @override
  ParentableNode<T> updateChildren(covariant List<T?> newChildren);
}

mixin PositionDependentMixin<T extends GreenNode> on ParentableNode<T> {
  var range = const TextRange(start: 0, end: -1);

  int get pos => range.start - 1;

  void updatePos(int pos) {
    range = getRange(pos);
  }
}

/// [SlotableNode] is those composite node that has editable [EquationRowNode]
/// as children and lay them out into certain slots.
///
/// [SlotableNode] is the most commonly-used node. They share cursor logic and
/// editing logic.
///
/// Depending on node type, some [SlotableNode] can have nulls inside their
/// children list. When null is allowed, it usually means that node will have
/// different layout slot logic depending on non-null children number.
abstract class SlotableNode<T extends EquationRowNode?>
    extends ParentableNode<T> {
  @override
  late final List<T> children = computeChildren();

  /// Compute children. Abstract.
  ///
  /// Used to cache children list
  List<T> computeChildren();

  @override
  int computeWidth() => children.fold<int>(
        1,
        (sum, child) => sum + (child?.capturedCursor ?? 0),
      );

  @override
  List<int> computeChildPositions() {
    var curPos = 0;
    final result = <int>[];
    for (final child in children) {
      result.add(curPos);
      curPos += child?.capturedCursor ?? 0;
    }
    return result;
  }
}

/// [TransparentNode] refers to those node who have zero rendering content
/// iteself, and are expected to be unwrapped for its children during rendering.
///
/// [TransparentNode]s are only allowed to appear directly under
/// [EquationRowNode]s and other [TransparentNode]s. And those nodes have to
/// explicitly unwrap transparent nodes during building stage.
abstract class TransparentNode extends ParentableNode<GreenNode>
    with _ClipChildrenMixin, _TransparentNodeRendering {
  @override
  int computeWidth() =>
      children.fold<int>(0, (sum, child) => sum + child.editingWidth);

  @override
  List<int> computeChildPositions() {
    var curPos = 0;
    return List.generate(children.length + 1, (index) {
      if (index == 0) return curPos;
      return curPos += children[index - 1].editingWidth;
    }, growable: false);
  }

  /// Children list when fully expand any underlying [TransparentNode]
  late final List<GreenNode> flattenedChildList = children
      .expand((child) =>
          child is TransparentNode ? child.flattenedChildList : [child])
      .toList(growable: false);

  @override
  late final AtomType leftType = children[0].leftType;

  @override
  late final AtomType rightType = children.last.rightType;
}

/// A row of unrelated [GreenNode]s.
///
/// [EquationRowNode] provides cursor-reachability and editability. It
/// represents a collection of nodes that you can freely edit and navigate.
class EquationRowNode extends ParentableNode<GreenNode>
    with PositionDependentMixin, _ClipChildrenMixin, _EquationRowNodeRendering {
  /// If non-null, the leftmost and rightmost [AtomType] will be overriden.
  final AtomType? overrideType;

  @override
  final List<GreenNode> children;

  @override
  int computeWidth() =>
      children.fold<int>(2, (sum, child) => sum + child.editingWidth);

  @override
  List<int> computeChildPositions() {
    var curPos = 1;
    return List.generate(children.length + 1, (index) {
      if (index == 0) return curPos;
      return curPos += children[index - 1].editingWidth;
    }, growable: false);
  }

  EquationRowNode({
    required this.children,
    this.overrideType,
  });

  factory EquationRowNode.empty() => EquationRowNode(children: []);

  /// Children list when fully expanded any underlying [TransparentNode].
  late final List<GreenNode> flattenedChildList = children
      .expand((child) =>
          child is TransparentNode ? child.flattenedChildList : [child])
      .toList(growable: false);

  /// Children positions when fully expanded underlying [TransparentNode], but
  /// appended an extra position entry for the end.
  late final List<int> caretPositions = computeCaretPositions();
  List<int> computeCaretPositions() {
    var curPos = 1;
    return List.generate(flattenedChildList.length + 1, (index) {
      if (index == 0) return curPos;
      return curPos += flattenedChildList[index - 1].editingWidth;
    }, growable: false);
  }

  @override
  EquationRowNode updateChildren(List<GreenNode?> newChildren) => copyWith(
        children: newChildren.map((child) {
          if (child == null) {
            throw ArgumentError(
              'EquationRowNode does not allow null children during updates.',
            );
          }
          return child;
        }).toList(growable: false),
      );

  @override
  AtomType get leftType => overrideType ?? AtomType.ord;

  @override
  AtomType get rightType => overrideType ?? AtomType.ord;

  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'children': children.map((child) => child.toJson()).toList(),
      if (overrideType != null) 'overrideType': overrideType,
    });

  /// Utility method.
  EquationRowNode copyWith({
    AtomType? overrideType,
    List<GreenNode>? children,
  }) =>
      EquationRowNode(
        overrideType: overrideType ?? this.overrideType,
        children: children ?? this.children,
      );
}

mixin _ClipChildrenMixin on ParentableNode<GreenNode> {
  ParentableNode<GreenNode> clipChildrenBetween(int pos1, int pos2) {
    final childIndex1 = childPositions.slotFor(pos1);
    final childIndex2 = childPositions.slotFor(pos2);
    final childIndex1Floor = childIndex1.floor();
    final childIndex1Ceil = childIndex1.ceil();
    final childIndex2Floor = childIndex2.floor();
    final childIndex2Ceil = childIndex2.ceil();
    GreenNode? head;
    GreenNode? tail;
    if (childIndex1Floor != childIndex1 &&
        childIndex1Floor >= 0 &&
        childIndex1Floor <= children.length - 1) {
      final child = children[childIndex1Floor];
      if (child is TransparentNode) {
        head = child.clipChildrenBetween(
            pos1 - childPositions[childIndex1Floor],
            pos2 - childPositions[childIndex1Floor]);
      } else {
        head = child;
      }
    }
    if (childIndex2Ceil != childIndex2 &&
        childIndex2Floor >= 0 &&
        childIndex2Floor <= children.length - 1) {
      final child = children[childIndex2Floor];
      if (child is TransparentNode) {
        tail = child.clipChildrenBetween(
            pos1 - childPositions[childIndex2Floor],
            pos2 - childPositions[childIndex2Floor]);
      } else {
        tail = child;
      }
    }
    return this.updateChildren(<GreenNode>[
      if (head != null) head,
      for (var i = childIndex1Ceil; i < childIndex2Floor; i++) children[i],
      if (tail != null) tail,
    ]);
  }
}

extension GreenNodeWrappingExt on GreenNode {
  /// Wrap a node in [EquationRowNode]
  ///
  /// If this node is already [EquationRowNode], then it won't be wrapped
  EquationRowNode wrapWithEquationRow() {
    if (this is EquationRowNode) {
      return this as EquationRowNode;
    }
    return EquationRowNode(children: [this]);
  }

  /// If this node is [EquationRowNode], its children will be returned. If not,
  /// itself will be returned in a list.
  List<GreenNode> expandEquationRow() {
    if (this is EquationRowNode) {
      return (this as EquationRowNode).children;
    }
    return [this];
  }

  /// Return the only child of [EquationRowNode]
  ///
  /// If the [EquationRowNode] has more than one child, an error will be thrown.
  GreenNode unwrapEquationRow() {
    if (this is EquationRowNode) {
      if (this.children.length == 1) {
        return (this as EquationRowNode).children[0];
      }
      throw ArgumentError(
          'Unwrap equation row failed due to multiple children inside');
    }
    return this;
  }
}

extension GreenNodeListWrappingExt on List<GreenNode> {
  /// Wrap list of [GreenNode] in an [EquationRowNode]
  ///
  /// If the list only contain one [EquationRowNode], then this note will be
  /// returned.
  EquationRowNode wrapWithEquationRow() {
    if (this.length == 1 && this[0] is EquationRowNode) {
      return this[0] as EquationRowNode;
    }
    return EquationRowNode(children: this);
  }
}

/// [GreenNode] that doesn't have any children
abstract class LeafNode extends GreenNode {
  /// [Mode] that this node acquires during parse.
  Mode get mode;

  @override
  List<GreenNode> get children => const [];

  @override
  LeafNode updateChildren(List<GreenNode> newChildren) {
    assert(newChildren.isEmpty);
    return this;
  }

  @override
  List<MathOptions> computeChildOptions(MathOptions options) =>
      const <MathOptions>[];

  @override
  List<int> get childPositions => const [];

  @override
  int get editingWidth => 1;
}

/// Only for improvisional use during parsing. Do not use.
class TemporaryNode extends LeafNode with _TemporaryNodeRendering {
  @override
  Mode get mode => Mode.math;
}

extension _FirstWhereOrNullExt<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
