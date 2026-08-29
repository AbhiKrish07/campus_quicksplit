import '../models/expense.dart';
import '../models/person.dart';

class SimplifiedTransaction {
  final String fromPersonId;
  final String toPersonId;
  final double amount;

  const SimplifiedTransaction({
    required this.fromPersonId,
    required this.toPersonId,
    required this.amount,
  });
}

/// Algorithmic min-flow solver that simplifies complex multi-person debt webs
/// into the minimal number of direct peer repayment transactions.
class DebtSimplifier {
  static List<SimplifiedTransaction> simplifyDebts(
      List<Person> people, List<Expense> expenses) {
    // 1. Calculate Net Balances for each person
    final Map<String, double> netBalances = {};
    for (final person in people) {
      netBalances[person.id] = 0.0;
    }

    for (final expense in expenses) {
      for (final person in people) {
        final paid = expense.getAmountPaidBy(person.id);
        final share = expense.getShareForParticipant(person.id);
        netBalances[person.id] = (netBalances[person.id] ?? 0.0) + (paid - share);
      }
    }

    // 2. Separate into Debtors and Creditors
    final List<MapEntry<String, double>> debtors = [];
    final List<MapEntry<String, double>> creditors = [];

    netBalances.forEach((personId, net) {
      if (net < -0.009) {
        debtors.add(MapEntry(personId, -net)); // positive debt amount
      } else if (net > 0.009) {
        creditors.add(MapEntry(personId, net));
      }
    });

    // Sort descending by magnitude for optimal greedy matching
    debtors.sort((a, b) => b.value.compareTo(a.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    final List<SimplifiedTransaction> transactions = [];
    int dIndex = 0;
    int cIndex = 0;

    // 3. Greedily match maximum debtor with maximum creditor
    while (dIndex < debtors.length && cIndex < creditors.length) {
      final debtor = debtors[dIndex];
      final creditor = creditors[cIndex];

      final double settleAmount =
          debtor.value < creditor.value ? debtor.value : creditor.value;

      if (settleAmount > 0.009) {
        transactions.add(
          SimplifiedTransaction(
            fromPersonId: debtor.key,
            toPersonId: creditor.key,
            amount: (settleAmount * 100).roundToDouble() / 100,
          ),
        );
      }

      debtors[dIndex] = MapEntry(debtor.key, debtor.value - settleAmount);
      creditors[cIndex] = MapEntry(creditor.key, creditor.value - settleAmount);

      if (debtors[dIndex].value <= 0.009) dIndex++;
      if (creditors[cIndex].value <= 0.009) cIndex++;
    }

    return transactions;
  }
}
