class User {
  final String id;
  final String? name;
  final String region;
  final String gardenType;
  final bool notificationsEnabled;

  User({
    required this.id,
    this.name,
    required this.region,
    required this.gardenType,
    this.notificationsEnabled = true,
  });
}