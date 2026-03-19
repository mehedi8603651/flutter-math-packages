import 'package:flutter/material.dart';
import 'package:flutter_math_katex/ast.dart';
import 'package:flutter_math_katex/flutter_math_katex.dart';
import 'package:flutter_math_katex/tex.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tex surface is available', () {
    final ast = SyntaxTree(
      greenRoot: TexParser(r'\frac{a}{b}', const TexParserSettings()).parse(),
    );

    expect(ast.greenRoot.children, isNotEmpty);
    expect(TexEncoder().convert(ast.greenRoot), contains(r'\frac'));
  });

  testWidgets('widget surface is available', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Math.tex(
            r'x^2 + 1',
            mathStyle: MathStyle.display,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(Math), findsOneWidget);
  });
}
