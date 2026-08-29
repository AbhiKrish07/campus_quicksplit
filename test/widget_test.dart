import 'package:flutter_test/flutter_test.dart';
import 'package:campus_quicksplit/main.dart';

void main() {
  testWidgets('CampusQuickSplitApp builds cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusQuickSplitApp());
    await tester.pumpAndSettle();
    expect(find.text('Good Morning,'), findsOneWidget);
  });
}
