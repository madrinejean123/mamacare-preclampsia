import 'package:flutter_test/flutter_test.dart';

import 'package:mamasafe/main.dart';

void main() {
  testWidgets('Landing page renders the MamaSafe headline', (WidgetTester tester) async {
    await tester.pumpWidget(const MamaSafeApp());
    await tester.pumpAndSettle();

    expect(find.text('MamaSafe'), findsWidgets);
    expect(find.textContaining('Detect preeclampsia risk'), findsOneWidget);
  });
}
