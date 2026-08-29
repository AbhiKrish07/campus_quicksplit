import '../models/expense.dart';

/// Pure, side-effect free mathematical functions for calculating individual
/// and pairwise split balances across all expenses.
class BalanceCalculator {
  /// Calculates total amount paid by a person across all expenses (supporting multi-payer).
  static double calculateTotalPaidBy(String personId, List<Expense> expenses) {
    double totalPaid = 0.0;
    for (final expense in expenses) {
      totalPaid += expense.getAmountPaidBy(personId);
    }
    return totalPaid;
  }

  /// Calculates total fair share owed by a person across all expenses
  /// (supporting equal remainder, exact amounts, and percentage ratios).
  static double calculateTotalShareFor(String personId, List<Expense> expenses) {
    double totalShare = 0.0;
    for (final expense in expenses) {
      totalShare += expense.getShareForParticipant(personId);
    }
    return totalShare;
  }

  /// Net balance for a person = (Total Paid) - (Total Fair Share)
  static double calculateNetBalance(String personId, List<Expense> expenses) {
    final paid = calculateTotalPaidBy(personId, expenses);
    final share = calculateTotalShareFor(personId, expenses);
    return paid - share;
  }

  /// Calculates total amount others owe to current user across expenses.
  static double calculateTotalYouAreOwed(
      String currentUserId, List<Expense> expenses) {
    double totalOwedToUser = 0.0;
    for (final expense in expenses) {
      final userPaid = expense.getAmountPaidBy(currentUserId);
      final userShare = expense.getShareForParticipant(currentUserId);
      if (userPaid > userShare) {
        totalOwedToUser += (userPaid - userShare);
      }
    }
    return totalOwedToUser;
  }

  /// Calculates total amount current user owes to others across expenses.
  static double calculateTotalYouOwe(
      String currentUserId, List<Expense> expenses) {
    double totalUserOwes = 0.0;
    for (final expense in expenses) {
      final userPaid = expense.getAmountPaidBy(currentUserId);
      final userShare = expense.getShareForParticipant(currentUserId);
      if (userShare > userPaid) {
        totalUserOwes += (userShare - userPaid);
      }
    }
    return totalUserOwes;
  }

  /// Calculates net pairwise balance between [currentUserId] and [friendId].
  /// Positive (+) means [friendId] owes [currentUserId].
  /// Negative (-) means [currentUserId] owes [friendId].
  static double calculatePairwiseBalance(
      String currentUserId, String friendId, List<Expense> expenses) {
    double friendOwesUser = 0.0;
    double userOwesFriend = 0.0;

    for (final expense in expenses) {
      if (!expense.participantIds.contains(currentUserId) &&
          !expense.participantIds.contains(friendId)) {
        continue;
      }

      final userPaid = expense.getAmountPaidBy(currentUserId);
      final userShare = expense.getShareForParticipant(currentUserId);
      final friendPaid = expense.getAmountPaidBy(friendId);
      final friendShare = expense.getShareForParticipant(friendId);

      // Bilateral share ratio
      if (userPaid > 0 && expense.participantIds.contains(friendId)) {
        friendOwesUser += friendShare;
      }
      if (friendPaid > 0 && expense.participantIds.contains(currentUserId)) {
        userOwesFriend += userShare;
      }
    }

    return friendOwesUser - userOwesFriend;
  }
}
