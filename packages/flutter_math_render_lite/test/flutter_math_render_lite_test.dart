import 'package:flutter/widgets.dart';
import 'package:flutter_math_render_lite/flutter_math_render_lite.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scales child options by style', () {
    const options = LiteMathOptions(
      style: MathStyle.display,
      fontSize: 20,
    );

    expect(options.forChildStyle(MathStyle.script).fontSize, 14);
    expect(options.forChildStyle(MathStyle.scriptscript).fontSize, 10);
  });

  test('keeps default system-font fallback for main math fonts', () {
    const options = LiteMathOptions(
      mathFontOptions: FontOptions(fontFamily: 'Main'),
    );

    final style = options.resolveTextStyle();
    expect(style.fontFamily, isNull);
  });

  test('merges pure options diff into lite options', () {
    const options = LiteMathOptions(
      fontSize: 20,
      color: Color(0xFF000000),
      textFontOptions: FontOptions(fontFamily: 'Main'),
    );

    final merged = options.merge(
      const OptionsDiff(
        style: MathStyle.script,
        color: MathColor.fromARGB(0xff, 0x12, 0x34, 0x56),
        textFontOptions: PartialFontOptions(
          fontWeight: MathFontWeight.bold,
        ),
      ),
    );

    expect(merged.style, MathStyle.script);
    expect(merged.color, const Color(0xFF123456));
    expect(merged.textFontOptions?.fontWeight, MathFontWeight.bold);
  });

  testWidgets('builds lite renderer primitives', (tester) async {
    final symbol = buildLiteSymbol(
      symbol: 'x',
      options: const LiteMathOptions(),
    );

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: 1,
          heightFactor: 1,
          child: LiteLine(
            spacing: 4,
            children: <Widget>[
              LiteSymbol(
                symbol: 'a',
                options: LiteMathOptions(),
              ),
              LiteFraction(
                numerator: Text('1'),
                denominator: Text('2'),
                options: LiteMathOptions(),
              ),
              LiteSqrt(
                index: Text('3'),
                radicand: Text('x+1'),
                options: LiteMathOptions(),
              ),
            ],
          ),
        ),
      ),
    );

    expect(symbol.widget, isA<LiteSymbol>());
    expect(find.byType(LiteLine), findsOneWidget);
    expect(find.byType(LiteSymbol), findsOneWidget);
    expect(find.byType(LiteFraction), findsOneWidget);
    expect(find.byType(LiteSqrt), findsOneWidget);
  });

  testWidgets('builds a syntax tree for supported lite nodes', (tester) async {
    final syntaxTree = SyntaxTree(
      greenRoot: EquationRowNode(
        children: <GreenNode>[
          LiteSymbolNode(symbol: 'x'),
          SpaceNodeModel(
            height: Measurement.zero,
            width: const Measurement(value: 0.5, unit: Unit.em),
            mode: Mode.math,
          ),
          FracNodeModel(
            numerator: stringToLiteRow('1'),
            denominator: stringToLiteRow('2'),
          ),
          LiteSymbolNode(symbol: '+'),
          SqrtNodeModel(
            index: stringToLiteRow('3'),
            base: stringToLiteRow('y'),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: 1,
          heightFactor: 1,
          child: LiteSyntaxTreeView(
            syntaxTree: syntaxTree,
            options: const LiteMathOptions(),
          ),
        ),
      ),
    );

    expect(find.byType(LiteSyntaxTreeView), findsOneWidget);
    expect(find.byType(LiteLine), findsWidgets);
    expect(find.byType(LiteFraction), findsOneWidget);
    expect(find.byType(LiteSqrt), findsOneWidget);
  });

  testWidgets('builds extended shared lite nodes', (tester) async {
    final syntaxTree = SyntaxTree(
      greenRoot: EquationRowNode(
        children: <GreenNode>[
          FunctionNodeModel(
            functionName: stringToLiteRow('sin'),
            argument: stringToLiteRow('x'),
          ),
          LiteSymbolNode(symbol: '+'),
          MultiscriptsNodeModel(
            base: stringToLiteRow('x'),
            sub: stringToLiteRow('i'),
            sup: stringToLiteRow('2'),
          ),
          LiteSymbolNode(symbol: '+'),
          OverNodeModel(
            base: stringToLiteRow('A'),
            above: stringToLiteRow('~'),
          ),
          LiteSymbolNode(symbol: '+'),
          UnderNodeModel(
            base: stringToLiteRow('B'),
            below: stringToLiteRow('_'),
          ),
          LiteSymbolNode(symbol: '+'),
          LeftRightNodeModel(
            leftDelim: '(',
            rightDelim: ')',
            body: <EquationRowNode>[
              stringToLiteRow('x'),
              stringToLiteRow('y'),
            ],
            middle: const <String?>['|'],
          ),
          LiteSymbolNode(symbol: '+'),
          StretchyOpNodeModel(
            symbol: '→',
            above: stringToLiteRow('f'),
            below: stringToLiteRow('g'),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: 1,
          heightFactor: 1,
          child: LiteSyntaxTreeView(
            syntaxTree: syntaxTree,
            options: const LiteMathOptions(),
          ),
        ),
      ),
    );

    expect(find.byType(LiteScripts), findsOneWidget);
    expect(find.byType(LiteUnderOver), findsNWidgets(3));
    expect(find.byType(LiteDelimited), findsOneWidget);
    expect(find.text('('), findsOneWidget);
    expect(find.text(')'), findsOneWidget);
    expect(find.text('|'), findsOneWidget);
    expect(find.text('→'), findsOneWidget);
  });

  testWidgets('renders shared style nodes with merged lite options',
      (tester) async {
    final syntaxTree = SyntaxTree(
      greenRoot: EquationRowNode(
        children: <GreenNode>[
          StyleNode(
            children: <GreenNode>[
              LiteSymbolNode(symbol: 'x', mode: Mode.text),
            ],
            optionsDiff: const OptionsDiff(
              style: MathStyle.script,
              color: MathColor.fromARGB(0xff, 0x12, 0x34, 0x56),
              textFontOptions: PartialFontOptions(
                fontWeight: MathFontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: 1,
          heightFactor: 1,
          child: LiteSyntaxTreeView(
            syntaxTree: syntaxTree,
            options: const LiteMathOptions(),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('x'));
    expect(text.style?.color, const Color(0xFF123456));
    expect(text.style?.fontWeight, FontWeight.w700);
    expect(text.style?.fontSize, LiteMathOptions.defaultFontSize * 0.7);
  });

  testWidgets('builds remaining shared lite nodes', (tester) async {
    final syntaxTree = SyntaxTree(
      greenRoot: EquationRowNode(
        children: <GreenNode>[
          AccentNodeModel(
            base: stringToLiteRow('x'),
            label: '^',
            isStretchy: false,
            isShifty: false,
          ),
          LiteSymbolNode(symbol: '+'),
          AccentUnderNodeModel(
            base: stringToLiteRow('y'),
            label: '_',
          ),
          LiteSymbolNode(symbol: '+'),
          NaryOperatorNodeModel(
            operator: '∑',
            lowerLimit: stringToLiteRow('i'),
            upperLimit: stringToLiteRow('n'),
            naryand: stringToLiteRow('x'),
          ),
          LiteSymbolNode(symbol: '+'),
          RaiseBoxNodeModel(
            body: stringToLiteRow('z'),
            dy: const Measurement(value: 0.3, unit: Unit.em),
          ),
          LiteSymbolNode(symbol: '+'),
          PhantomNodeModel(
            phantomChild: stringToLiteRow('p'),
            zeroWidth: true,
          ),
          LiteSymbolNode(symbol: '+'),
          MatrixNodeModel(
            columnAligns: const <MatrixColumnAlign>[
              MatrixColumnAlign.left,
              MatrixColumnAlign.right,
            ],
            vLines: const <MatrixSeparatorStyle>[
              MatrixSeparatorStyle.solid,
              MatrixSeparatorStyle.none,
              MatrixSeparatorStyle.solid,
            ],
            hLines: const <MatrixSeparatorStyle>[
              MatrixSeparatorStyle.solid,
              MatrixSeparatorStyle.none,
              MatrixSeparatorStyle.solid,
            ],
            body: <List<EquationRowNode?>>[
              <EquationRowNode?>[stringToLiteRow('a'), stringToLiteRow('b')],
              <EquationRowNode?>[stringToLiteRow('c'), null],
            ],
          ),
          LiteSymbolNode(symbol: '+'),
          EquationArrayNodeModel(
            addJot: true,
            body: <EquationRowNode>[
              stringToLiteRow('r1'),
              stringToLiteRow('r2'),
            ],
            hlines: const <MatrixSeparatorStyle>[
              MatrixSeparatorStyle.solid,
              MatrixSeparatorStyle.none,
              MatrixSeparatorStyle.solid,
            ],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: 1,
          heightFactor: 1,
          child: LiteSyntaxTreeView(
            syntaxTree: syntaxTree,
            options: const LiteMathOptions(),
          ),
        ),
      ),
    );

    expect(find.byType(LiteAccent), findsNWidgets(2));
    expect(find.byType(LiteMatrix), findsOneWidget);
    expect(find.byType(LiteEquationArray), findsOneWidget);
    expect(find.text('∑'), findsOneWidget);
  });
}
