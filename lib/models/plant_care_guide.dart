// lib/models/plant_care_guide.dart
class PlantCareGuide {
  final String id;
  final String name;
  final String scientificName;
  final String family;
  final String origin;
  final String difficulty; // Легкий/Средний/Сложный
  final String description;
  final String light;
  final String temperature;
  final String watering;
  final String humidity;
  final String soil;
  final String fertilization;
  final String propagation;
  final String pruning;
  final String repotting;
  final String commonProblems;
  final String toxicity; // Для животных/детей
  final List<String> benefits; // Польза растения
  final List<String> tips; // Дополнительные советы
  final String imageUrl;

  PlantCareGuide({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.family,
    required this.origin,
    required this.difficulty,
    required this.description,
    required this.light,
    required this.temperature,
    required this.watering,
    required this.humidity,
    required this.soil,
    required this.fertilization,
    required this.propagation,
    required this.pruning,
    required this.repotting,
    required this.commonProblems,
    required this.toxicity,
    required this.benefits,
    required this.tips,
    required this.imageUrl,
  });

  // Фабричный метод для создания из JSON
  factory PlantCareGuide.fromJson(Map<String, dynamic> json) {
    return PlantCareGuide(
      id: json['id'],
      name: json['name'],
      scientificName: json['scientificName'],
      family: json['family'],
      origin: json['origin'],
      difficulty: json['difficulty'],
      description: json['description'],
      light: json['light'],
      temperature: json['temperature'],
      watering: json['watering'],
      humidity: json['humidity'],
      soil: json['soil'],
      fertilization: json['fertilization'],
      propagation: json['propagation'],
      pruning: json['pruning'],
      repotting: json['repotting'],
      commonProblems: json['commonProblems'],
      toxicity: json['toxicity'],
      benefits: List<String>.from(json['benefits']),
      tips: List<String>.from(json['tips']),
      imageUrl: json['imageUrl'],
    );
  }
}