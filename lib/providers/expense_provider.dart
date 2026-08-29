import 'package:flutter/material.dart';
import '../models/person.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/group.dart';
import '../models/split_mode.dart';
import '../logic/balance_calculator.dart';
import '../logic/debt_simplifier.dart';
import '../logic/local_storage_service.dart';

class ExpenseProvider extends ChangeNotifier {
  // Current logged in user (Vanessa)
  final Person _currentUser = const Person(
    id: 'user_me',
    name: 'Vanessa Lobanovskiy',
    initials: 'VL',
    color: Color(0xFF7C4DFF),
  );

  // Mock campus friends list
  late final List<Person> _friends = [
    const Person(
      id: 'friend_1',
      name: 'Billie Eilish',
      initials: 'BE',
      color: Color(0xFFC0CA33),
    ),
    const Person(
      id: 'friend_2',
      name: 'Taylor Swift',
      initials: 'TS',
      color: Color(0xFFFFB300),
    ),
    const Person(
      id: 'friend_3',
      name: 'Alex Rivera',
      initials: 'AR',
      color: Color(0xFF00ACC1),
    ),
    const Person(
      id: 'friend_4',
      name: 'Marcus Chen',
      initials: 'MC',
      color: Color(0xFF43A047),
    ),
    const Person(
      id: 'friend_5',
      name: 'Sophia Martinez',
      initials: 'SM',
      color: Color(0xFFE91E63),
    ),
  ];

  // Initial mock groups
  late final List<Group> _groups = [
    const Group(
      id: 'group_1',
      name: 'The Convoy House',
      participantIds: ['user_me', 'friend_1', 'friend_3', 'friend_4', 'friend_5'],
      icon: '🏠',
    ),
    const Group(
      id: 'group_2',
      name: "Mom's Birthday Gift",
      participantIds: ['user_me', 'friend_1', 'friend_2', 'friend_3'],
      icon: '🎁',
    ),
    const Group(
      id: 'group_3',
      name: 'Weekend Hackathon',
      participantIds: ['user_me', 'friend_3', 'friend_4'],
      icon: '💻',
    ),
  ];

  // Expenses store
  final List<Expense> _expenses = [];

  // Temporary storage for Undo deletion
  Expense? _recentlyDeletedExpense;
  int? _recentlyDeletedIndex;

  ExpenseProvider() {
    _loadLocalStateOrInit();
  }

  Future<void> _loadLocalStateOrInit() async {
    final stored = await LocalStorageService.loadExpenses();
    if (stored != null && stored.isNotEmpty) {
      _expenses.clear();
      _expenses.addAll(stored);
    } else {
      _initInitialMockData();
      await LocalStorageService.saveExpenses(_expenses);
    }
    notifyListeners();
  }

  void _initInitialMockData() {
    final now = DateTime.now();
    _expenses.addAll([
      Expense(
        id: 'exp_1',
        description: 'Starbucks Coffee & Bagels',
        amount: 25.30,
        category: CategoryType.coffee,
        paidById: 'user_me',
        participantIds: ['user_me', 'friend_1'],
        timestamp: now.subtract(const Duration(minutes: 45)),
      ),
      Expense(
        id: 'exp_2',
        description: 'Dribbble Pro Team Subscription',
        amount: 180.00,
        category: CategoryType.subscription,
        paidById: 'friend_1',
        participantIds: ['user_me', 'friend_1', 'friend_3'],
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      Expense(
        id: 'exp_3',
        description: 'Spotify Family Plan',
        amount: 29.00,
        category: CategoryType.subscription,
        paidById: 'friend_1',
        participantIds: ['user_me', 'friend_1'],
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      Expense(
        id: 'exp_4',
        description: 'Burger King Convoy Night',
        amount: 120.00,
        category: CategoryType.food,
        paidById: 'user_me',
        participantIds: ['user_me', 'friend_1', 'friend_3', 'friend_4', 'friend_5'],
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      Expense(
        id: 'exp_5',
        description: 'Uber to Campus Event',
        amount: 45.50,
        category: CategoryType.travel,
        paidById: 'friend_3',
        participantIds: ['user_me', 'friend_3'],
        timestamp: now.subtract(const Duration(days: 1, hours: 6)),
      ),
      Expense(
        id: 'exp_6',
        description: 'Apartment Wi-Fi & Electric',
        amount: 150.00,
        category: CategoryType.utilities,
        paidById: 'user_me',
        participantIds: ['user_me', 'friend_1', 'friend_4'],
        timestamp: now.subtract(const Duration(days: 2)),
      ),
    ]);
  }

  // Getters
  Person get currentUser => _currentUser;
  List<Person> get friends => List.unmodifiable(_friends);
  List<Person> get allPeople => List.unmodifiable([_currentUser, ..._friends]);
  List<Group> get groups => List.unmodifiable(_groups);
  List<Expense> get expenses => List.unmodifiable(
        [..._expenses]..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
      );

  // Computed Financial Totals
  double get totalYouAreOwed =>
      BalanceCalculator.calculateTotalYouAreOwed(_currentUser.id, _expenses);

  double get totalYouOwe =>
      BalanceCalculator.calculateTotalYouOwe(_currentUser.id, _expenses);

  double get netTotalBalance => totalYouAreOwed - totalYouOwe;

  double getPairwiseBalance(String friendId) =>
      BalanceCalculator.calculatePairwiseBalance(
          _currentUser.id, friendId, _expenses);

  /// Debt Simplification Algorithm Output
  List<SimplifiedTransaction> get simplifiedDebts =>
      DebtSimplifier.simplifyDebts(allPeople, _expenses);

  Person getPersonById(String id) {
    if (id == _currentUser.id) return _currentUser;
    return _friends.firstWhere(
      (f) => f.id == id,
      orElse: () => Person(
        id: id,
        name: 'Unknown',
        initials: '?',
        color: Colors.grey,
      ),
    );
  }

  List<Expense> getExpensesForFriend(String friendId) {
    return _expenses
        .where((e) =>
            e.participantIds.contains(friendId) &&
            e.participantIds.contains(_currentUser.id))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<Expense> getExpensesForGroup(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    return _expenses
        .where((e) => e.participantIds
            .any((pId) => group.participantIds.contains(pId)))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Analytics Category Breakdown
  Map<ExpenseCategory, double> getCategorySpendingBreakdown() {
    final Map<ExpenseCategory, double> breakdown = {};
    for (final exp in _expenses) {
      final cat = ExpenseCategory.fromType(exp.category);
      breakdown[cat] = (breakdown[cat] ?? 0.0) + exp.amount;
    }
    return breakdown;
  }

  // Mutation Actions with Local Persistence
  void addExpense(Expense expense) {
    _expenses.add(expense);
    LocalStorageService.saveExpenses(_expenses);
    notifyListeners();
  }

  void deleteExpense(String expenseId) {
    final index = _expenses.indexWhere((e) => e.id == expenseId);
    if (index != -1) {
      _recentlyDeletedExpense = _expenses[index];
      _recentlyDeletedIndex = index;
      _expenses.removeAt(index);
      LocalStorageService.saveExpenses(_expenses);
      notifyListeners();
    }
  }

  void undoDeleteExpense() {
    if (_recentlyDeletedExpense != null && _recentlyDeletedIndex != null) {
      _expenses.insert(_recentlyDeletedIndex!, _recentlyDeletedExpense!);
      _recentlyDeletedExpense = null;
      _recentlyDeletedIndex = null;
      LocalStorageService.saveExpenses(_expenses);
      notifyListeners();
    }
  }

  void settleUpBetween(String personAId, String personBId, double amount) {
    if (amount <= 0) return;

    final settlementExpense = Expense(
      id: 'settle_${DateTime.now().millisecondsSinceEpoch}',
      description: 'Settle Payment',
      amount: amount,
      category: CategoryType.general,
      paidById: personAId,
      participantIds: [personAId, personBId],
      splitMode: SplitMode.equal,
      timestamp: DateTime.now(),
    );

    _expenses.add(settlementExpense);
    LocalStorageService.saveExpenses(_expenses);
    notifyListeners();
  }
}
