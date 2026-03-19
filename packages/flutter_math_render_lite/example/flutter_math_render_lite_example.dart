import 'package:flutter/material.dart';
import 'package:flutter_math_render_lite/flutter_math_render_lite.dart';

void main() {
  runApp(const LiteRendererExampleApp());
}

class LiteRendererExampleApp extends StatelessWidget {
  const LiteRendererExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_math_render_lite example')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'This package is a small renderer backend. '
              'It builds widgets from a shared SyntaxTree without bundled KaTeX fonts.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _ExampleCard(
              title: 'Simple expression',
              child: LiteSyntaxTreeView(
                syntaxTree: SyntaxTree(
                  greenRoot: EquationRowNode(
                    children: [
                      LiteSymbolNode(symbol: 'f'),
                      LiteSymbolNode(symbol: '('),
                      LiteSymbolNode(symbol: 'x'),
                      LiteSymbolNode(symbol: ')'),
                      LiteSymbolNode(
                        symbol: '=',
                        overrideAtomType: AtomType.rel,
                      ),
                      FracNodeModel(
                        numerator: stringToLiteRow('1'),
                        denominator: stringToLiteRow('2'),
                      ),
                      LiteSymbolNode(symbol: '+'),
                      SqrtNodeModel(
                        index: stringToLiteRow('3'),
                        base: stringToLiteRow('x'),
                      ),
                    ],
                  ),
                ),
                options: const LiteMathOptions(fontSize: 26),
              ),
            ),
            const SizedBox(height: 20),
            _ExampleCard(
              title: 'Scripts and limits',
              child: LiteSyntaxTreeView(
                syntaxTree: SyntaxTree(
                  greenRoot: EquationRowNode(
                    children: [
                      MultiscriptsNodeModel(
                        base: stringToLiteRow('x'),
                        sub: stringToLiteRow('1'),
                        sup: stringToLiteRow('2'),
                      ),
                      LiteSymbolNode(symbol: '+'),
                      StretchyOpNodeModel(
                        symbol: '→',
                        above: stringToLiteRow('f'),
                        below: stringToLiteRow('g'),
                      ),
                    ],
                  ),
                ),
                options: const LiteMathOptions(
                  style: MathStyle.display,
                  fontSize: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
