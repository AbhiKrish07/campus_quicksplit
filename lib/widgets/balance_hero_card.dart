import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class BalanceHeroCard extends StatelessWidget {
  final double totalOwed;
  final double totalOwe;
  final VoidCallback onRequestPressed;
  final VoidCallback onPayPressed;

  const BalanceHeroCard({
    super.key,
    required this.totalOwed,
    required this.totalOwe,
    required this.onRequestPressed,
    required this.onPayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final netBalance = totalOwed - totalOwe;
    final isNetPositive = netBalance >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'TOTAL BALANCE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isNetPositive ? '+ Owed overall' : '- You owe overall',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            currencyFormat.format(netBalance.abs()),
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // 3-Metric Sub-pills matching Image 3 Splitwise Mockup
          Row(
            children: [
              Expanded(
                child: _buildSubPill(
                  label: 'My Share',
                  amount: currencyFormat.format(totalOwed + totalOwe > 0 ? (totalOwed + totalOwe) / 2 : 0),
                  color: Colors.white.withValues(alpha: 0.9),
                  bgColor: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSubPill(
                  label: 'I Paid',
                  amount: currencyFormat.format(totalOwed),
                  color: const Color(0xFF6EE7B7), // Emerald Green
                  bgColor: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSubPill(
                  label: 'I Owed',
                  amount: currencyFormat.format(totalOwe),
                  color: const Color(0xFFFCA5A5), // Soft Red
                  bgColor: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Primary Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRequestPressed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.south_west_rounded, size: 16),
                  label: const Text(
                    'Request Money',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPayPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.north_east_rounded, size: 16),
                  label: const Text(
                    'Pay / Settle',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubPill({
    required String label,
    required String amount,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
