import 'package:flutter_test/flutter_test.dart';
import 'package:parking/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const ParkingApp());
    expect(find.text('Smart Park - SUK'), findsOneWidget);
  });
}
