import 'package:flutter/widgets.dart';
import 'package:flutter_math_render_katex/flutter_math_render_katex.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exposes packaged font family names', () {
    expect(
      KaTeXFontFamilies.packaged(KaTeXFontFamilies.main),
      'packages/flutter_math_render_katex/KaTeX_Main',
    );
    expect(KaTeXFontFamilies.all, contains(KaTeXFontFamilies.math));
  });

  test('looks up bundled KaTeX character metrics', () {
    final metrics = getCharacterMetrics(
      character: 'A',
      fontName: 'AMS-Regular',
      mode: Mode.math,
    );

    expect(metrics, isNotNull);
    expect(metrics!.width, closeTo(0.72222, 0.00001));
    expect(metrics.height, closeTo(0.68889, 0.00001));
  });

  test('returns global metrics for display sizes', () {
    final metrics = getGlobalMetrics(MathSize.normalsize);

    expect(metrics.quad, closeTo(1.0, 0.00001));
    expect(metrics.axisHeight, closeTo(0.25, 0.00001));
  });

  testWidgets('builds KaTeX symbol widgets', (tester) async {
    final result = makeBaseSymbol(
      symbol: '+',
      atomType: AtomType.bin,
      mode: Mode.math,
      options: MathOptions.textOptions,
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: 1,
          heightFactor: 1,
          child: result.widget,
        ),
      ),
    );

    expect(find.byWidget(result.widget), findsOneWidget);
  });

  testWidgets('builds static and stretchy svg widgets', (tester) async {
    final options = MathOptions.textOptions;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: 1,
          heightFactor: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              staticSvg('vec', options),
              strechySvgSpan('widehat', 48, options),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(Column), findsOneWidget);
  });

  testWidgets('builds shared layout widgets', (tester) async {
    final options = MathOptions.textOptions;
    final baseResult = BuildResult(
      options: options,
      widget: const Text('x'),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            EquationRowView(
              children: const <LineElement>[
                LineElement(child: Text('row')),
              ],
            ),
            Line(
              children: const <Widget>[
                LineElement(child: Text('a')),
              ],
            ),
            VList(
              children: const <Widget>[
                VListElement(child: Text('b')),
              ],
            ),
            LayoutBuilderPreserveBaseline(
              builder: (_, __) => const Text('baseline'),
            ),
            const RemoveBaseline(
              child: Text('baseline-removed'),
            ),
            const MinDimension(
              minHeight: 12,
              minDepth: 3,
              child: Text('min-dimension'),
            ),
            Multiscripts(
              isBaseCharacterBox: true,
              baseResult: baseResult,
            ),
            EqnArray(
              ruleThickness: 1.0,
              jotSize: 0.0,
              arrayskip: 12.0,
              hlines: const <MatrixSeparatorStyle>[
                MatrixSeparatorStyle.none,
                MatrixSeparatorStyle.none,
              ],
              rowSpacings: const <double>[0.0],
              children: <Widget>[
                Line(
                  children: const <Widget>[
                    LineElement(child: Text('c')),
                  ],
                ),
              ],
            ),
            EditableLine(
              basePosition: 0,
              caretPositions: const <int>[1, 2],
              cursorColor: const Color(0xFF000000),
              preferredLineHeight: 16.0,
              children: const <Widget>[
                LineElement(child: Text('d')),
              ],
            ),
          ],
        ),
      ),
    );

    expect(find.byType(EquationRowView), findsOneWidget);
    expect(find.byType(Line), findsNWidgets(3));
    expect(find.byType(VList), findsOneWidget);
    expect(find.byType(LayoutBuilderPreserveBaseline), findsOneWidget);
    expect(find.byType(RemoveBaseline), findsOneWidget);
    expect(find.byType(MinDimension), findsOneWidget);
    expect(find.byType(Multiscripts), findsOneWidget);
    expect(find.byType(EqnArray), findsOneWidget);
    expect(find.byType(EditableLine), findsOneWidget);
  });
}
