import 'package:flutter_math_model/flutter_math_model.dart';
import 'package:test/test.dart';

void main() {
  group('package info', () {
    test('exposes a stable package name', () {
      expect(flutterMathModelPackageName, 'flutter_math_model');
    });

    test('exposes a non-empty summary', () {
      expect(flutterMathModelPackageSummary, isNotEmpty);
    });

    test('package info object stays in sync with exported constants', () {
      expect(
        flutterMathModelPackageInfo,
        const FlutterMathModelPackageInfo(
          name: flutterMathModelPackageName,
          version: flutterMathModelPackageVersion,
          summary: flutterMathModelPackageSummary,
        ),
      );
    });
  });

  group('model ast', () {
    test('measurement values are pure model value objects', () {
      expect(Measurement.zero, const Measurement(value: 0, unit: Unit.pt));
      expect(2.pt.toString(), '2.0pt');
      expect(UnitExt.parse('mu'), Unit.mu);
      expect('cssEm'.parseUnit(), Unit.cssEm);
    });

    test('math style helpers keep TeX-style reductions', () {
      expect(MathStyle.display.sup(), MathStyle.scriptCramped);
      expect(MathStyle.text.cramp(), MathStyle.textCramped);
      expect(MathStyle.script.isTight(), isTrue);
      expect(
          MathSize.large.underStyle(MathStyle.script), MathSize.footnotesize);
    });

    test('font and color options stay pure and comparable', () {
      const color = MathColor.fromARGB(0xff, 0x11, 0x22, 0x33);
      const font = FontOptions(
        fontFamily: 'Main',
        fontWeight: MathFontWeight.bold,
        fontShape: MathFontStyle.italic,
      );
      const diff = OptionsDiff(
        color: color,
        textFontOptions: PartialFontOptions(
          fontWeight: MathFontWeight.bold,
        ),
        mathFontOptions: font,
      );

      expect(color.toARGB32(), 0xff112233);
      expect(font.fontName, 'Main-BoldItalic');
      expect(font, font.mergeWith(const PartialFontOptions()));
      expect(diff.removeStyle(), same(diff));
      expect(diff.removeMathFont().mathFontOptions, isNull);
    });

    test('style node model is reusable across tree implementations', () {
      final model = StyleNodeModel<String>(
        children: const ['a', 'b'],
        optionsDiff: const OptionsDiff(
          color: MathColor.fromARGB(0xff, 0x12, 0x34, 0x56),
        ),
      );

      expect(
        model.toJsonWith((child) => child),
        <String, Object?>{
          'children': const ['a', 'b'],
          'optionsDiff':
              'OptionsDiff(style: null, size: null, color: MathColor(0xff123456), textFontOptions: null, mathFontOptions: null)',
        },
      );
      expect(model.copyWith().children, const ['a', 'b']);
      expect(model.mapChildren<int>(const [1, 2]).children, const [1, 2]);
    });

    test('style node is a shared transparent green node wrapper', () {
      final child = _TokenNode('x');
      final node = StyleNode(
        children: [child],
        optionsDiff: const OptionsDiff(
          style: MathStyle.script,
          color: MathColor.fromARGB(0xff, 0x12, 0x34, 0x56),
        ),
      );

      expect(node.children, [child]);
      expect(node.flattenedChildList, [child]);
      expect(node.leftType, child.leftType);
      expect(node.rightType, child.rightType);
      expect(
        node.updateChildren([_TokenNode('y')]).children.first,
        isA<_TokenNode>(),
      );
      expect(
        node.toJson()['optionsDiff'],
        contains('MathColor(0xff123456)'),
      );
    });

    test('symbol node model keeps parser-facing metadata', () {
      const model = SymbolNodeModel(
        symbol: 'x',
        mode: Mode.text,
        variantForm: true,
        overrideAtomType: AtomType.rel,
        overrideFont: FontOptions(fontFamily: 'Main'),
      );

      expect(model.withSymbol('y').symbol, 'y');
      expect(
        model.toJsonWith(
          symbolValue: 'x',
          modeValue: 'Mode.text',
          overrideAtomTypeValue: 'AtomType.rel',
          overrideFontValue: 'Main-Regular',
        ),
        <String, Object?>{
          'mode': 'Mode.text',
          'symbol': 'x',
          'variantForm': true,
          'atomType': 'AtomType.rel',
          'overrideFont': 'Main-Regular',
        },
      );
    });

    test('finds nodes at a position', () {
      final tree = SyntaxTree(
        greenRoot: EquationRowNode(
          children: [
            _TokenNode('a'),
            _TokenNode('b'),
          ],
        ),
      );

      final nodes = tree.findNodesAtPosition(0);

      expect(nodes.length, 2);
      expect(nodes.first.value, same(tree.greenRoot));
      expect((nodes.last.value as _TokenNode).value, 'a');
    });

    test('replaces a leaf node through the red tree facade', () {
      final tree = SyntaxTree(
        greenRoot: EquationRowNode(
          children: [
            _TokenNode('a'),
            _TokenNode('b'),
          ],
        ),
      );

      final target = tree.findNodesAtPosition(1).last;
      final updated = tree.replaceNode(target, _TokenNode('c'));

      final values = updated.greenRoot.children
          .cast<_TokenNode>()
          .map((node) => node.value)
          .toList(growable: false);

      expect(values, ['a', 'c']);
    });

    test('flattens transparent nodes for editing order', () {
      final row = EquationRowNode(
        children: [
          _TokenNode('a'),
          _TransparentGroupNode([
            _TokenNode('b'),
            _TokenNode('c'),
          ]),
          _TokenNode('d'),
        ],
      );

      final values = row.flattenedChildList
          .cast<_TokenNode>()
          .map((node) => node.value)
          .toList(growable: false);

      expect(values, ['a', 'b', 'c', 'd']);
    });

    test('clips children by editing positions', () {
      final row = EquationRowNode(
        children: [
          _TokenNode('a'),
          _TokenNode('b'),
          _TokenNode('c'),
        ],
      );

      final clipped = row.clipChildrenBetween(1, 3) as EquationRowNode;
      final values = clipped.children
          .cast<_TokenNode>()
          .map((node) => node.value)
          .toList(growable: false);

      expect(values, ['a', 'b']);
    });

    test('finds selected nodes through the syntax tree API', () {
      final tree = SyntaxTree(
        greenRoot: EquationRowNode(
          children: [
            _TokenNode('a'),
            _TokenNode('b'),
            _TokenNode('c'),
          ],
        ),
      );

      final selected = tree.findSelectedNodes(0, 2);
      final values = selected
          .cast<_TokenNode>()
          .map((node) => node.value)
          .toList(growable: false);

      expect(values, ['a', 'b']);
    });

    test('wrap and unwrap helpers keep equation-row ergonomics', () {
      final token = _TokenNode('x');

      expect(token.wrapWithEquationRow().children, [token]);
      expect(token.expandEquationRow(), [token]);
      expect(token.wrapWithEquationRow().unwrapEquationRow(), same(token));
      expect([token].wrapWithEquationRow().children, [token]);
    });

    test('function node model keeps slot order and atom types', () {
      final functionName = EquationRowNode(children: [_TokenNode('f')]);
      final argument = EquationRowNode(children: [_TokenNode('x')]);
      final node = FunctionNodeModel(
        functionName: functionName,
        argument: argument,
      );

      expect(node.children, [functionName, argument]);
      expect(node.leftType, AtomType.op);
      expect(node.rightType, argument.rightType);
      expect(
        node
            .updateChildren([
              EquationRowNode(children: [_TokenNode('g')]),
              argument,
            ])
            .functionName
            .children
            .first,
        isA<_TokenNode>(),
      );
    });

    test('left-right node model preserves delimiter metadata', () {
      final row = EquationRowNode(children: [_TokenNode('x')]);
      final node = LeftRightNodeModel(
        leftDelim: '(',
        rightDelim: ')',
        body: [row, row],
        middle: const ['|'],
      );

      expect(node.children, [row, row]);
      expect(node.leftType, AtomType.open);
      expect(node.rightType, AtomType.close);
      expect(node.middle, const ['|']);
    });

    test('phantom node model keeps dimension flags in json', () {
      final node = PhantomNodeModel(
        phantomChild: EquationRowNode(children: [_TokenNode('x')]),
        zeroWidth: true,
        zeroHeight: true,
      );

      expect(node.mode, Mode.math);
      expect(node.leftType, AtomType.ord);
      expect(node.toJson()['zeroWidth'], isTrue);
      expect(node.toJson()['zeroHeight'], isTrue);
      expect(node.toJson().containsKey('zeroDepth'), isFalse);
    });

    test('over and under node models keep base-first child order', () {
      final base = EquationRowNode(children: [_TokenNode('x')]);
      final label = EquationRowNode(children: [_TokenNode('y')]);
      final over = OverNodeModel(base: base, above: label, stackRel: true);
      final under = UnderNodeModel(base: base, below: label);

      expect(over.children, [base, label]);
      expect(over.leftType, AtomType.rel);
      expect(over.rightType, AtomType.rel);
      expect(under.children, [base, label]);
      expect(under.leftType, AtomType.ord);
      expect(under.rightType, AtomType.ord);
    });

    test('sqrt node model keeps index-before-base slot order', () {
      final index = EquationRowNode(children: [_TokenNode('n')]);
      final base = EquationRowNode(children: [_TokenNode('x')]);
      final node = SqrtNodeModel(index: index, base: base);

      expect(node.children, [index, base]);
      expect(node.leftType, AtomType.ord);
      expect(node.rightType, AtomType.ord);
      expect(
        node
            .updateChildren([
              null,
              EquationRowNode(children: [_TokenNode('y')])
            ])
            .base
            .children
            .first,
        isA<_TokenNode>(),
      );
    });

    test('multiscripts node model tracks script-sensitive atom types', () {
      final base = EquationRowNode(children: [_TokenNode('x')]);
      final sub = EquationRowNode(children: [_TokenNode('i')]);
      final presup = EquationRowNode(children: [_TokenNode('j')]);

      final simple = MultiscriptsNodeModel(base: base, sub: sub);
      final withPrescripts = MultiscriptsNodeModel(
        base: base,
        sub: sub,
        presup: presup,
        alignPostscripts: true,
      );

      expect(simple.children, [base, sub, null, null, null]);
      expect(simple.leftType, base.leftType);
      expect(simple.rightType, AtomType.ord);
      expect(withPrescripts.leftType, AtomType.ord);
      expect(withPrescripts.toJson()['alignPostscripts'], isTrue);
    });

    test('nary operator node model keeps operator and argument semantics', () {
      final lower = EquationRowNode(children: [_TokenNode('0')]);
      final upper = EquationRowNode(children: [_TokenNode('n')]);
      final body = EquationRowNode(children: [_TokenNode('x')]);
      final node = NaryOperatorNodeModel(
        operator: '∑',
        lowerLimit: lower,
        upperLimit: upper,
        naryand: body,
        limits: true,
      );

      expect(node.children, [lower, upper, body]);
      expect(node.leftType, AtomType.op);
      expect(node.rightType, body.rightType);
      expect(node.toJson()['operator'], '∑');
      expect(node.toJson()['limits'], isTrue);
    });
    test('frac node model keeps numerator-denominator slots and metadata', () {
      final numerator = EquationRowNode(children: [_TokenNode('a')]);
      final denominator = EquationRowNode(children: [_TokenNode('b')]);
      final node = FracNodeModel(
        numerator: numerator,
        denominator: denominator,
        barSize: 0.4.pt,
        continued: true,
      );

      expect(node.children, [numerator, denominator]);
      expect(node.leftType, AtomType.ord);
      expect(node.rightType, AtomType.ord);
      expect(node.toJson()['barSize'], '0.4pt');
      expect(node.toJson()['continued'], isTrue);
    });

    test('raise box node model keeps vertical displacement metadata', () {
      final body = EquationRowNode(children: [_TokenNode('x')]);
      final node = RaiseBoxNodeModel(body: body, dy: 1.5.ex);

      expect(node.children, [body]);
      expect(node.dy, 1.5.ex);
      expect(node.toJson()['dy'], '1.5ex');
    });

    test('space node model keeps break and alignment flags', () {
      final space = SpaceNodeModel(
        height: Measurement.zero,
        width: 1.em,
        breakPenalty: 50,
        mode: Mode.math,
      );
      final aligner = SpaceNodeModel.alignerOrSpacer();

      expect(space.leftType, AtomType.spacing);
      expect(space.toJson()['breakPenalty'], 50);
      expect(aligner.alignerOrSpacer, isTrue);
      expect(aligner.fill, isTrue);
    });

    test('accent models preserve labels and slot order', () {
      final base = EquationRowNode(children: [_TokenNode('x')]);
      final accent = AccentNodeModel(
        base: base,
        label: '^',
        isStretchy: false,
        isShifty: true,
      );
      final under = AccentUnderNodeModel(
        base: base,
        label: '_',
      );

      expect(accent.children, [base]);
      expect(accent.toJson()['label'], '^');
      expect(under.children, [base]);
      expect(under.toJson()['label'], '_');
    });

    test('stretchy op model keeps nullable attachments', () {
      final above = EquationRowNode(children: [_TokenNode('x')]);
      final node = StretchyOpNodeModel(
        above: above,
        below: null,
        symbol: '→',
      );

      expect(node.children, [above, null]);
      expect(node.leftType, AtomType.rel);
      expect(node.rightType, AtomType.rel);
      expect(node.toJson()['symbol'], '→');
    });

    test('equation array model pads separator and spacing metadata', () {
      final row = EquationRowNode(children: [_TokenNode('x')]);
      final node = EquationArrayNodeModel(
        body: [row],
        hlines: const [MatrixSeparatorStyle.solid],
      );

      expect(node.children, [row]);
      expect(node.hlines.length, 2);
      expect(node.hlines[1], MatrixSeparatorStyle.none);
      expect(node.rowSpacings, [Measurement.zero]);
    });

    test('matrix node model sanitizes dimensions and preserves null cells', () {
      final cell = EquationRowNode(children: [_TokenNode('x')]);
      final node = MatrixNodeModel(
        columnAligns: const [MatrixColumnAlign.left],
        body: [
          [cell],
          [],
        ],
      );

      expect(node.rows, 2);
      expect(node.cols, 1);
      expect(node.children, [cell, null]);
      expect(node.columnAligns, [MatrixColumnAlign.left]);
      expect(node.vLines.length, 2);
      expect(node.hLines.length, 3);
    });
  });
}

final class _TokenNode extends LeafNode {
  final String value;

  _TokenNode(this.value);

  @override
  Mode get mode => Mode.math;

  @override
  AtomType get leftType => AtomType.ord;

  @override
  AtomType get rightType => AtomType.ord;

  @override
  Map<String, Object?> toJson() => super.toJson()..['value'] = value;
}

final class _TransparentGroupNode extends TransparentNode {
  @override
  final List<GreenNode> children;

  _TransparentGroupNode(this.children);

  @override
  _TransparentGroupNode updateChildren(List<GreenNode> newChildren) =>
      _TransparentGroupNode(newChildren);
}
