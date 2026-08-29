import 'package:flutter/material.dart';

enum SplitMode {
  equal,
  exactAmount,
  percentage,
}

extension SplitModeExtension on SplitMode {
  String get displayName {
    switch (this) {
      case SplitMode.equal:
        return 'Equal Split';
      case SplitMode.exactAmount:
        return 'Exact Amounts (\$)';
      case SplitMode.percentage:
        return 'Ratio / Percentage (%)';
    }
  }

  IconData get icon {
    switch (this) {
      case SplitMode.equal:
        return Icons.pie_chart_rounded;
      case SplitMode.exactAmount:
        return Icons.attach_money_rounded;
      case SplitMode.percentage:
        return Icons.percent_rounded;
    }
  }
}
