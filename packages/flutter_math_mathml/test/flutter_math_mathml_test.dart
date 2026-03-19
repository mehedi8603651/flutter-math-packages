import 'package:flutter_math_mathml/flutter_math_mathml.dart';
import 'package:flutter_math_model/ast.dart';
import 'package:flutter_math_tex/flutter_math_tex.dart' as tex;
import 'package:test/test.dart';

void main() {
  group('encoder', () {
    test('encodes TeX parser output to MathML', () {
      final ast = tex.TexParser(
        r'\frac{\mathbb{R}+1}{x_2}',
        const tex.TexParserSettings(),
      ).parse();

      final encoded = ast.encodeMathML();

      expect(
        encoded,
        allOf(
          contains('<math xmlns="http://www.w3.org/1998/Math/MathML"'),
          contains('<mfrac>'),
          contains('mathvariant="double-struck"'),
          contains('<msub>'),
        ),
      );
    });

    test('encodes style wrappers with MathML mstyle attributes', () {
      final ast = StyleNode(
        children: <GreenNode>[
          EquationRowNode(
            children: <GreenNode>[
              SymbolNode(symbol: 'x'),
            ],
          ),
        ],
        optionsDiff: const OptionsDiff(
          color: MathColor.fromARGB(255, 255, 170, 102),
          size: MathSize.large,
          mathFontOptions: FontOptions(
            fontFamily: 'SansSerif',
            fontWeight: MathFontWeight.bold,
          ),
          style: MathStyle.script,
        ),
      );

      final encoded = ast.encodeMathML();

      expect(
        encoded,
        allOf(
          contains('mathcolor="#ffaa66"'),
          contains('mathsize="120.0%"'),
          contains('displaystyle="false"'),
          contains('scriptlevel="1"'),
          contains('mathvariant="bold-sans-serif"'),
        ),
      );
    });

    test('encodes matrix and equation array nodes as mtable', () {
      final matrix = MatrixNodeModel(
        body: <List<EquationRowNode?>>[
          <EquationRowNode?>[
            EquationRowNode(children: <GreenNode>[SymbolNode(symbol: 'a')]),
            EquationRowNode(children: <GreenNode>[SymbolNode(symbol: 'b')]),
          ],
          <EquationRowNode?>[
            EquationRowNode(children: <GreenNode>[SymbolNode(symbol: 'c')]),
            EquationRowNode(children: <GreenNode>[SymbolNode(symbol: 'd')]),
          ],
        ],
      );

      final equationArray = EquationArrayNodeModel(
        body: <EquationRowNode>[
          EquationRowNode(
            children: <GreenNode>[
              SymbolNode(symbol: 'x'),
              SpaceNodeModel.alignerOrSpacer(),
              SymbolNode(symbol: '=', overrideAtomType: AtomType.rel),
              SymbolNode(symbol: '1'),
            ],
          ),
        ],
      );

      final matrixEncoded = matrix.encodeMathML(
        conf: const MathMLEncodeConf(includeMathTag: false),
      );
      final eqArrayEncoded = equationArray.encodeMathML(
        conf: const MathMLEncodeConf(includeMathTag: false),
      );

      expect(
        matrixEncoded,
        allOf(
          contains('<mtable'),
          contains('<mtr>'),
          contains('<mtd>'),
          contains('<mi>a</mi>'),
          contains('<mi>d</mi>'),
        ),
      );
      expect(
        eqArrayEncoded,
        allOf(
          contains('<mtable'),
          contains('columnalign="left left"'),
          contains('<mo>=</mo>'),
          contains('<mn>1</mn>'),
        ),
      );
    });

    test('encodes menclose-like package node', () {
      final enclosure = EnclosureNode(
        base: EquationRowNode(children: <GreenNode>[SymbolNode(symbol: 'x')]),
        hasBorder: true,
        notation: const <String>['updiagonalstrike'],
        backgroundColor: const MathColor.fromARGB(255, 255, 255, 0),
      );

      final encoded = enclosure.encodeMathML(
        conf: const MathMLEncodeConf(includeMathTag: false),
      );

      expect(
        encoded,
        allOf(
          contains('<menclose notation="updiagonalstrike">'),
          contains('mathbackground="#ffff00"'),
          contains('<mi>x</mi>'),
        ),
      );
    });
  });

  group('parser', () {
    test('roundtrips encoder output for a TeX-derived AST', () {
      final original = tex.TexParser(
        r'\frac{\mathbb{R}+1}{x_2}',
        const tex.TexParserSettings(),
      ).parse();

      final mathml = original.encodeMathML();
      final parsed = parseMathML(mathml);

      expect(parsed.encodeMathML(), mathml);
    });

    test('parses style and token variants from raw MathML', () {
      final parsed = parseMathML(
        '<math xmlns="http://www.w3.org/1998/Math/MathML">'
        '<mstyle mathcolor="#ffaa66" mathsize="120.0%" displaystyle="false" '
        'scriptlevel="1" mathvariant="bold-sans-serif">'
        '<mrow><mi>x</mi></mrow>'
        '</mstyle>'
        '</math>',
      );

      final encoded = parsed.encodeMathML();

      expect(
        encoded,
        allOf(
          contains('mathcolor="#ffaa66"'),
          contains('mathsize="120.0%"'),
          contains('scriptlevel="1"'),
          contains('mathvariant="bold-sans-serif"'),
        ),
      );
    });

    test('parses menclose and padded phantom structures', () {
      final parsed = parseMathML(
        '<math xmlns="http://www.w3.org/1998/Math/MathML">'
        '<mrow>'
        '<menclose notation="updiagonalstrike">'
        '<mstyle mathbackground="#ffff00"><mrow><mi>x</mi></mrow></mstyle>'
        '</menclose>'
        '<mpadded width="0em"><mphantom><mrow><mi>y</mi></mrow></mphantom></mpadded>'
        '</mrow>'
        '</math>',
      );

      final encoded = parsed.encodeMathML();

      expect(
        encoded,
        allOf(
          contains('<menclose notation="updiagonalstrike">'),
          contains('mathbackground="#ffff00"'),
          contains('<mpadded width="0em">'),
          contains('<mphantom>'),
        ),
      );
    });
  });
}
