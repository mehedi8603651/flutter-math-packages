import 'package:flutter/material.dart';
import 'package:flutter_math_katex/flutter_math_katex.dart';

void main() {
  runApp(const KatexExampleApp());
}

class KatexExampleApp extends StatelessWidget {
  const KatexExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_math_katex example')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'High-fidelity TeX rendering for Flutter widgets.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _ExampleSection(
              title: 'Inline text mode',
              description:
                  'Use MathStyle.text when the formula should behave like inline content.',
              child: Math.tex(
                r'\text{বাংলা গণিত পরীক্ষা} + \text{العربية} + x^2 = 25',
                mathStyle: MathStyle.text,
                textStyle: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            _ExampleSection(
              title: 'Display math',
              description:
                  'Display style is the better default for larger standalone equations.',
              child: Math.tex(
                r'\int_0^\infty e^{-x^2}\,\mathrm{d}x = \frac{\sqrt{\pi}}{2}',
                mathStyle: MathStyle.display,
                textStyle: const TextStyle(fontSize: 30),
              ),
            ),
            const SizedBox(height: 20),
            _ExampleSection(
              title: 'Structured layout',
              description:
                  'Matrices, scripts, and larger operators work through the same widget API.',
              child: Math.tex(
                r'\begin{bmatrix}1 & 2 \\ 3 & 4\end{bmatrix}'
                r'\begin{bmatrix}x \\ y\end{bmatrix}'
                r'='
                r'\begin{bmatrix}5 \\ 11\end{bmatrix}',
                mathStyle: MathStyle.display,
                textStyle: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(height: 20),
            _ExampleSection(
              title: 'Selectable math',
              description:
                  'Use SelectableMath when users need selection or copy support.',
              child: SelectableMath.tex(
                r'\sum_{n=1}^{\infty}\frac{x_n}{n!}'
                r'='
                r'\frac{\sqrt{x^2+1}}{\mathbb{R}_2}',
                mathStyle: MathStyle.display,
                textStyle: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(height: 20),
            _ExampleSection(
              title: 'Handled parse error',
              description:
                  'You can provide a custom fallback instead of exposing a raw exception.',
              child: Math.tex(
                r'\frac{1}{',
                mathStyle: MathStyle.display,
                onErrorFallback: (error) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    error.messageWithType,
                    style: const TextStyle(color: Color(0xFFB71C1C)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleSection extends StatelessWidget {
  const _ExampleSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
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
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
