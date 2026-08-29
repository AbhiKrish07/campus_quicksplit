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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL NET BALANCE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isNetPositive ? AppColors.positiveBg : AppColors.negativeBg),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isNetPositive ? AppColors.positive : AppColors.negative,
                    width: 1,
                  ),
                ),
                child: Text(
                  isNetPositive ? '+ Owed overall' : '- You owe overall',
                  style: TextStyle(
                    color: isNetPositive ? AppColors.positive : AppColors.negative,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(netBalance.abs()),
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: isNetPositive ? AppColors.positive : AppColors.negative,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: AppColors.surfaceBorder.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  label: 'Owed to you',
                  amount: currencyFormat.format(totalOwed),
                  color: AppColors.positive,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.surfaceBorder,
              ),
              Expanded(
                child: _buildStatColumn(
                  label: 'You owe',
                  amount: currencyFormat.format(totalOwe),
                  color: AppColors.negative,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRequestPressed,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Request Money'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPayPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Pay / Settle'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
