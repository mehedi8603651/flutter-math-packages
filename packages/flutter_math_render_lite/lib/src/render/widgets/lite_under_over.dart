import 'package:flutter/widgets.dart';

class LiteUnderOver extends StatelessWidget {
  const LiteUnderOver({
    super.key,
    required this.base,
    this.above,
    this.below,
    this.gap = 0,
  });

  final Widget base;
  final Widget? above;
  final Widget? below;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (above != null) above!,
        if (above != null) SizedBox(height: gap),
        base,
        if (below != null) SizedBox(height: gap),
        if (below != null) below!,
      ],
    );
  }
}
