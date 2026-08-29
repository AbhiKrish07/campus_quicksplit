import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../providers/expense_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/expense_card.dart';
import '../widgets/empty_state_widget.dart';
import 'bill_detail_screen.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  CategoryType? _selectedCategoryFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, d MMM yyyy').format(date);
    }
  }

  Map<String, List<Expense>> _groupExpensesByDate(List<Expense> expenses) {
    final Map<String, List<Expense>> grouped = {};
    for (final exp in expenses) {
      final header = _getDateHeader(exp.timestamp);
      if (!grouped.containsKey(header)) {
        grouped[header] = [];
      }
      grouped[header]!.add(exp);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    List<Expense> allExpenses = provider.expenses;

    // Filter by category if selected
    if (_selectedCategoryFilter != null) {
      allExpenses = allExpenses
          .where((e) => e.category == _selectedCategoryFilter)
          .toList();
    }

    // Filter by search query if non-empty
    if (_searchQuery.trim().isNotEmpty) {
      allExpenses = allExpenses
          .where((e) => e.description
              .toLowerCase()
              .contains(_searchQuery.trim().toLowerCase()))
          .toList();
    }

    final groupedExpenses = _groupExpensesByDate(allExpenses);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Activity Log',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Search TextField
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search expenses by title...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),

                const SizedBox(height: 12),

                // Category Filter Chips
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('All'),
                          selected: _selectedCategoryFilter == null,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.cardBackground,
                          labelStyle: TextStyle(
                            color: _selectedCategoryFilter == null
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedCategoryFilter = null;
                            });
                          },
                        ),
                      ),
                      ...ExpenseCategory.categories.map((cat) {
                        final isSelected = _selectedCategoryFilter == cat.type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar: Icon(cat.icon,
                                size: 14,
                                color: isSelected ? Colors.white : cat.color),
                            label: Text(cat.name),
                            selected: isSelected,
                            selectedColor: cat.color,
                            backgroundColor: AppColors.cardBackground,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategoryFilter =
                                    selected ? cat.type : null;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Grouped Expenses List
          Expanded(
            child: allExpenses.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No matching expenses',
                    message:
                        'Try searching for another keyword or clearing category filters.',
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: groupedExpenses.keys.length,
                    itemBuilder: (context, sectionIndex) {
                      final dateHeader =
                          groupedExpenses.keys.elementAt(sectionIndex);
                      final sectionExpenses = groupedExpenses[dateHeader]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              dateHeader.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          ...sectionExpenses.map((expense) {
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
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
