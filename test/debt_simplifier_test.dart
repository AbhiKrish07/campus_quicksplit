import 'package:flutter_test/flutter_test.dart';
import 'package:campus_quicksplit/models/person.dart';
import 'package:campus_quicksplit/models/expense.dart';
import 'package:campus_quicksplit/models/expense_category.dart';
import 'package:campus_quicksplit/models/split_mode.dart';
import 'package:campus_quicksplit/logic/debt_simplifier.dart';

void main() {
  group('DebtSimplifier Graph Algorithm Unit Tests', () {
    final now = DateTime.now();

    final p1 = const Person(id: 'p1', name: 'Alice', initials: 'A');
    final p2 = const Person(id: 'p2', name: 'Bob', initials: 'B');
    final p3 = const Person(id: 'p3', name: 'Charlie', initials: 'C');
    final people = [p1, p2, p3];

    test('Simplifies multi-person circular debt into minimal transfer path', () {
      // Expense 1: Alice pays $90 for Alice, Bob, Charlie ($30 each)
      // Net after Exp 1: Alice +60, Bob -30, Charlie -30
      final exp1 = Expense(
        id: 'e1',
        description: 'Dinner',
        amount: 90.0,
        category: CategoryType.food,
        paidById: 'p1',
        participantIds: ['p1', 'p2', 'p3'],
        timestamp: now,
      );

      // Expense 2: Bob pays $30 for Charlie
      // Net after Exp 2: Alice +60, Bob ( -30 + 30 = 0 ), Charlie ( -30 - 30 = -60 )
      final exp2 = Expense(
        id: 'e2',
        description: 'Cab',
        amount: 30.0,
        category: CategoryType.travel,
        paidById: 'p2',
        participantIds: ['p3'],
        timestamp: now,
      );

      final transactions = DebtSimplifier.simplifyDebts(people, [exp1, exp2]);

      // Optimal result: Only 1 transaction needed: Charlie pays Alice $60.00!
      expect(transactions.length, 1);
      expect(transactions.first.fromPersonId, 'p3');
      expect(transactions.first.toPersonId, 'p1');
      expect(transactions.first.amount, 60.0);
    });

    test('Granular percentage split mode calculation', () {
      final exp = Expense(
        id: 'e3',
        description: 'Rent',
        amount: 1000.0,
        category: CategoryType.rent,
        paidById: 'p1',
        participantIds: ['p1', 'p2'],
        splitMode: SplitMode.percentage,
        customShares: {'p1': 70.0, 'p2': 30.0},
        timestamp: now,
      );

      expect(exp.getShareForParticipant('p1'), 700.0);
      expect(exp.getShareForParticipant('p2'), 300.0);
    });
  });
}
