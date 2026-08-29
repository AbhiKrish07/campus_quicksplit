import 'dart:math';
import 'package:flutter/material.dart';
import '../models/expense_category.dart';
import '../theme/app_colors.dart';

class SpendCategoryDonutChart extends StatelessWidget {
  final Map<ExpenseCategory, double> categoryData;

  const SpendCategoryDonutChart({super.key, required this.categoryData});

  @override
  Widget build(BuildContext context) {
    final double totalAmount =
        categoryData.values.fold(0.0, (sum, val) => sum + val);

    if (totalAmount <= 0) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No expense data to analyze',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: CustomPaint(
        painter: _DonutChartPainter(categoryData: categoryData, total: totalAmount),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'TOTAL SPENT',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final Map<ExpenseCategory, double> categoryData;
  final double total;

  _DonutChartPainter({required this.categoryData, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 12;
    const strokeWidth = 24.0;

    final rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -pi / 2;

    for (final entry in categoryData.entries) {
      final sweepAngle = (entry.value / total) * 2 * pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = entry.key.color;

      canvas.drawArc(rect, startAngle + 0.05, sweepAngle - 0.08, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
