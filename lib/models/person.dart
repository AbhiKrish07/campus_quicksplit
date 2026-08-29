import 'package:flutter/material.dart';

class Person {
  final String id;
  final String name;
  final String? avatarUrl;
  final String initials;
  final Color color;

  const Person({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.initials,
    this.color = Colors.deepPurpleAccent,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
