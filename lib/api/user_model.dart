class User {
  final String id;
  final String email;
  final String? name;
  final String region;
  final String gardenType;
  final String token;

  User({
    required this.id,
    required this.email,
    this.name,
    required this.region,
    required this.gardenType,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'],
      email: json['email'],
      name: json['name'],
      region: json['region'],
      gardenType: json['gardenType'],
      token: json['token'],
    );
  }
}