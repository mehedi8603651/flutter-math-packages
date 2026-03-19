import '../options.dart';
import '../syntax_tree.dart';

/// Generic parser-facing model for style wrapper nodes such as `\mathbf{...}`.
///
/// This stays independent from any particular green-tree implementation so
/// both the root package and future frontend packages can share the same data
/// shape before their tree layers are fully unified.
class StyleNodeModel<TChild> {
  final List<TChild> children;
  final OptionsDiff optionsDiff;

  const StyleNodeModel({
    required this.children,
    required this.optionsDiff,
  });

  StyleNodeModel<TChild> copyWith({
    List<TChild>? children,
    OptionsDiff? optionsDiff,
  }) =>
      StyleNodeModel<TChild>(
        children: children ?? this.children,
        optionsDiff: optionsDiff ?? this.optionsDiff,
      );

  StyleNodeModel<TNextChild> mapChildren<TNextChild>(
    List<TNextChild> children,
  ) =>
      StyleNodeModel<TNextChild>(
        children: children,
        optionsDiff: optionsDiff,
      );

  Map<String, Object?> toJsonWith(Object? Function(TChild child) encodeChild) =>
      <String, Object?>{
        'children': children.map(encodeChild).toList(growable: false),
        'optionsDiff': optionsDiff.toString(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StyleNodeModel<TChild> &&
          _listEquals(other.children, children) &&
          other.optionsDiff == optionsDiff;

  @override
  int get hashCode => Object.hash(Object.hashAll(children), optionsDiff);
}

/// Shared green-tree wrapper for style changes such as `\textstyle` or
/// `\mathbf{...}`.
class StyleNode extends TransparentNode {
  final StyleNodeModel<GreenNode> _model;

  StyleNode({
    required List<GreenNode> children,
    required OptionsDiff optionsDiff,
  }) : _model = StyleNodeModel<GreenNode>(
         children: children,
         optionsDiff: optionsDiff,
       );

  @override
  List<GreenNode> get children => _model.children;

  OptionsDiff get optionsDiff => _model.optionsDiff;

  StyleNodeModel<GreenNode> get sharedModel => _model;

  @override
  StyleNode updateChildren(covariant List<GreenNode?> newChildren) {
    final updatedChildren = newChildren.map((child) {
      if (child == null) {
        throw ArgumentError.value(
          newChildren,
          'children',
          'StyleNode does not allow null children.',
        );
      }
      return child;
    }).toList(growable: false);
    return copyWith(children: updatedChildren);
  }

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll(_model.toJsonWith((child) => child.toJson()));

  StyleNode copyWith({
    List<GreenNode>? children,
    OptionsDiff? optionsDiff,
  }) =>
      StyleNode(
        children: children ?? this.children,
        optionsDiff: optionsDiff ?? this.optionsDiff,
      );
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (identical(left, right)) {
    return true;
  }
  if (left.length != right.length) {
    return false;
  }
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) {
      return false;
    }
  }
  return true;
}
