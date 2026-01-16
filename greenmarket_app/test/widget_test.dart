import 'package:flutter_test/flutter_test.dart';
import 'package:greenmarket_app/main.dart';

void main() {
  testWidgets('GreenMarket app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GreenMarketApp());
    expect(find.text('Toshkent, Chilonzor'), findsOneWidget);
  });
}
