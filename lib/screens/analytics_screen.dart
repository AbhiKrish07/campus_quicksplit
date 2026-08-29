import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/spend_analytics_chart.dart';
import '../widgets/empty_state_widget.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final categoryBreakdown = provider.getCategorySpendingBreakdown();
    final totalSpent =
        categoryBreakdown.values.fold(0.0, (sum, val) => sum + val);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final simplifiedDebts = provider.simplifiedDebts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Spend Analytics & Architecture',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Donut CustomPainter Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.surfaceBorder, width: 1),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CATEGORY SPEND BREAKDOWN',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Icon(Icons.pie_chart_outline_rounded,
                          color: AppColors.primaryLight, size: 18),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SpendCategoryDonutChart(categoryData: categoryBreakdown),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Simplified Debt Optimization Card (Phase 2 & 3 Graph Solver)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.alt_route_rounded,
                            color: AppColors.secondary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MINIMUM SETTLEMENT PATH',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            'goPaymentGraph (Min-Flow Engine)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (simplifiedDebts.isEmpty)
                    const Text(
                      'All campus group balances are perfectly settled! Zero transfers needed.',
                      style: TextStyle(color: AppColors.positive, fontSize: 13),
                    )
                  else
                    Column(
                      children: simplifiedDebts.map((tx) {
                        final sender = provider.getPersonById(tx.fromPersonId);
                        final receiver = provider.getPersonById(tx.toPersonId);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.surfaceBorder, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: sender.color,
                                      child: Text(
                                        sender.initials,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      sender.name.split(' ').first,
                                      style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 6),
                                      child: Icon(Icons.arrow_forward_rounded,
                                          size: 14, color: AppColors.textMuted),
                                    ),
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: receiver.color,
                                      child: Text(
                                        receiver.initials,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      receiver.name.split(' ').first,
                                      style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                currencyFormat.format(tx.amount),
                                style: const TextStyle(
                                  color: AppColors.positive,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Backend System Microservices Architecture (Matching User Diagrams 1 & 2)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.surfaceBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cloud_sync_rounded,
                          color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'BACKEND SYSTEM ARCHITECTURE',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Distributed Microservices Topology (AWS & Splitwise Go Scaling)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildArchitectureRow(
                    context,
                    title: '⚡ API Gateway & Load Balancer',
                    subtitle: 'Entry router handling JWT auth, rate limiting & CDN caching',
                    status: 'ACTIVE',
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 10),
                  _buildArchitectureRow(
                    context,
                    title: '📦 Expense Service (DB & Metadata Cache)',
                    subtitle: 'Stores expense metadata, attachments & bill itemization',
                    status: 'SYNCED',
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 10),
                  _buildArchitectureRow(
                    context,
                    title: '⚖️ Balance Service (goPaymentGraph)',
                    subtitle: 'O(N) min-flow debt algorithm graph solver per group (gid)',
                    status: 'OPTIMAL',
                    color: AppColors.positive,
                  ),
                  const SizedBox(height: 10),
                  _buildArchitectureRow(
                    context,
                    title: '🔔 Notification Service (Queue & SQS)',
                    subtitle: 'Asynchronous payment settlement & cash request alerts',
                    status: 'READY',
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Category Spending Progress Bars List
            const Text(
              'SPENDING BY CATEGORY',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            if (categoryBreakdown.isEmpty)
              const EmptyStateWidget(
                icon: Icons.pie_chart_outline_rounded,
                title: 'No category data',
                message: 'Logged expenses will automatically appear here.',
              )
            else
              ...categoryBreakdown.entries.map((entry) {
                final category = entry.key;
                final amount = entry.value;
                final percentage =
                    totalSpent > 0 ? (amount / totalSpent) : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(18),
                    border:
                        Border.all(color: AppColors.surfaceBorder, width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: category.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(category.icon,
                                    color: category.color, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                category.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            currencyFormat.format(amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: AppColors.surfaceBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(category.color),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildArchitectureRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceBorder.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: 1),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
