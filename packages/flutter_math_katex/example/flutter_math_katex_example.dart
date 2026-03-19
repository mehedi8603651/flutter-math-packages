import 'package:flutter/material.dart';
import 'package:flutter_math_katex/flutter_math_katex.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Math.tex(
            r'\sum_{n=1}^{\infty}\frac{1}{n^2}=\frac{\pi^2}{6}',
            mathStyle: MathStyle.display,
          ),
        ),
      ),
    ),
  );
}
