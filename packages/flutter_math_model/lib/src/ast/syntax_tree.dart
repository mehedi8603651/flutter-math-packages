import 'dart:math' as math;

import 'range.dart';
import 'types.dart';

/// Roslyn-style red-green tree for math syntax.
class SyntaxTree {
  /// Root of the green tree.
  final EquationRowNode greenRoot;

  SyntaxTree({
    required this.greenRoot,
  });

  /// Root of the red tree.
  late final SyntaxNode root = SyntaxNode(
    parent: null,
    value: greenRoot,
    pos: -1,
  );

  /// Replace the node at [position] with [newNode].
  SyntaxTree replaceNode(SyntaxNode position, GreenNode newNode) {
    if (identical(position.value, newNode)) {
      return this;
    }
    if (identical(position, root)) {
      return SyntaxTree(greenRoot: newNode.wrapWithEquationRow());
    }

    final parent = position.parent;
    if (parent == null) {
      throw ArgumentError(
        'The replaced node is not the root of this tree but has no parent.',
      );
    }

    final updatedChildren = List<GreenNode?>.generate(
      parent.children.length,
      (index) {
        final child = parent.children[index];
        return identical(child, position) ? newNode : child?.value;
      },
      growable: false,
    );

    return replaceNode(parent, parent.value.updateChildren(updatedChildren));
  }

  /// Find all red nodes that contain [position], from root to leaf.
  List<SyntaxNode> findNodesAtPosition(int position) {
    var current = root;
    final result = <SyntaxNode>[];

    while (true) {
      result.add(current);
      final next = _firstWhereOrNull(
        current.children,
        (child) => child != null && child.managesPosition(position),
      );
      if (next == null) {
        break;
      }
      current = next;
    }
    return result;
  }

  /// Find the lowest equation-row node whose range still contains [position].
  EquationRowNode findNodeManagesPosition(int position) {
    var current = root;
    var lastEquationRow = root.value as EquationRowNode;

    while (true) {
      final next = _firstWhereOrNull(
        current.children,
        (child) => child != null && child.managesPosition(position),
      );
      if (next == null) {
        break;
      }
      if (next.value is EquationRowNode) {
        lastEquationRow = next.value as EquationRowNode;
      }
      current = next;
    }

    return lastEquationRow;
  }

  /// Find the lowest common ancestor equation-row node for two positions.
  EquationRowNode findLowestCommonRowNode(int position1, int position2) {
    final nodes1 = findNodesAtPosition(position1);
    final nodes2 = findNodesAtPosition(position2);

    for (var index = math.min(nodes1.length, nodes2.length) - 1;
        index >= 0;
        index--) {
      final value1 = nodes1[index].value;
      final value2 = nodes2[index].value;
      if (value1 == value2 && value1 is EquationRowNode) {
        return value1;
      }
    }
    return greenRoot;
  }

  /// Return selected green nodes between [position1] and [position2].
  List<GreenNode> findSelectedNodes(int position1, int position2) {
    final rowNode = findLowestCommonRowNode(position1, position2);
    final localPosition1 = position1 - rowNode.pos;
    final localPosition2 = position2 - rowNode.pos;
    return rowNode.clipChildrenBetween(localPosition1, localPosition2).children;
  }
}

/// Immutable red node facade over a [GreenNode].
class SyntaxNode {
  final SyntaxNode? parent;
  final GreenNode value;
  final int pos;

  SyntaxNode({
    required this.parent,
    required this.value,
    required this.pos,
  }) {
    if (value is PositionDependentMixin) {
      (value as PositionDependentMixin).updatePos(pos);
    }
  }

  /// Lazily evaluated children of the current syntax node.
  late final List<SyntaxNode?> children = List<SyntaxNode?>.generate(
    value.children.length,
    (index) {
      final child = value.children[index];
      if (child == null) {
        return null;
      }
      return SyntaxNode(
        parent: this,
        value: child,
        pos: pos + value.childPositions[index],
      );
    },
    growable: false,
  );

  /// Absolute range of the node in editing coordinates.
  late final MathRange range = value.getRange(pos);

  int get width => value.editingWidth;

  int get capturedCursor => value.capturedCursor;

  /// Whether this syntax node manages [position] in editing coordinates.
  bool managesPosition(int position) =>
      position >= pos && position < pos + value.editingWidth;
}

/// Base class of all green-tree nodes.
abstract class GreenNode {
  /// Structural children of this node.
  List<GreenNode?> get children;

  /// Return a copy of this node with new children.
  GreenNode updateChildren(covariant List<GreenNode?> newChildren);

  /// Minimum number of cursor steps needed to pass this node.
  int get editingWidth;

  /// Number of cursor positions captured within this node.
  int get capturedCursor => editingWidth - 1;

  /// Absolute range if this node starts at [pos].
  MathRange getRange(int pos) => MathRange(
        start: pos + 1,
        end: pos + capturedCursor,
      );

  /// Relative positions of children when this node starts at zero.
  List<int> get childPositions;

  /// Atom type observed from the left side.
  AtomType get leftType;

  /// Atom type observed from the right side.
  AtomType get rightType;

  Map<String, Object?> toJson() => {
        'type': runtimeType.toString(),
      };
}

/// Green node that can have children.
abstract class ParentableNode<T extends GreenNode?> extends GreenNode {
  @override
  List<T> get children;

  @override
  late final int editingWidth = computeWidth();

  int computeWidth();

  @override
  late final List<int> childPositions = computeChildPositions();

  List<int> computeChildPositions();

  @override
  ParentableNode<T> updateChildren(covariant List<T?> newChildren);
}

/// Stores absolute range data for nodes whose editing logic needs it.
mixin PositionDependentMixin<T extends GreenNode> on ParentableNode<T> {
  MathRange range = MathRange.empty;

  int get pos => range.start - 1;

  void updatePos(int pos) {
    range = getRange(pos);
  }
}

/// Composite node whose slots are equation-row children.
abstract class SlotableNode<T extends EquationRowNode?>
    extends ParentableNode<T> {
  @override
  late final List<T> children = computeChildren();

  List<T> computeChildren();

  @override
  int computeWidth() =>
      children.fold<int>(1, (sum, child) => sum + (child?.capturedCursor ?? 0));

  @override
  List<int> computeChildPositions() {
    var currentPosition = 0;
    final positions = <int>[];
    for (final child in children) {
      positions.add(currentPosition);
      currentPosition += child?.capturedCursor ?? 0;
    }
    return positions;
  }
}

/// Node that does not render its own surface and should be unwrapped.
abstract class TransparentNode extends ParentableNode<GreenNode>
    with _ClipChildrenMixin {
  @override
  int computeWidth() =>
      children.fold<int>(0, (sum, child) => sum + child.editingWidth);

  @override
  List<int> computeChildPositions() {
    var currentPosition = 0;
    return List<int>.generate(
      children.length + 1,
      (index) {
        if (index == 0) {
          return currentPosition;
        }
        currentPosition += children[index - 1].editingWidth;
        return currentPosition;
      },
      growable: false,
    );
  }

  /// Children list when all nested transparent nodes are flattened.
  late final List<GreenNode> flattenedChildList = children
      .expand(
        (child) => child is TransparentNode
            ? child.flattenedChildList
            : <GreenNode>[child],
      )
      .toList(growable: false);

  @override
  AtomType get leftType =>
      children.isEmpty ? AtomType.ord : children.first.leftType;

  @override
  AtomType get rightType =>
      children.isEmpty ? AtomType.ord : children.last.rightType;
}

/// A row of unrelated green nodes that can be freely edited and navigated.
class EquationRowNode extends ParentableNode<GreenNode>
    with PositionDependentMixin, _ClipChildrenMixin {
  final AtomType? overrideType;

  @override
  final List<GreenNode> children;

  EquationRowNode({
    required this.children,
    this.overrideType,
  });

  factory EquationRowNode.empty() => EquationRowNode(children: const []);

  @override
  int computeWidth() =>
      children.fold<int>(2, (sum, child) => sum + child.editingWidth);

  @override
  List<int> computeChildPositions() {
    var currentPosition = 1;
    return List<int>.generate(
      children.length + 1,
      (index) {
        if (index == 0) {
          return currentPosition;
        }
        currentPosition += children[index - 1].editingWidth;
        return currentPosition;
      },
      growable: false,
    );
  }

  /// Children list when all nested transparent nodes are flattened.
  late final List<GreenNode> flattenedChildList = children
      .expand(
        (child) => child is TransparentNode
            ? child.flattenedChildList
            : <GreenNode>[child],
      )
      .toList(growable: false);

  /// Caret positions in the flattened child list.
  late final List<int> caretPositions = _computeCaretPositions();

  List<int> _computeCaretPositions() {
    var currentPosition = 1;
    return List<int>.generate(
      flattenedChildList.length + 1,
      (index) {
        if (index == 0) {
          return currentPosition;
        }
        currentPosition += flattenedChildList[index - 1].editingWidth;
        return currentPosition;
      },
      growable: false,
    );
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

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'children':
          children.map((child) => child.toJson()).toList(growable: false),
      if (overrideType != null) 'overrideType': overrideType.toString(),
    });

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
  ParentableNode<GreenNode> clipChildrenBetween(int position1, int position2) {
    final childIndex1 = childPositions.slotFor(position1);
    final childIndex2 = childPositions.slotFor(position2);
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
          position1 - childPositions[childIndex1Floor],
          position2 - childPositions[childIndex1Floor],
        );
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
          position1 - childPositions[childIndex2Floor],
          position2 - childPositions[childIndex2Floor],
        );
      } else {
        tail = child;
      }
    }

    final clippedChildren = <GreenNode>[
      if (head != null) head,
      for (var index = childIndex1Ceil; index < childIndex2Floor; index++)
        children[index],
      if (tail != null) tail,
    ];

    return updateChildren(clippedChildren);
  }
}

extension GreenNodeWrappingExt on GreenNode {
  /// Wrap a node in an [EquationRowNode] unless it is already one.
  EquationRowNode wrapWithEquationRow() {
    if (this is EquationRowNode) {
      return this as EquationRowNode;
    }
    return EquationRowNode(children: <GreenNode>[this]);
  }

  /// Expand the equation row if present, otherwise return the node itself.
  List<GreenNode> expandEquationRow() {
    if (this is EquationRowNode) {
      return (this as EquationRowNode).children;
    }
    return <GreenNode>[this];
  }

  /// Unwrap the single child of an [EquationRowNode].
  GreenNode unwrapEquationRow() {
    if (this is EquationRowNode) {
      final equationRow = this as EquationRowNode;
      if (equationRow.children.length == 1) {
        return equationRow.children.first;
      }
      throw ArgumentError(
        'Unwrap equation row failed because more than one child is present.',
      );
    }
    return this;
  }
}

extension GreenNodeListWrappingExt on List<GreenNode> {
  /// Wrap a list of [GreenNode] in an [EquationRowNode].
  EquationRowNode wrapWithEquationRow() {
    if (length == 1 && first is EquationRowNode) {
      return first as EquationRowNode;
    }
    return EquationRowNode(children: this);
  }
}

/// Base class for nodes without children.
abstract class LeafNode extends GreenNode {
  Mode get mode;

  @override
  List<GreenNode> get children => const <GreenNode>[];

  @override
  LeafNode updateChildren(List<GreenNode> newChildren) {
    if (newChildren.isNotEmpty) {
      throw ArgumentError('Leaf nodes cannot accept child updates.');
    }
    return this;
  }

  @override
  List<int> get childPositions => const <int>[];

  @override
  int get editingWidth => 1;
}

/// TeX atom type observed from node boundaries.
enum AtomType {
  ord,
  op,
  bin,
  rel,
  open,
  close,
  punct,
  inner,
  spacing,
}

/// Placeholder node used during parsing before a real node is constructed.
class TemporaryNode extends LeafNode {
  @override
  Mode get mode => Mode.math;

  @override
  AtomType get leftType =>
      throw UnsupportedError('Temporary node $runtimeType encountered.');

  @override
  AtomType get rightType =>
      throw UnsupportedError('Temporary node $runtimeType encountered.');
}

SyntaxNode? _firstWhereOrNull(
  List<SyntaxNode?> items,
  bool Function(SyntaxNode? item) test,
) {
  for (final item in items) {
    if (test(item)) {
      return item;
    }
  }
  return null;
}

extension IntListSlotSearchExt on List<int> {
  /// Return the exact or interpolated slot index for [value].
  double slotFor(int value) {
    var left = -1;
    var right = length;

    for (var index = 0; index < length; index++) {
      final element = this[index];
      if (element < value) {
        left = index;
      } else if (element == value) {
        return index.toDouble();
      } else {
        right = index;
        break;
      }
    }

    return (left + right) / 2;
  }
}
