import 'expense_category.dart';
import 'split_mode.dart';

class Expense {
  final String id;
  final String description;
  final double amount;
  final CategoryType category;
  final String paidById;
  final Map<String, double> payerContributions; // personId -> amount paid upfront
  final List<String> participantIds;
  final SplitMode splitMode;
  final Map<String, double> customShares; // personId -> dollar share OR percentage value
  final bool isSettlement;
  final DateTime timestamp;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.paidById,
    Map<String, double>? payerContributions,
    required this.participantIds,
    this.splitMode = SplitMode.equal,
    Map<String, double>? customShares,
    this.isSettlement = false,
    required this.timestamp,
  })  : payerContributions = payerContributions ?? {paidById: amount},
        customShares = customShares ?? {};

  /// Computes the exact dollar share for a specific participant taking into account
  /// equal remainder distribution, exact dollar amounts, percentage ratios, or direct settlements.
  double getShareForParticipant(String personId) {
    if (!participantIds.contains(personId) || participantIds.isEmpty) return 0.0;

    if (isSettlement) {
      // In a 1-to-1 settlement transfer, the payee (personId != paidById) has 100% of the share amount,
      // while the payer (paidById) has 0.0 share.
      if (personId != paidById) {
        return amount;
      }
      return 0.0;
    }

    switch (splitMode) {
      case SplitMode.equal:
        // Precise handling for leftover decimal remainders
        final baseShare = (amount / participantIds.length * 100).floorToDouble() / 100;
        final totalBase = baseShare * participantIds.length;
        final remainderInCents = ((amount - totalBase) * 100).round();

        // Payer / first participant gets remainder cents to ensure sum(shares) == amount
        final firstParticipantId = participantIds.contains(paidById)
            ? paidById
            : participantIds.first;

        if (personId == firstParticipantId) {
          return baseShare + (remainderInCents / 100.0);
        }
        return baseShare;

      case SplitMode.exactAmount:
        return customShares[personId] ?? 0.0;

      case SplitMode.percentage:
        final pct = customShares[personId] ?? 0.0;
        return (amount * pct) / 100.0;
    }
  }

  /// Total amount paid upfront by a specific person for this bill
  double getAmountPaidBy(String personId) {
    if (payerContributions.containsKey(personId)) {
      return payerContributions[personId]!;
    }
    return paidById == personId ? amount : 0.0;
  }

  /// Default per-person equal share helper
  double get perPersonShare =>
      participantIds.isEmpty ? 0.0 : amount / participantIds.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category.name,
      'paidById': paidById,
      'payerContributions': payerContributions,
      'participantIds': participantIds,
      'splitMode': splitMode.name,
      'customShares': customShares,
      'isSettlement': isSettlement,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    final catName = json['category'] as String;
    final catType = CategoryType.values.firstWhere(
      (c) => c.name == catName,
      orElse: () => CategoryType.general,
    );

    final modeName = json['splitMode'] as String? ?? 'equal';
    final mode = SplitMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => SplitMode.equal,
    );

    Map<String, double> parseMap(dynamic mapData) {
      if (mapData is Map) {
        return mapData.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
      }
      return {};
    }

    final expId = json['id'] as String? ?? '';
    final expDesc = json['description'] as String? ?? '';
    final descLower = expDesc.toLowerCase();
    final isSettle = (json['isSettlement'] as bool? ?? false) ||
        expId.startsWith('settle_') ||
        descLower.contains('settle') ||
        descLower.contains('pay') ||
        descLower.contains('transfer');

    return Expense(
      id: expId,
      description: expDesc,
      amount: (json['amount'] as num).toDouble(),
      category: catType,
      paidById: json['paidById'] as String,
      payerContributions: parseMap(json['payerContributions']),
      participantIds: List<String>.from(json['participantIds'] as List),
      splitMode: mode,
      customShares: parseMap(json['customShares']),
      isSettlement: isSettle,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
