import 'package:flutter/material.dart';
import '../models/person.dart';
import '../theme/app_colors.dart';

class AvatarStack extends StatelessWidget {
  final List<Person> people;
  final int maxVisible;
  final double size;

  const AvatarStack({
    super.key,
    required this.people,
    this.maxVisible = 3,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();

    final visiblePeople = people.take(maxVisible).toList();
    final overflowCount = people.length - maxVisible;

    return SizedBox(
      height: size,
      width: (visiblePeople.length * (size * 0.7)) +
          (overflowCount > 0 ? (size * 0.7) : 0) +
          (size * 0.3),
      child: Stack(
        children: [
          for (int i = 0; i < visiblePeople.length; i++)
            Positioned(
              left: i * (size * 0.65),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: visiblePeople[i].color,
                  border: Border.all(color: AppColors.cardBackground, width: 2),
                ),
                child: Center(
                  child: Text(
                    visiblePeople[i].initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          if (overflowCount > 0)
            Positioned(
              left: visiblePeople.length * (size * 0.65),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cardElevated,
                  border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '+$overflowCount',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: size * 0.38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
