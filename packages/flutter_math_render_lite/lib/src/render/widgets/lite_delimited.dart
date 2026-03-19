import 'package:flutter/widgets.dart';

import '../../lite_math_options.dart';
import 'lite_line.dart';
import 'lite_symbol.dart';

class LiteDelimited extends StatelessWidget {
  const LiteDelimited({
    super.key,
    required this.body,
    required this.options,
    this.leftDelimiter,
    this.rightDelimiter,
    this.middleDelimiters = const <String?>[],
  });

  final List<Widget> body;
  final LiteMathOptions options;
  final String? leftDelimiter;
  final String? rightDelimiter;
  final List<String?> middleDelimiters;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (_showsDelimiter(leftDelimiter))
        LiteSymbol(
          symbol: leftDelimiter!,
          options: options.copyWith(fontSize: options.fontSize * 1.1),
        ),
    ];

    for (var index = 0; index < body.length; index++) {
      children.add(body[index]);
      if (index < middleDelimiters.length &&
          _showsDelimiter(middleDelimiters[index])) {
        children.add(
          LiteSymbol(
            symbol: middleDelimiters[index]!,
            options: options.copyWith(fontSize: options.fontSize * 1.1),
          ),
        );
      }
    }

    if (_showsDelimiter(rightDelimiter)) {
      children.add(
        LiteSymbol(
          symbol: rightDelimiter!,
          options: options.copyWith(fontSize: options.fontSize * 1.1),
        ),
      );
    }

    return LiteLine(children: children);
  }

  static bool _showsDelimiter(String? delimiter) =>
      delimiter != null && delimiter != '.';
}
