import 'package:flutter/widgets.dart';

class LiteScripts extends StatelessWidget {
  const LiteScripts({
    super.key,
    required this.base,
    this.presup,
    this.presub,
    this.sup,
    this.sub,
    this.scriptGap = 0,
    this.baseGap = 0,
  });

  final Widget base;
  final Widget? presup;
  final Widget? presub;
  final Widget? sup;
  final Widget? sub;
  final double scriptGap;
  final double baseGap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (presup != null || presub != null) _buildScriptColumn(presup, presub),
        if (presup != null || presub != null) SizedBox(width: baseGap),
        base,
        if (sup != null || sub != null) SizedBox(width: baseGap),
        if (sup != null || sub != null) _buildScriptColumn(sup, sub),
      ],
    );
  }

  Widget _buildScriptColumn(Widget? upper, Widget? lower) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (upper != null) upper,
        if (upper != null && lower != null) SizedBox(height: scriptGap),
        if (lower != null) lower,
      ],
    );
  }
}
