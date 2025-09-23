class Plant {
  final String id;
  final String name;
  final String? variety;
  final DateTime plantingDate;
  final String growthStage;
  final String imageUrl;
  final String description;
  final String category;
  final String? culture; // Каноническое название культуры для поиска планов

  Plant({
    required this.id,
    required this.name,
    this.variety,
    required this.plantingDate,
    required this.growthStage,
    required this.imageUrl,
    required this.description,
    required this.category,
    this.culture,
  });
}