import 'package:flutter/material.dart';
import 'package:flutter_math_katex/flutter_math_katex.dart';

const _utfTextFormula =
    r'\text{বাংলা গণিত পরীক্ষা} + \text{العربية} + x^2 = 25';

const _analysisFormula =
    r'\int_0^\infty e^{-x^2}\,\mathrm{d}x = \frac{\sqrt{\pi}}{2}'
    r'\qquad\text{and}\qquad'
    r'\sum_{n=1}^{\infty}\frac{x^n}{n!}=e^x-1';

const _matrixAndCasesFormula =
    r'A=\begin{bmatrix}'
    r'1 & 2 & 3 \\'
    r'4 & 5 & 6 \\'
    r'7 & 8 & 9'
    r'\end{bmatrix}'
    r'\qquad'
    r'f(x)=\begin{cases}'
    r'x^2 & x\ge 0 \\'
    r'-x & x<0'
    r'\end{cases}';

const _selectableFormula =
    r'\left(\frac{\partial}{\partial x} + \frac{\partial}{\partial y}\right)^2'
    r'\phi(x,y)'
    r'='
    r'\frac{\partial^2\text{বাংলা গণিত পরীক্ষা}}{\partial x^2}'
    r'+2\frac{\partial^2\phi}{\partial x\partial y}'
    r'+\frac{\partial^2\phi}{\partial y^2}';

const _brokenFormula = r'\frac{1}{';

void main() {
  runApp(const BanglaMathKatexApp());
}

class BanglaMathKatexApp extends StatelessWidget {
  const BanglaMathKatexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'flutter_math_katex Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14532D),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const BanglaMathKatexPage(),
    );
  }
}

class BanglaMathKatexPage extends StatelessWidget {
  const BanglaMathKatexPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('flutter_math_katex Test')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'This app tests flutter_math_katex rendering.',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'All examples below are rendered with the KaTeX-backed widget package, not just parsed as text.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Check 3 things: UTF text inside \\text{...}, larger display equations, and selectable math.',
            ),
          ),
          const SizedBox(height: 22),
          _MathSection(
            title: '1. UTF Text In Math',
            description:
                'Bangla and Arabic text are rendered inside TeX text mode together with math symbols.',
            source: _utfTextFormula,
            child: Math.tex(
              _utfTextFormula,
              mathStyle: MathStyle.text,
              textStyle: const TextStyle(fontSize: 28),
            ),
          ),
          _MathSection(
            title: '2. Complex Display Formula',
            description:
                'A larger display equation using an improper integral, radicals, and an infinite series.',
            source: _analysisFormula,
            child: Math.tex(
              _analysisFormula,
              mathStyle: MathStyle.display,
              textStyle: const TextStyle(fontSize: 26),
            ),
          ),
          _MathSection(
            title: '3. Matrix And Cases',
            description:
                'Tests array-like layout with a matrix and a piecewise function in one row.',
            source: _matrixAndCasesFormula,
            child: Math.tex(
              _matrixAndCasesFormula,
              mathStyle: MathStyle.display,
              textStyle: const TextStyle(fontSize: 24),
            ),
          ),
          _MathSection(
            title: '4. Selectable Math',
            description:
                'Long-press or drag to test selection and copy support on a non-trivial expression.',
            source: _selectableFormula,
            child: SelectableMath.tex(
              _selectableFormula,
              mathStyle: MathStyle.display,
              textStyle: const TextStyle(fontSize: 24),
            ),
          ),
          _MathSection(
            title: '5. Error Fallback',
            description:
                'Intentional invalid TeX so you can confirm the package surfaces parser errors in the widget layer.',
            source: _brokenFormula,
            child: Math.tex(
              _brokenFormula,
              mathStyle: MathStyle.display,
              textStyle: const TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _MathSection extends StatelessWidget {
  final String title;
  final String description;
  final String source;
  final Widget child;

  const _MathSection({
    required this.title,
    required this.description,
    required this.source,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(description),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TeX source',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    source,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
