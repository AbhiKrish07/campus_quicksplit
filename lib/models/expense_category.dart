import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CategoryType {
  coffee,
  food,
  shopping,
  subscription,
  rent,
  utilities,
  travel,
  general,
}

class ExpenseCategory {
  final CategoryType type;
  final String name;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
  });

  static final List<ExpenseCategory> categories = [
    const ExpenseCategory(
      type: CategoryType.coffee,
      name: 'Coffee',
      icon: Icons.local_cafe_rounded,
      color: AppColors.catCoffee,
    ),
    const ExpenseCategory(
      type: CategoryType.food,
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: AppColors.catFood,
    ),
    const ExpenseCategory(
      type: CategoryType.shopping,
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.catShopping,
    ),
    const ExpenseCategory(
      type: CategoryType.subscription,
      name: 'Subscriptions',
      icon: Icons.subscriptions_rounded,
      color: AppColors.catSub,
    ),
    const ExpenseCategory(
      type: CategoryType.rent,
      name: 'Rent & Housing',
      icon: Icons.home_rounded,
      color: AppColors.catRent,
    ),
    const ExpenseCategory(
      type: CategoryType.utilities,
      name: 'Utilities',
      icon: Icons.bolt_rounded,
      color: AppColors.catUtil,
    ),
    const ExpenseCategory(
      type: CategoryType.travel,
      name: 'Travel & Cab',
      icon: Icons.directions_car_rounded,
      color: AppColors.catTravel,
    ),
    const ExpenseCategory(
      type: CategoryType.general,
      name: 'General',
      icon: Icons.receipt_long_rounded,
      color: AppColors.catGeneral,
    ),
  ];

  static ExpenseCategory fromType(CategoryType type) {
    return categories.firstWhere(
      (c) => c.type == type,
      orElse: () => categories.last,
    );
  }
}
