import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../providers/expense_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/circular_participant_view.dart';
import '../widgets/payment_gateway_modal.dart';
import 'edit_expense_screen.dart';
import 'request_cash_screen.dart';

class BillDetailScreen extends StatelessWidget {
  final String expenseId;

  const BillDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final expense = provider.expenses.firstWhere(
      (e) => e.id == expenseId,
      orElse: () => Expense(
        id: expenseId,
        description: 'Expense Detail',
        amount: 0.0,
        category: CategoryType.general,
        paidById: provider.currentUser.id,
        participantIds: [provider.currentUser.id],
        timestamp: DateTime.now(),
      ),
    );

    final category = ExpenseCategory.fromType(expense.category);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('EEEE, d MMMM yyyy • h:mm a');
    final paidByPerson = provider.getPersonById(expense.paidById);
    final participants = expense.participantIds
        .map((id) => provider.getPersonById(id))
        .toList();

    final perPersonShare = expense.perPersonShare;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Split Details',
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          // Edit Expense Button
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.primaryLight),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditExpenseScreen(expense: expense),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Split breakdown copied to clipboard!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Category Icon Badge + Total Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.surfaceBorder, width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(category.icon, color: category.color, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.description,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Paid by ${paidByPerson.name}',
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.surfaceBorder),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL BILL',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currencyFormat.format(expense.amount),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'PER PERSON SHARE',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currencyFormat.format(perPersonShare),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dateFormat.format(expense.timestamp),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Circular Orbital Participant Graphic
            CircularParticipantView(
              participants: participants,
              paidById: expense.paidById,
              perPersonShare: perPersonShare,
            ),

            const SizedBox(height: 20),

            // Participant Breakdown Header
            const Row(
              children: [
                Text(
                  'PARTICIPANT BREAKDOWN',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Breakdown List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final person = participants[index];
                final isPayer = person.id == expense.paidById;
                final share = expense.getShareForParticipant(person.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder, width: 1),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: person.color,
                        child: Text(
                          person.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  person.name,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (person.id == provider.currentUser.id)
                                  const Text(
                                    ' (You)',
                                    style: TextStyle(
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPayer
                                  ? 'Paid ${currencyFormat.format(expense.amount)}'
                                  : 'Owes ${currencyFormat.format(share)}',
                              style: TextStyle(
                                color: isPayer
                                    ? AppColors.positive
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight:
                                    isPayer ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        isPayer
                            ? '+${currencyFormat.format(expense.amount - share)}'
                            : '-${currencyFormat.format(share)}',
                        style: TextStyle(
                          color: isPayer ? AppColors.positive : AppColors.negative,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Action Settle / Request Button Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RequestCashScreen(
                            initialNote: expense.description,
                            initialAmount: perPersonShare,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_active_outlined, size: 18),
                    label: const Text('Request All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => PaymentGatewayModal(
                          payeeName: paidByPerson.name,
                          payeeId: paidByPerson.id,
                          payerId: provider.currentUser.id,
                          defaultAmount: perPersonShare,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.positive,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.payment_rounded, size: 18),
                    label: const Text('Settle Gateway'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
