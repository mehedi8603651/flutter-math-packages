import 'package:bangla_math_test/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('flutter_math_katex demo app builds', (tester) async {
    await tester.pumpWidget(const BanglaMathKatexApp());
    await tester.pumpAndSettle();

    final pageScroll = find.byType(Scrollable).first;

    expect(find.text('flutter_math_katex Test'), findsOneWidget);
    expect(
      find.text('This app tests flutter_math_katex rendering.'),
      findsOneWidget,
    );
    expect(find.text('1. UTF Text In Math'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('3. Matrix And Cases'),
      350,
      scrollable: pageScroll,
    );
    await tester.pumpAndSettle();

    expect(find.text('3. Matrix And Cases'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('5. Error Fallback'),
      350,
      scrollable: pageScroll,
    );
    await tester.pumpAndSettle();

    expect(find.text('4. Selectable Math'), findsOneWidget);
    expect(find.text('5. Error Fallback'), findsOneWidget);
    expect(find.text('TeX source'), findsWidgets);
  });
}
