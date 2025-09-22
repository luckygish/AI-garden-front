class Plant {
  final String id;
  final String name;
  final String? variety;
  final DateTime plantingDate;
  final String growthStage;
  final String culture;
  final String region;
  final String gardenType;

  Plant({
    required this.id,
    required this.name,
    this.variety,
    required this.plantingDate,
    required this.growthStage,
    required this.culture,
    required this.region,
    required this.gardenType,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      name: json['name'],
      variety: json['variety'],
      plantingDate: DateTime.parse(json['plantingDate']),
      growthStage: json['growthStage'],
      culture: json['culture'],
      region: json['region'],
      gardenType: json['gardenType'],
    );
  }
}