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
  Person _currentUser = const Person(
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
  final List<Group> _groups = [
    const Group(
      id: 'group_1',
      name: 'The Convoy House',
      participantIds: ['user_me', 'friend_1', 'friend_3', 'friend_4', 'friend_5'],
      icon: '🏠',
    ),
    const Group(
      id: 'group_2',
      name: "Mom's Birthday Gift",
      participantIds: ['user_me', 'friend_2', 'friend_4'],
      icon: '🎁',
    ),
    const Group(
      id: 'group_3',
      name: 'CS301 Hackathon Team',
      participantIds: ['user_me', 'friend_1', 'friend_2', 'friend_3'],
      icon: '💻',
    ),
  ];

  // User PIN & Bank Accounts
  String _userPin = '1234';
  List<String> _bankAccounts = [
    'State Bank of India •••• 4821',
    'HDFC Bank •••• 9102',
    'Chase Premier •••• 5519',
  ];

  List<Expense> _expenses = [];

  Expense? _recentlyDeletedExpense;
  int? _recentlyDeletedIndex;

  ExpenseProvider() {
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final loadedExpenses = await LocalStorageService.loadExpenses();
    if (loadedExpenses != null && loadedExpenses.isNotEmpty) {
      _expenses = loadedExpenses;
    } else {
      _initInitialMockData();
    }

    final loadedFriends = await LocalStorageService.loadFriends();
    if (loadedFriends != null && loadedFriends.isNotEmpty) {
      _friends.clear();
      _friends.addAll(loadedFriends);
    }

    final loadedGroups = await LocalStorageService.loadGroups();
    if (loadedGroups != null && loadedGroups.isNotEmpty) {
      _groups.clear();
      _groups.addAll(loadedGroups);
    }

    _userPin = await LocalStorageService.loadUserPin();
    final savedBanks = await LocalStorageService.loadBankAccounts();
    if (savedBanks != null && savedBanks.isNotEmpty) {
      _bankAccounts = savedBanks;
    }

    final authMap = await LocalStorageService.loadAuthState();
    _isLoggedIn = authMap['isLoggedIn'] as bool? ?? true;
    _userEmail = authMap['email'] as String? ?? 'vanessa.campus@gmail.com';
    _authMethod = authMap['method'] as String? ?? 'Google Sign-In';

    final userProfile = await LocalStorageService.loadUserProfile();
    if (userProfile != null) {
      final name = userProfile['name']!;
      final initials = name
          .split(' ')
          .map((e) => e.isNotEmpty ? e[0] : '')
          .take(2)
          .join()
          .toUpperCase();
      _currentUser = Person(
        id: 'user_me',
        name: name,
        initials: initials.isNotEmpty ? initials : 'ME',
        color: _currentUser.color,
      );
      _userEmail = userProfile['email']!;
    }

    notifyListeners();
  }

  bool _isLoggedIn = true;
  String _userEmail = 'vanessa.campus@gmail.com';
  String _authMethod = 'Google Sign-In';

  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  String get authMethod => _authMethod;

  Future<void> updateUserProfile(String newName, String newEmail) async {
    final initials = newName
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    _currentUser = Person(
      id: 'user_me',
      name: newName,
      initials: initials.isNotEmpty ? initials : 'ME',
      color: _currentUser.color,
    );
    _userEmail = newEmail;

    await LocalStorageService.saveUserProfile(newName, newEmail);
    await LocalStorageService.saveAuthState(_isLoggedIn, _userEmail, _authMethod);
    notifyListeners();
  }

  Future<void> updateFriendName(String friendId, String newName) async {
    final index = _friends.indexWhere((f) => f.id == friendId);
    if (index != -1) {
      final old = _friends[index];
      final initials = newName
          .split(' ')
          .map((e) => e.isNotEmpty ? e[0] : '')
          .take(2)
          .join()
          .toUpperCase();

      _friends[index] = Person(
        id: old.id,
        name: newName,
        initials: initials.isNotEmpty ? initials : old.initials,
        color: old.color,
      );

      await LocalStorageService.saveFriends(_friends);
      notifyListeners();
    }
  }

  void resetInitialData() {
    _expenses.clear();
    _initInitialMockData();
    LocalStorageService.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> addGroupMembers(String groupId, List<String> newMemberIds) async {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final old = _groups[index];
      final updatedParticipants = Set<String>.from(old.participantIds)..addAll(newMemberIds);

      _groups[index] = Group(
        id: old.id,
        name: old.name,
        participantIds: updatedParticipants.toList(),
        icon: old.icon,
      );

      await LocalStorageService.saveGroups(_groups);
      notifyListeners();
    }
  }

  Future<void> updateGroupName(String groupId, String newName) async {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final old = _groups[index];
      _groups[index] = Group(
        id: old.id,
        name: newName,
        participantIds: old.participantIds,
        icon: old.icon,
      );

      await LocalStorageService.saveGroups(_groups);
      notifyListeners();
    }
  }

  Future<void> loginWithGoogleAccount(String name, String email) async {
    _isLoggedIn = true;
    _userEmail = email;
    _authMethod = 'Google Sign-In';

    final initials = name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    _currentUser = Person(
      id: 'user_me',
      name: name,
      initials: initials.isNotEmpty ? initials : 'GO',
      color: _currentUser.color,
    );

    await LocalStorageService.saveUserProfile(name, email);
    await LocalStorageService.saveAuthState(true, email, _authMethod);
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    await loginWithGoogleAccount('Vanessa Lobanovskiy', 'vanessa.google@campus.edu');
  }

  Future<void> loginWithEmail(String email, String password) async {
    _isLoggedIn = true;
    _userEmail = email.isNotEmpty ? email : 'vanessa.campus@gmail.com';
    _authMethod = 'Email & Password';
    await LocalStorageService.saveAuthState(true, _userEmail, _authMethod);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await LocalStorageService.saveAuthState(false, '', '');
    notifyListeners();
  }

  void addFriend(Person newFriend) {
    if (_friends.any((f) => f.id == newFriend.id)) return;
    _friends.add(newFriend);
    LocalStorageService.saveFriends(_friends);
    notifyListeners();
  }

  void _initInitialMockData() {
    _expenses = [
      Expense(
        id: 'exp_1',
        description: 'Burger King Feast',
        amount: 120.00,
        category: CategoryType.food,
        paidById: 'friend_1',
        participantIds: ['user_me', 'friend_1', 'friend_3', 'friend_4', 'friend_5'],
        splitMode: SplitMode.equal,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Expense(
        id: 'exp_2',
        description: 'Game Center & Arcade',
        amount: 300.00,
        category: CategoryType.subscription,
        paidById: 'user_me',
        participantIds: ['user_me', 'friend_2', 'friend_4'],
        splitMode: SplitMode.equal,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Expense(
        id: 'exp_3',
        description: 'Fashion King Apparels',
        amount: 160.00,
        category: CategoryType.shopping,
        paidById: 'friend_2',
        participantIds: ['user_me', 'friend_2'],
        splitMode: SplitMode.equal,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Expense(
        id: 'exp_4',
        description: 'PVR Cinema Tickets',
        amount: 140.00,
        category: CategoryType.food,
        paidById: 'user_me',
        participantIds: ['user_me', 'friend_1', 'friend_3'],
        splitMode: SplitMode.equal,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  // GETTERS
  Person get currentUser => _currentUser;
  List<Person> get friends => List.unmodifiable(_friends);
  List<Person> get allPeople => [_currentUser, ..._friends];
  List<Group> get groups => List.unmodifiable(_groups);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  String get userPin => _userPin;
  List<String> get bankAccounts => List.unmodifiable(_bankAccounts);

  Person getPersonById(String id) {
    if (id == _currentUser.id) return _currentUser;
    return _friends.firstWhere(
      (f) => f.id == id,
      orElse: () => Person(
        id: id,
        name: 'Campus Peer',
        initials: 'CP',
        color: const Color(0xFF7C4DFF),
      ),
    );
  }

  double get totalYouAreOwed =>
      BalanceCalculator.calculateTotalYouAreOwed(_currentUser.id, _expenses);

  double get totalYouOwe =>
      BalanceCalculator.calculateTotalYouOwe(_currentUser.id, _expenses);

  double get totalNetBalance =>
      BalanceCalculator.calculateNetBalance(_currentUser.id, _expenses);

  double getPairwiseBalance(String friendId) =>
      BalanceCalculator.calculatePairwiseBalance(
          _currentUser.id, friendId, _expenses);

  List<SimplifiedTransaction> get simplifiedSettlements =>
      DebtSimplifier.simplifyDebts(allPeople, _expenses);

  List<SimplifiedTransaction> get simplifiedDebts =>
      DebtSimplifier.simplifyDebts(allPeople, _expenses);

  List<Expense> getExpensesForGroup(String groupId) => getGroupExpenses(groupId);

  List<Expense> getExpensesForFriend(String friendId) {
    return _expenses.where((e) {
      return e.participantIds.contains(friendId) &&
          (e.participantIds.contains(_currentUser.id) || e.paidById == friendId);
    }).toList();
  }

  Map<ExpenseCategory, double> getCategorySpendingBreakdown() {
    final map = <ExpenseCategory, double>{};
    for (final e in _expenses) {
      final cat = ExpenseCategory.fromType(e.category);
      map[cat] = (map[cat] ?? 0.0) + e.amount;
    }
    return map;
  }

  List<Expense> getGroupExpenses(String groupId) {
    final group = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => _groups.first,
    );
    return _expenses.where((e) {
      return e.participantIds
          .any((pId) => group.participantIds.contains(pId));
    }).toList();
  }

  double getGroupTotalExpenses(String groupId) {
    return getGroupExpenses(groupId).fold(0.0, (sum, e) => sum + e.amount);
  }

  double getGroupUserNetBalance(String groupId) {
    final groupExpenses = getGroupExpenses(groupId);
    return BalanceCalculator.calculateNetBalance(_currentUser.id, groupExpenses);
  }

  // SETTERS & MUTATIONS
  void setUserPin(String newPin) {
    if (newPin.length == 4) {
      _userPin = newPin;
      LocalStorageService.saveUserPin(newPin);
      notifyListeners();
    }
  }

  void addBankAccount(String bankName) {
    if (bankName.trim().isNotEmpty && !_bankAccounts.contains(bankName)) {
      _bankAccounts.add(bankName.trim());
      LocalStorageService.saveBankAccounts(_bankAccounts);
      notifyListeners();
    }
  }

  void removeBankAccount(String bankName) {
    _bankAccounts.remove(bankName);
    LocalStorageService.saveBankAccounts(_bankAccounts);
    notifyListeners();
  }

  void createGroup(String name, String icon, List<String> memberIds) {
    if (name.trim().isEmpty) return;
    final newGroup = Group(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      participantIds: ['user_me', ...memberIds],
      icon: icon.isNotEmpty ? icon : '👥',
    );
    _groups.add(newGroup);
    LocalStorageService.saveGroups(_groups);
    notifyListeners();
  }

  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
    LocalStorageService.saveExpenses(_expenses);
    notifyListeners();
  }

  void updateExpense(Expense updatedExpense) {
    final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      LocalStorageService.saveExpenses(_expenses);
      notifyListeners();
    }
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
      isSettlement: true,
      timestamp: DateTime.now(),
    );

    _expenses.insert(0, settlementExpense);
    LocalStorageService.saveExpenses(_expenses);
    notifyListeners();
  }

  void resetToInitialData() {
    _expenses.clear();
    _initInitialMockData();
    LocalStorageService.saveExpenses(_expenses);
    notifyListeners();
  }
}
