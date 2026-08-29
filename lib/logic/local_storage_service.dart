import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class LocalStorageService {
  static const String _keyExpenses = 'quicksplit_expenses_v1';
  static const String _keyDarkMode = 'quicksplit_dark_mode_v1';

  /// Saves list of expenses to persistent local storage
  static Future<void> saveExpenses(List<Expense> expenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = expenses.map((e) => e.toJson()).toList();
      final encodedStr = jsonEncode(jsonList);
      await prefs.setString(_keyExpenses, encodedStr);
    } catch (e) {
      // Ignore or log storage errors
    }
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
    } catch (e) {
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
}
