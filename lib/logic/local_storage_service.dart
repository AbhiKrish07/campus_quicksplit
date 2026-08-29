import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/person.dart';
import '../models/group.dart';

class LocalStorageService {
  static const String _keyExpenses = 'quicksplit_expenses_v1';
  static const String _keyDarkMode = 'quicksplit_dark_mode_v1';
  static const String _keyUserPin = 'quicksplit_user_pin_v1';
  static const String _keyBankAccounts = 'quicksplit_bank_accounts_v1';
  static const String _keyFriends = 'quicksplit_friends_v1';
  static const String _keyGroups = 'quicksplit_groups_v1';
  static const String _keyIsLoggedIn = 'quicksplit_is_logged_in_v1';
  static const String _keyUserEmail = 'quicksplit_user_email_v1';
  static const String _keyAuthMethod = 'quicksplit_auth_method_v1';
  static const String _keyUserName = 'quicksplit_user_name_v1';

  /// Saves custom user profile info
  static Future<void> saveUserProfile(String name, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserName, name);
      await prefs.setString(_keyUserEmail, email);
    } catch (_) {}
  }

  /// Loads custom user profile info
  static Future<Map<String, String>?> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_keyUserName);
      final email = prefs.getString(_keyUserEmail);
      if (name == null && email == null) return null;
      return {
        'name': name ?? 'Vanessa Lobanovskiy',
        'email': email ?? 'vanessa.campus@gmail.com',
      };
    } catch (_) {
      return null;
    }
  }

  /// Saves user authentication state
  static Future<void> saveAuthState(bool isLoggedIn, String email, String method) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
      await prefs.setString(_keyUserEmail, email);
      await prefs.setString(_keyAuthMethod, method);
    } catch (_) {}
  }

  /// Loads user authentication state
  static Future<Map<String, dynamic>> loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'isLoggedIn': prefs.getBool(_keyIsLoggedIn) ?? true,
        'email': prefs.getString(_keyUserEmail) ?? 'vanessa.campus@gmail.com',
        'method': prefs.getString(_keyAuthMethod) ?? 'Google Sign-In',
      };
    } catch (_) {
      return {
        'isLoggedIn': true,
        'email': 'vanessa.campus@gmail.com',
        'method': 'Google Sign-In',
      };
    }
  }

  /// Saves list of expenses to persistent local storage
  static Future<void> saveExpenses(List<Expense> expenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = expenses.map((e) => e.toJson()).toList();
      final encodedStr = jsonEncode(jsonList);
      await prefs.setString(_keyExpenses, encodedStr);
    } catch (_) {}
  }

  /// Loads expenses from persistent local storage
  static Future<List<Expense>?> loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedStr = prefs.getString(_keyExpenses);
      if (encodedStr == null || encodedStr.isEmpty) return null;

      final decodedList = jsonDecode(encodedStr) as List;
      return decodedList
          .map((item) => Expense.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  /// Saves custom friends list
  static Future<void> saveFriends(List<Person> friends) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = friends.map((f) => f.toJson()).toList();
      await prefs.setString(_keyFriends, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Loads custom friends list
  static Future<List<Person>?> loadFriends() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyFriends);
      if (str == null || str.isEmpty) return null;
      final list = jsonDecode(str) as List;
      return list.map((item) => Person.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  /// Saves custom groups list
  static Future<void> saveGroups(List<Group> groups) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = groups.map((g) => g.toJson()).toList();
      await prefs.setString(_keyGroups, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Loads custom groups list
  static Future<List<Group>?> loadGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyGroups);
      if (str == null || str.isEmpty) return null;
      final list = jsonDecode(str) as List;
      return list.map((item) => Group.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  /// Saves system theme preference
  static Future<void> saveThemeMode(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDarkMode, isDarkMode);
    } catch (_) {}
  }

  /// Loads system theme preference
  static Future<bool?> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyDarkMode);
    } catch (_) {
      return null;
    }
  }

  /// Saves custom security UPI PIN
  static Future<void> saveUserPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserPin, pin);
    } catch (_) {}
  }

  /// Loads custom security UPI PIN (defaults to 1234)
  static Future<String> loadUserPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserPin) ?? '1234';
    } catch (_) {
      return '1234';
    }
  }

  /// Saves user bank accounts
  static Future<void> saveBankAccounts(List<String> accounts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyBankAccounts, accounts);
    } catch (_) {}
  }

  /// Loads user bank accounts
  static Future<List<String>?> loadBankAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keyBankAccounts);
    } catch (_) {
      return null;
    }
  }
}
