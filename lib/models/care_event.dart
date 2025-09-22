class CareEvent {
  final String id;
  final String plantId;
  final String title;
  final String description;
  final DateTime date;
  final bool isCompleted;
  final List<CareOption> options;

  CareEvent({
    required this.id,
    required this.plantId,
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
    required this.options,
  });
}

class CareOption {
  final String type;
  final String title;
  final String instructions;
  final List<String> products;
  final List<String> alternatives;

  CareOption({
    required this.type,
    required this.title,
    required this.instructions,
    required this.products,
    required this.alternatives,
  });
}