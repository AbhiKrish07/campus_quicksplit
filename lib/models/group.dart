class Group {
  final String id;
  final String name;
  final List<String> participantIds;
  final String? icon;

  const Group({
    required this.id,
    required this.name,
    required this.participantIds,
    this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'participantIds': participantIds,
        'icon': icon,
      };

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'] as String,
        name: json['name'] as String,
        participantIds: List<String>.from(json['participantIds'] as List),
        icon: json['icon'] as String?,
      );
}
