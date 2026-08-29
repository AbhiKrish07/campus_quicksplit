import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/expense_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/payment_gateway_modal.dart';
import 'bill_detail_screen.dart';

class FriendDetailScreen extends StatelessWidget {
  final String friendId;

  const FriendDetailScreen({super.key, required this.friendId});

  void _showPaymentGatewayModal(
      BuildContext context, String friendName, String friendId, String currentUserId, double currentBalance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final payerId = currentBalance < 0 ? currentUserId : friendId;
        final payeeId = currentBalance < 0 ? friendId : currentUserId;

        return PaymentGatewayModal(
          payeeName: friendName,
          payeeId: payeeId,
          payerId: payerId,
          defaultAmount: currentBalance.abs(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final friend = provider.getPersonById(friendId);
    final pairwiseBalance = provider.getPairwiseBalance(friendId);
    final friendExpenses = provider.getExpensesForFriend(friendId);

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isYouOwe = pairwiseBalance < 0;
    final isOwedYou = pairwiseBalance > 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: friend.color,
                  child: Text(
                    friend.initials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  friend.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isYouOwe
                      ? 'You owe ${friend.name.split(' ').first} ${currencyFormat.format(pairwiseBalance.abs())}'
                      : isOwedYou
                          ? '${friend.name.split(' ').first} owes you ${currencyFormat.format(pairwiseBalance)}'
                          : 'You are all settled up!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isYouOwe
                        ? AppColors.negative
                        : isOwedYou
                            ? AppColors.positive
                            : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 20),

                // Primary Action Buttons: SETTLE / REQUEST
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showPaymentGatewayModal(
                          context,
                          friend.name,
                          friend.id,
                          provider.currentUser.id,
                          pairwiseBalance,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.positive,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.account_balance_wallet_rounded,
                            size: 18),
                        label: const Text('SETTLE VIA GATEWAY'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Payment request notification sent to ${friend.name}!',
                              ),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('REQUEST'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Grouped Transaction Feed Sheet Container
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SHARED EXPENSES',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: friendExpenses.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.receipt_long_outlined,
                            title: 'No shared expenses yet',
                            message:
                                'Log a new bill together to start splitting expenses!',
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: friendExpenses.length,
                            itemBuilder: (context, index) {
                              final expense = friendExpenses[index];
                              final paidBy =
                                  provider.getPersonById(expense.paidById);

                              return ExpenseCard(
                                expense: expense,
                                paidByPerson: paidBy,
                                currentUserId: provider.currentUser.id,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BillDetailScreen(
                                        expenseId: expense.id,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
