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
}
