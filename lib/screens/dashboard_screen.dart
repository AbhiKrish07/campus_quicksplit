import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/balance_hero_card.dart';
import '../widgets/avatar_stack.dart';
import '../widgets/expense_card.dart';
import 'bill_detail_screen.dart';
import 'friend_detail_screen.dart';
import 'settings_screen.dart';
import 'request_cash_screen.dart';
import 'main_navigation_screen.dart';
import 'group_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  void _showCreateGroupModal(BuildContext context, ExpenseProvider provider) {
    final nameController = TextEditingController();
    String selectedIcon = '🏠';
    final selectedMembers = <String>{};

    final icons = ['🏠', '🎁', '💻', '✈️', '🍕', '🎓', '⚽'];

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
                  const Text(
                    'CREATE NEW CAMPUS GROUP',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Group Expense Hub',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Group Name (e.g. Dorm Room 402)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose Icon:',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: icons.map((icon) {
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedIcon = icon;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceBorder,
                              width: 2,
                            ),
                          ),
                          child: Text(icon, style: const TextStyle(fontSize: 20)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Participating Friends:',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.friends.map((friend) {
                      final isSelected = selectedMembers.contains(friend.id);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(friend.name),
                        selectedColor: AppColors.primary,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              selectedMembers.add(friend.id);
                            } else {
                              selectedMembers.remove(friend.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (nameController.text.trim().isNotEmpty) {
                          provider.createGroup(
                            nameController.text.trim(),
                            selectedIcon,
                            selectedMembers.toList(),
                          );
                          Navigator.pop(modalContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Created group "${nameController.text.trim()}"!'),
                              backgroundColor: AppColors.positive,
                            ),
                          );
                        }
                      },
                      child: const Text('CREATE GROUP NOW',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentUser = provider.currentUser;
    final friends = provider.friends;
    final groups = provider.groups;
    final recentExpenses = provider.expenses.take(4).toList();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Greeting & Theme Toggle Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Good Morning,',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentUser.name,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.displayLarge?.color,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Logout',
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.redAccent.withValues(alpha: 0.4), width: 1),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                        ),
                        onPressed: () async {
                          await provider.logout();
                        },
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.surfaceBorder, width: 1),
                          ),
                          child: Icon(
                            themeProvider.isDarkMode
                                ? Icons.wb_sunny_rounded
                                : Icons.nightlight_round,
                            color: themeProvider.isDarkMode
                                ? Colors.amber
                                : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        onPressed: () {
                          themeProvider.toggleTheme();
                        },
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: currentUser.color,
                          child: Text(
                            currentUser.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              // Total Balance Hero Card with Pulse Animation
              BalanceHeroCard(
                totalOwed: provider.totalYouAreOwed,
                totalOwe: provider.totalYouOwe,
                onRequestPressed: () {
                  if (onNavigateTab != null) {
                    onNavigateTab!(4); // Switch to Friends Page tab
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RequestCashScreen(),
                      ),
                    );
                  }
                },
                onPayPressed: () {
                  if (onNavigateTab != null) {
                    onNavigateTab!(4); // Switch to Friends Page tab
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FriendsListScreen(),
                      ),
                    );
                  }
                },
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 28),

              // Active Groups Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ACTIVE GROUPS',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showCreateGroupModal(context, provider);
                    },
                    child: const Text(
                      '+ Create Group',
                      style: TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 100% Dynamic Groups Cards with Animations
              ...groups.asMap().entries.map((entry) {
                final index = entry.key;
                final group = entry.value;
                final groupMembers = group.participantIds
                    .map((id) => provider.getPersonById(id))
                    .toList();

                final groupTotal = provider.getGroupTotalExpenses(group.id);
                final userGroupNet = provider.getGroupUserNetBalance(group.id);

                final isUserOwed = userGroupNet > 0.009;
                final isUserOwe = userGroupNet < -0.009;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.surfaceBorder, width: 1),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupDetailScreen(groupId: group.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    group.icon ?? '📁',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    group.name,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isUserOwed
                                      ? AppColors.positiveBg
                                      : isUserOwe
                                          ? AppColors.negativeBg
                                          : AppColors.cardElevated,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isUserOwed
                                      ? 'Owed ${currencyFormat.format(userGroupNet)}'
                                      : isUserOwe
                                          ? 'You owe ${currencyFormat.format(userGroupNet.abs())}'
                                          : 'Settled',
                                  style: TextStyle(
                                    color: isUserOwed
                                        ? AppColors.positive
                                        : isUserOwe
                                            ? AppColors.negative
                                            : AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Group Total Spending',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currencyFormat.format(groupTotal),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              AvatarStack(
                                people: groupMembers,
                                maxVisible: 3,
                                size: 32,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        GroupDetailScreen(groupId: group.id),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                side: const BorderSide(
                                    color: AppColors.surfaceBorder, width: 1.5),
                              ),
                              child: const Text('View Group Details'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate()
                 .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                 .slideY(begin: 0.1, end: 0);
              }),

              const SizedBox(height: 20),

              // Recent Friends Horizontal Scroll
              const Text(
                'RECENT FRIENDS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 105,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final balance = provider.getPairwiseBalance(friend.id);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FriendDetailScreen(friendId: friend.id),
                          ),
                        );
                      },
                      child: Container(
                        width: 82,
                        margin: const EdgeInsets.only(right: 14),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: friend.color,
                                  child: Text(
                                    friend.initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (balance.abs() > 0.009)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: balance > 0
                                            ? AppColors.positive
                                            : AppColors.negative,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              friend.name.split(' ').first,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              balance > 0.009
                                  ? '+\$${balance.toStringAsFixed(0)}'
                                  : balance < -0.009
                                      ? '-\$${balance.abs().toStringAsFixed(0)}'
                                      : 'Settled',
                              style: TextStyle(
                                color: balance > 0.009
                                    ? AppColors.positive
                                    : balance < -0.009
                                        ? AppColors.negative
                                        : AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(
                            delay: (80 * index).ms,
                            duration: 350.ms)
                        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Recent Activity Feed Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECENT ACTIVITY',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (onNavigateTab != null) {
                        onNavigateTab!(1); // Switch to Activity tab
                      }
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(
                          color: AppColors.primaryLight, fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Recent Expenses List
              ...recentExpenses.asMap().entries.map((entry) {
                final index = entry.key;
                final expense = entry.value;
                final paidBy = provider.getPersonById(expense.paidById);

                return ExpenseCard(
                  expense: expense,
                  paidByPerson: paidBy,
                  currentUserId: currentUser.id,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BillDetailScreen(expenseId: expense.id),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(
                        delay: (100 * index).ms,
                        duration: 400.ms)
                    .slideY(begin: 0.1, end: 0);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
