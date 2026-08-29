import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_state_widget.dart';
import 'dashboard_screen.dart';
import 'activity_log_screen.dart';
import 'analytics_screen.dart';
import 'add_expense_screen.dart';
import 'friend_detail_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 2) {
      // Middle tab is "+ New Expense"
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
      const ActivityLogScreen(),
      const SizedBox.shrink(), // Placeholder for + New tab button
      const AnalyticsScreen(),
      const FriendsListScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: pages,
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
            icon: Icon(Icons.show_chart_rounded),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            ),
            label: 'New',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.donut_large_rounded),
            label: 'Analytics',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.group_rounded),
            label: 'Friends',
          ),
        ],
      ),
    );
  }
}

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final friends = provider.friends;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Friends & Campus Groups',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: friends.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.people_outline_rounded,
              title: 'No friends found',
              message: 'Add campus peers to start tracking shared expenses!',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                final pairwiseBalance = provider.getPairwiseBalance(friend.id);
                final isYouOwe = pairwiseBalance < 0;
                final isOwedYou = pairwiseBalance > 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppColors.surfaceBorder, width: 1),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 24,
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
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FriendDetailScreen(friendId: friend.id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
