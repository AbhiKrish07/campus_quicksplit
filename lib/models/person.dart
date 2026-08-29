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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'initials': initials,
        'color': color.toARGB32(),
      };

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        initials: json['initials'] as String? ??
            ((json['name'] as String).isNotEmpty ? (json['name'] as String)[0].toUpperCase() : 'P'),
        color: json['color'] != null ? Color(json['color'] as int) : Colors.deepPurpleAccent,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
