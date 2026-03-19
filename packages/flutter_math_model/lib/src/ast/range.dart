/// Immutable integer range used by the model layer.
class MathRange {
  final int start;
  final int end;

  const MathRange({
    required this.start,
    required this.end,
  });

  static const empty = MathRange(start: 0, end: -1);

  bool get isEmpty => end < start;

  int get length => isEmpty ? 0 : end - start;

  bool contains(int position) => position >= start && position <= end;

  bool overlaps(MathRange other) =>
      !isEmpty && !other.isEmpty && start <= other.end && other.start <= end;

  MathRange copyWith({
    int? start,
    int? end,
  }) =>
      MathRange(
        start: start ?? this.start,
        end: end ?? this.end,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is MathRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'MathRange(start: $start, end: $end)';
}
