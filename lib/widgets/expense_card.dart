import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/person.dart';
import '../providers/expense_provider.dart';
import '../theme/app_colors.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final Person paidByPerson;
  final String currentUserId;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.paidByPerson,
    required this.currentUserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = ExpenseCategory.fromType(expense.category);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('d MMM • h:mm a');

    final isPayer = expense.paidById == currentUserId;
    final isParticipant = expense.participantIds.contains(currentUserId);
    final userShare = expense.getShareForParticipant(currentUserId);
    final userPaid = expense.getAmountPaidBy(currentUserId);

    final descLower = expense.description.toLowerCase();
    final bool isSettlementExp = expense.isSettlement ||
        expense.id.startsWith('settle_') ||
        descLower.contains('settle') ||
        descLower.contains('pay') ||
        descLower.contains('transfer');

    // Exact Splitwise Net Balance Logic
    final double netAmount = userPaid - userShare;
    String statusTitle = '';
    String netLabel = '';
    Color amountColor = AppColors.textSecondary;

    if (isSettlementExp) {
      if (isPayer) {
        statusTitle = 'You paid ${currencyFormat.format(expense.amount)}';
        netLabel = 'payment sent';
        amountColor = AppColors.positive;
      } else {
        statusTitle = '${paidByPerson.name.split(' ').first} paid ${currencyFormat.format(expense.amount)}';
        netLabel = 'payment received';
        amountColor = AppColors.positive;
      }
    } else if (isPayer) {
      statusTitle = 'You paid ${currencyFormat.format(expense.amount)}';
      if (netAmount > 0.009) {
        netLabel = 'you lent';
        amountColor = AppColors.positive;
      } else {
        netLabel = 'no balance change';
        amountColor = AppColors.textMuted;
      }
    } else if (isParticipant) {
      statusTitle = '${paidByPerson.name.split(' ').first} paid ${currencyFormat.format(expense.amount)}';
      if (netAmount < -0.009) {
        netLabel = 'you owe ${paidByPerson.name.split(' ').first}';
        amountColor = AppColors.negative;
      } else {
        netLabel = 'no balance change';
        amountColor = AppColors.textMuted;
      }
    } else {
      statusTitle = '${paidByPerson.name.split(' ').first} paid ${currencyFormat.format(expense.amount)}';
      netLabel = 'not involved';
      amountColor = AppColors.textMuted;
    }

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.negative,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'DELETE',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      onDismissed: (_) {
        final provider = Provider.of<ExpenseProvider>(context, listen: false);
        provider.deleteExpense(expense.id);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${expense.description}"'),
            backgroundColor: AppColors.cardElevated,
            action: SnackBarAction(
              label: 'UNDO',
              textColor: AppColors.primaryLight,
              onPressed: () {
                provider.undoDeleteExpense();
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.surfaceBorder, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Category Icon Badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: category.color.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      isSettlementExp ? Icons.payment_rounded : category.icon,
                      color: isSettlementExp ? AppColors.positive : category.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Middle Details Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.description,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusTitle,
                          style: TextStyle(
                            color: isPayer
                                ? AppColors.primaryLight
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSettlementExp
                              ? '${dateFormat.format(expense.timestamp)} • Direct Payment'
                              : '${dateFormat.format(expense.timestamp)} • ${expense.participantIds.length} split (${expense.splitMode.name})',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Right Side Splitwise Net Amount Badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        netLabel,
                        style: TextStyle(
                          color: isSettlementExp
                              ? (isPayer ? AppColors.positive : AppColors.positive)
                              : amountColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isSettlementExp
                            ? (isPayer
                                ? '-${currencyFormat.format(expense.amount)}'
                                : '+${currencyFormat.format(expense.amount)}')
                            : netAmount > 0.009
                                ? '+${currencyFormat.format(netAmount)}'
                                : netAmount < -0.009
                                    ? '-${currencyFormat.format(netAmount.abs())}'
                                    : currencyFormat.format(0),
                        style: TextStyle(
                          color: isSettlementExp
                              ? (isPayer ? AppColors.positive : AppColors.positive)
                              : amountColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
