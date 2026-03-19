import 'package:flutter/widgets.dart';

import 'line.dart';

class EquationRowView extends StatelessWidget {
  const EquationRowView({
    super.key,
    this.lineKey,
    required this.children,
  });

  final Key? lineKey;
  final List<LineElement> children;

  @override
  Widget build(BuildContext context) => Line(
        key: lineKey,
        children: children,
      );
}
