import 'package:flutter_test/flutter_test.dart';
import 'package:campus_quicksplit/main.dart';

void main() {
  testWidgets('CampusQuickSplitApp builds cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusQuickSplitApp());
    expect(find.text('Campus QuickSplit'), findsNothing); // Title is in MaterialApp
    expect(find.text('Good Morning,'), findsOneWidget);
  });
}
