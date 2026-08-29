import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/group.dart';
import '../providers/expense_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/expense_card.dart';
import '../widgets/empty_state_widget.dart';
import 'add_expense_screen.dart';
import 'bill_detail_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  bool _simplifyDebtsEnabled = true;

  void _showAddMembersModal(
      BuildContext context, ExpenseProvider provider, Group group) {
    final selectedNewMemberIds = <String>{};
    final availableFriends = provider.friends
        .where((f) => !group.participantIds.contains(f.id))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'ADD MEMBERS TO ${group.name.toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add Friends to Group',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  availableFriends.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'All your campus friends are already members of this group!',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 13),
                          ),
                        )
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: availableFriends.map((friend) {
                            final isSelected =
                                selectedNewMemberIds.contains(friend.id);
                            return FilterChip(
                              selected: isSelected,
                              avatar: CircleAvatar(
                                backgroundColor: friend.color,
                                child: Text(friend.initials,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                              label: Text(friend.name),
                              selectedColor: AppColors.primary,
                              onSelected: (selected) {
                                setModalState(() {
                                  if (selected) {
                                    selectedNewMemberIds.add(friend.id);
                                  } else {
                                    selectedNewMemberIds.remove(friend.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedNewMemberIds.isEmpty
                          ? null
                          : () {
                              provider.addGroupMembers(
                                  group.id, selectedNewMemberIds.toList());
                              Navigator.pop(modalContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Added ${selectedNewMemberIds.length} new member(s) to ${group.name}!'),
                                  backgroundColor: AppColors.positive,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'ADD ${selectedNewMemberIds.length} MEMBER(S)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final group = provider.groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => Group(
        id: widget.groupId,
        name: 'Campus Group',
        participantIds: ['user_me'],
        icon: '👥',
      ),
    );

    final groupExpenses = provider.getGroupExpenses(group.id);
    final totalGroupSpend = provider.getGroupTotalExpenses(group.id);
    final userNetBalance = provider.getGroupUserNetBalance(group.id);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

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
          group.name,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded,
                color: AppColors.primaryLight),
            tooltip: 'Add Members',
            onPressed: () => _showAddMembersModal(context, provider, group),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primaryLight),
            tooltip: 'Add Group Expense',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Hero Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              group.icon ?? '👥',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${group.participantIds.length} Members',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _showAddMembersModal(context, provider, group),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.person_add_rounded,
                                  size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                '+ Add Member',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL GROUP EXPENSE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(totalGroupSpend),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'YOUR GROUP BALANCE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userNetBalance >= 0
                                ? '+${currencyFormat.format(userNetBalance)}'
                                : '-${currencyFormat.format(userNetBalance.abs())}',
                            style: TextStyle(
                              color: userNetBalance >= 0
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFFFCA5A5),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Simplify Debts Switcher
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.alt_route_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Simplify Group Debts',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: _simplifyDebtsEnabled,
                          activeThumbColor: AppColors.positive,
                          onChanged: (val) {
                            setState(() {
                              _simplifyDebtsEnabled = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Group Members Header & Add Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GROUP PARTICIPANTS',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddMembersModal(context, provider, group),
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text(
                    '+ Add Members',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: group.participantIds.length + 1,
                itemBuilder: (context, idx) {
                  if (idx == group.participantIds.length) {
                    // Add Member Card Button
                    return GestureDetector(
                      onTap: () => _showAddMembersModal(context, provider, group),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primary, width: 1.5),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add_circle_outline_rounded,
                                color: AppColors.primaryLight, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Add Member',
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final pId = group.participantIds[idx];
                  final person = provider.getPersonById(pId);

                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.surfaceBorder, width: 1),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: person.color,
                          child: Text(
                            person.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          person.id == provider.currentUser.id
                              ? 'You'
                              : person.name.split(' ').first,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Group Expenses Feed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GROUP TRANSACTIONS',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddExpenseScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text(
                    'Add Expense',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            groupExpenses.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.receipt_long_rounded,
                    title: 'No group expenses yet',
                    message:
                        'Add an expense to start splitting bills with this group!',
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groupExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = groupExpenses[index];
                      final payer = provider.getPersonById(expense.paidById);

                      return ExpenseCard(
                        expense: expense,
                        paidByPerson: payer,
                        currentUserId: provider.currentUser.id,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BillDetailScreen(expenseId: expense.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
