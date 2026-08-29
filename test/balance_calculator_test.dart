import 'package:flutter_test/flutter_test.dart';
import 'package:campus_quicksplit/models/expense.dart';
import 'package:campus_quicksplit/models/expense_category.dart';
import 'package:campus_quicksplit/logic/balance_calculator.dart';

void main() {
  group('BalanceCalculator Pure Math Unit Tests', () {
    final now = DateTime.now();

    final testExpenses = [
      Expense(
        id: '1',
        description: 'Dinner',
        amount: 90.0, // 90 / 3 = 30 per person
        category: CategoryType.food,
        paidById: 'user_1', // user_1 paid 90
        participantIds: ['user_1', 'user_2', 'user_3'],
        timestamp: now,
      ),
      Expense(
        id: '2',
        description: 'Cab',
        amount: 40.0, // 40 / 2 = 20 per person
        category: CategoryType.travel,
        paidById: 'user_2', // user_2 paid 40
        participantIds: ['user_1', 'user_2'],
        timestamp: now,
      ),
    ];

    test('calculateTotalPaidBy correctly sums amounts paid', () {
      expect(BalanceCalculator.calculateTotalPaidBy('user_1', testExpenses), 90.0);
      expect(BalanceCalculator.calculateTotalPaidBy('user_2', testExpenses), 40.0);
      expect(BalanceCalculator.calculateTotalPaidBy('user_3', testExpenses), 0.0);
    });

    test('calculateTotalShareFor computes equal participant share', () {
      // user_1 share: 30 (Dinner) + 20 (Cab) = 50
      expect(BalanceCalculator.calculateTotalShareFor('user_1', testExpenses), 50.0);

      // user_2 share: 30 (Dinner) + 20 (Cab) = 50
      expect(BalanceCalculator.calculateTotalShareFor('user_2', testExpenses), 50.0);

      // user_3 share: 30 (Dinner) = 30
      expect(BalanceCalculator.calculateTotalShareFor('user_3', testExpenses), 30.0);
    });

    test('calculateNetBalance computes exact net owed/owing balance', () {
      // user_1: paid 90, share 50 => +40 (owed 40)
      expect(BalanceCalculator.calculateNetBalance('user_1', testExpenses), 40.0);

      // user_2: paid 40, share 50 => -10 (owes 10)
      expect(BalanceCalculator.calculateNetBalance('user_2', testExpenses), -10.0);

      // user_3: paid 0, share 30 => -30 (owes 30)
      expect(BalanceCalculator.calculateNetBalance('user_3', testExpenses), -30.0);

      // Sum of all net balances must equal 0 in closed system
      final sumNet = BalanceCalculator.calculateNetBalance('user_1', testExpenses) +
          BalanceCalculator.calculateNetBalance('user_2', testExpenses) +
          BalanceCalculator.calculateNetBalance('user_3', testExpenses);
      expect(sumNet, 0.0);
    });

    test('calculatePairwiseBalance computes net bilateral debts', () {
      // Between user_1 and user_2:
      // Expense 1 (Dinner): user_1 paid, user_2 share = 30 (user_2 owes user_1 30)
      // Expense 2 (Cab): user_2 paid, user_1 share = 20 (user_1 owes user_2 20)
      // Net pairwise: 30 - 20 = +10 (user_2 owes user_1 10)
      expect(
        BalanceCalculator.calculatePairwiseBalance('user_1', 'user_2', testExpenses),
        10.0,
      );

      // Inverse perspective: user_2 wrt user_1 => -10
      expect(
        BalanceCalculator.calculatePairwiseBalance('user_2', 'user_1', testExpenses),
        -10.0,
      );
    });

    test('isSettlement reduces debt by exact 100% dollar amount', () {
      // user_2 owes user_1 $10.00
      // user_2 pays $1.00 settlement to user_1
      final settlement = Expense(
        id: 'settle_1',
        description: 'Settle Payment',
        amount: 1.0,
        category: CategoryType.general,
        paidById: 'user_2',
        participantIds: ['user_2', 'user_1'],
        isSettlement: true,
        timestamp: now,
      );

      final updatedExpenses = [...testExpenses, settlement];

      // Net debt should reduce from $10.00 to $9.00 (not $9.50)
      expect(
        BalanceCalculator.calculatePairwiseBalance('user_1', 'user_2', updatedExpenses),
        9.0,
      );
    });
  });
}
