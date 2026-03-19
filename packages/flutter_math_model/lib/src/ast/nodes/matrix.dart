import '../size.dart';
import '../syntax_tree.dart';

enum MatrixSeparatorStyle {
  solid,
  dashed,
  none,
}

enum MatrixColumnAlign {
  left,
  center,
  right,
}

enum MatrixRowAlign {
  top,
  bottom,
  center,
  baseline,
}

/// Pure model for TeX/MathML-style matrices and tables.
class MatrixNodeModel extends SlotableNode<EquationRowNode?> {
  final double arrayStretch;
  final bool hskipBeforeAndAfter;
  final bool isSmall;
  final List<MatrixColumnAlign> columnAligns;
  final List<MatrixSeparatorStyle> vLines;
  final List<Measurement> rowSpacings;
  final List<MatrixSeparatorStyle> hLines;
  final List<List<EquationRowNode?>> body;
  final int rows;
  final int cols;

  MatrixNodeModel._({
    required this.rows,
    required this.cols,
    this.arrayStretch = 1.0,
    this.hskipBeforeAndAfter = false,
    this.isSmall = false,
    required this.columnAligns,
    required this.vLines,
    required this.rowSpacings,
    required this.hLines,
    required this.body,
  })  : assert(body.length == rows),
        assert(body.every((row) => row.length == cols)),
        assert(columnAligns.length == cols),
        assert(vLines.length == cols + 1),
        assert(rowSpacings.length == rows),
        assert(hLines.length == rows + 1);

  factory MatrixNodeModel({
    double arrayStretch = 1.0,
    bool hskipBeforeAndAfter = false,
    bool isSmall = false,
    List<MatrixColumnAlign> columnAligns = const <MatrixColumnAlign>[],
    List<MatrixSeparatorStyle> vLines = const <MatrixSeparatorStyle>[],
    List<Measurement> rowSpacings = const <Measurement>[],
    List<MatrixSeparatorStyle> hLines = const <MatrixSeparatorStyle>[],
    required List<List<EquationRowNode?>> body,
  }) {
    final cols = _max3(
      _maxOrZero(body.map((row) => row.length)),
      columnAligns.length,
      vLines.length - 1,
    );
    final sanitizedColumnAligns =
        _extendToByFill(columnAligns, cols, MatrixColumnAlign.center);
    final sanitizedVLines =
        _extendToByFill(vLines, cols + 1, MatrixSeparatorStyle.none);

    final rows = _max3(
      body.length,
      rowSpacings.length,
      hLines.length - 1,
    );
    final sanitizedBody = _extendToByFill(
      body
          .map((row) => _extendToByFill(row, cols, null))
          .toList(growable: false),
      rows,
      List<EquationRowNode?>.filled(cols, null, growable: false),
    );
    final sanitizedRowSpacings =
        _extendToByFill(rowSpacings, rows, Measurement.zero);
    final sanitizedHLines =
        _extendToByFill(hLines, rows + 1, MatrixSeparatorStyle.none);

    return MatrixNodeModel._(
      rows: rows,
      cols: cols,
      arrayStretch: arrayStretch,
      hskipBeforeAndAfter: hskipBeforeAndAfter,
      isSmall: isSmall,
      columnAligns: List<MatrixColumnAlign>.unmodifiable(sanitizedColumnAligns),
      vLines: List<MatrixSeparatorStyle>.unmodifiable(sanitizedVLines),
      rowSpacings: List<Measurement>.unmodifiable(sanitizedRowSpacings),
      hLines: List<MatrixSeparatorStyle>.unmodifiable(sanitizedHLines),
      body: List<List<EquationRowNode?>>.unmodifiable(
        sanitizedBody
            .map((row) => List<EquationRowNode?>.unmodifiable(row))
            .toList(growable: false),
      ),
    );
  }

  @override
  List<EquationRowNode?> computeChildren() =>
      body.expand((row) => row).toList(growable: false);

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  MatrixNodeModel updateChildren(List<EquationRowNode?> newChildren) {
    if (newChildren.length < rows * cols) {
      throw ArgumentError.value(
        newChildren,
        'children',
        'MatrixNodeModel requires at least ${rows * cols} slots.',
      );
    }
    final updatedBody = List<List<EquationRowNode?>>.generate(
      rows,
      (rowIndex) => List<EquationRowNode?>.from(
        newChildren.sublist(rowIndex * cols, (rowIndex + 1) * cols),
        growable: false,
      ),
      growable: false,
    );
    return copyWith(body: updatedBody);
  }

  @override
  Map<String, Object?> toJson() => super.toJson()
    ..addAll({
      'cols': cols,
      if (arrayStretch != 1.0) 'arrayStretch': arrayStretch,
      if (hskipBeforeAndAfter) 'hskipBeforeAndAfter': hskipBeforeAndAfter,
      if (isSmall) 'isSmall': isSmall,
      'columnAligns':
          columnAligns.map((align) => align.toString()).toList(growable: false),
      'vLines': vLines.map((line) => line.toString()).toList(growable: false),
      if (rowSpacings.any((spacing) => !spacing.isZero))
        'rowSpacings': rowSpacings
            .map((spacing) => spacing.toString())
            .toList(growable: false),
      if (hLines.any((line) => line != MatrixSeparatorStyle.none))
        'hLines': hLines.map((line) => line.toString()).toList(growable: false),
      'body': body
          .map(
            (row) => row.map((cell) => cell?.toJson()).toList(growable: false),
          )
          .toList(growable: false),
    });

  MatrixNodeModel copyWith({
    double? arrayStretch,
    bool? hskipBeforeAndAfter,
    bool? isSmall,
    List<MatrixColumnAlign>? columnAligns,
    List<MatrixSeparatorStyle>? columnLines,
    List<Measurement>? rowSpacing,
    List<MatrixSeparatorStyle>? rowLines,
    List<List<EquationRowNode?>>? body,
  }) =>
      MatrixNodeModel(
        arrayStretch: arrayStretch ?? this.arrayStretch,
        hskipBeforeAndAfter: hskipBeforeAndAfter ?? this.hskipBeforeAndAfter,
        isSmall: isSmall ?? this.isSmall,
        columnAligns: columnAligns ?? this.columnAligns,
        vLines: columnLines ?? vLines,
        rowSpacings: rowSpacing ?? rowSpacings,
        hLines: rowLines ?? hLines,
        body: body ?? this.body,
      );
}

List<T> _extendToByFill<T>(List<T> list, int desiredLength, T fill) =>
    list.length >= desiredLength
        ? List<T>.from(list, growable: false)
        : List<T>.generate(
            desiredLength,
            (index) => index < list.length ? list[index] : fill,
            growable: false,
          );

int _max3(int first, int second, int third) {
  var current = first;
  if (second > current) {
    current = second;
  }
  if (third > current) {
    current = third;
  }
  return current;
}

int _maxOrZero(Iterable<int> values) {
  var seenAny = false;
  var current = 0;
  for (final value in values) {
    if (!seenAny || value > current) {
      current = value;
      seenAny = true;
    }
  }
  return seenAny ? current : 0;
}
