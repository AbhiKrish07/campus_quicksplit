import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/person.dart';
import '../providers/expense_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/payment_gateway_modal.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'add_expense_screen.dart';
import 'friend_detail_screen.dart';
import 'settings_screen.dart';
import 'request_cash_screen.dart';

import 'groups_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 2) {
      // Middle tab action
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(onNavigateTab: (index) {
        setState(() {
          _currentIndex = index;
        });
      }),
      const GroupsListScreen(),
      const SizedBox.shrink(), // Centered Floating + Button placeholder
      const AnalyticsScreen(),
      const FriendsListScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 58,
        width: 58,
        margin: const EdgeInsets.only(top: 28),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            label: 'Groups',
          ),
          const BottomNavigationBarItem(
            icon: SizedBox(height: 24),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.donut_large_rounded),
            label: 'Analytics',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Friends',
          ),
        ],
      ),
    );
  }
}

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  void _showAddFriendModal(BuildContext context, ExpenseProvider provider) {
    final nameController = TextEditingController();
    final infoController = TextEditingController();
    Color selectedColor = AppColors.primary;
    final colors = [
      AppColors.primary,
      AppColors.positive,
      AppColors.negative,
      AppColors.secondary,
      Colors.amber,
      Colors.indigoAccent,
      Colors.pinkAccent,
    ];

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
                    'ADD CAMPUS PEER / FRIEND',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add New Friend',
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
                      labelText: 'Full Name (e.g. Alex Morgan)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: infoController,
                    decoration: const InputDecoration(
                      labelText: 'Email / Phone / UPI ID (e.g. alex@upi)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Avatar Accent Color:',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: colors.map((c) {
                      final isSelected = selectedColor == c;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedColor = c;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        final initials = name
                            .split(' ')
                            .map((e) => e.isNotEmpty ? e[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase();

                        final newFriend = Person(
                          id: 'friend_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          initials: initials.isNotEmpty ? initials : 'FP',
                          color: selectedColor,
                        );

                        provider.addFriend(newFriend);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added friend "$name"!'),
                            backgroundColor: AppColors.positive,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'ADD TO FRIENDS LIST',
                        style: TextStyle(
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
    final friends = provider.friends;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Friends & Campus Peers',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primaryLight),
            tooltip: 'Add Friend',
            onPressed: () => _showAddFriendModal(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Peer Action Banner (Pay or Ask Everyone)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.cardAccentGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PEER PAY & REQUEST HUB',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAddFriendModal(context, provider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                '+ Add Friend',
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
                  const SizedBox(height: 4),
                  const Text(
                    'Settle Debt or Ask Peers for Cash',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RequestCashScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Request Money'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (friends.isNotEmpty) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => PaymentGatewayModal(
                                  payeeName: friends.first.name,
                                  payeeId: friends.first.id,
                                  payerId: provider.currentUser.id,
                                  defaultAmount: 10.0,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.positive,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Pay / Settle'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CAMPUS FRIENDS LIST',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddFriendModal(context, provider),
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text(
                    'Add Friend',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            friends.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.people_outline_rounded,
                    title: 'No friends found',
                    message: 'Add campus peers to start tracking shared expenses!',
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      final pairwiseBalance = provider.getPairwiseBalance(friend.id);
                      final isYouOwe = pairwiseBalance < 0;
                      final isOwedYou = pairwiseBalance > 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: Theme.of(context).cardTheme.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(
                              color: AppColors.surfaceBorder, width: 1),
                        ),
                        child: ExpansionTile(
                          shape: const Border(),
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: friend.color,
                            child: Text(
                              friend.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          title: Text(
                            friend.name,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            isYouOwe
                                ? 'You owe \$${pairwiseBalance.abs().toStringAsFixed(2)}'
                                : isOwedYou
                                    ? 'Owes you \$${pairwiseBalance.toStringAsFixed(2)}'
                                    : 'All settled up',
                            style: TextStyle(
                              color: isYouOwe
                                  ? AppColors.negative
                                  : isOwedYou
                                      ? AppColors.positive
                                      : AppColors.textMuted,
                              fontWeight: isYouOwe || isOwedYou
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => RequestCashScreen(
                                              initialFriendId: friend.id,
                                              initialAmount: isYouOwe
                                                  ? pairwiseBalance.abs()
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.send_rounded,
                                          size: 14),
                                      label: const Text('Request'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => PaymentGatewayModal(
                                            payeeName: friend.name,
                                            payeeId: friend.id,
                                            payerId: provider.currentUser.id,
                                            defaultAmount: pairwiseBalance.abs() > 0
                                                ? pairwiseBalance.abs()
                                                : 10.0,
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.positive,
                                        foregroundColor: Colors.black,
                                      ),
                                      icon: const Icon(
                                          Icons.account_balance_wallet_rounded,
                                          size: 14),
                                      label: const Text('Pay'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward_rounded,
                                        size: 18, color: AppColors.primaryLight),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FriendDetailScreen(
                                              friendId: friend.id),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
