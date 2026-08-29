import 'dart:math';
import 'package:flutter/material.dart';
import '../models/person.dart';
import '../theme/app_colors.dart';

class CircularParticipantView extends StatelessWidget {
  final List<Person> participants;
  final String paidById;
  final double perPersonShare;

  const CircularParticipantView({
    super.key,
    required this.participants,
    required this.paidById,
    required this.perPersonShare,
  });

  @override
  Widget build(BuildContext context) {
    const double radius = 100;
    const double avatarSize = 46;

    return Container(
      height: 270,
      width: double.infinity,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Concentric Orbit Circles
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
          ),
          Container(
            width: radius * 1.3,
            height: radius * 1.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),

          // Central Icon / Split Badge
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.cardAccentGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart_rounded, color: Colors.white, size: 24),
                SizedBox(height: 2),
                Text(
                  'Equal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Orbiting Participant Avatars
          for (int i = 0; i < participants.length; i++) ...[
            Builder(builder: (context) {
              final angle = (2 * pi / participants.length) * i - (pi / 2);
              final dx = radius * cos(angle);
              final dy = radius * sin(angle);
              final person = participants[i];
              final isPayer = person.id == paidById;

              return Transform.translate(
                offset: Offset(dx, dy),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: person.color,
                            border: Border.all(
                              color: isPayer
                                  ? AppColors.positive
                                  : AppColors.cardBackground,
                              width: isPayer ? 2.5 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: person.color.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              person.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        if (isPayer)
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.positive,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                color: Colors.black,
                                size: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        person.name.split(' ').first,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
