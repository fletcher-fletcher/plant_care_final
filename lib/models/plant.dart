// lib/models/plant.dart - ОБНОВЛЕННЫЙ С ИМПОРТАМИ
import 'package:flutter/material.dart'; // ← ДОБАВИТЬ ЭТОТ ИМПОРТ
import 'package:hive/hive.dart';

part 'plant.g.dart';

@HiveType(typeId: 0)
class Plant extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String type;
  
  @HiveField(3)
  String? speciesId;
  
  @HiveField(4)
  DateTime addedDate;
  
  @HiveField(5)
  DateTime lastWatered;
  
  @HiveField(6)
  int wateringInterval;
  
  @HiveField(7)
  int? nextWateringNotificationId;
  
  @HiveField(8)
  int? nextFertilizingNotificationId;
  
  @HiveField(9)
  int? nextRepottingNotificationId;

  // Путь к изображению
  @HiveField(10)
  String? imagePath;

  // НОВОЕ ПОЛЕ: интервал удобрения
  @HiveField(11)
  int fertilizingInterval;

  Plant({
    required this.id,
    required this.name,
    required this.type,
    this.speciesId,
    required this.addedDate,
    required this.lastWatered,
    this.wateringInterval = 7,
    this.fertilizingInterval = 30, // Значение по умолчанию - 30 дней
    this.nextWateringNotificationId,
    this.nextFertilizingNotificationId,
    this.nextRepottingNotificationId,
    this.imagePath,
  });

  factory Plant.create(String name, String type, {String? speciesId, String? imagePath}) {
    return Plant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      speciesId: speciesId,
      addedDate: DateTime.now(),
      lastWatered: DateTime.now().subtract(const Duration(days: 1)),
      wateringInterval: _getDefaultInterval(type),
      fertilizingInterval: 30, // Стандартное значение
      imagePath: imagePath,
    );
  }

  static int _getDefaultInterval(String type) {
    switch (type.toLowerCase()) {
      case 'кактус':
        return 14;
      case 'суккулент':
        return 10;
      case 'тропическое':
        return 5;
      default:
        return 7;
    }
  }

  static int _getDefaultFertilizingInterval(String type) {
    switch (type.toLowerCase()) {
      case 'кактус':
        return 60; // Кактусы удобряют реже
      case 'суккулент':
        return 45; // Суккуленты тоже реже
      case 'тропическое':
        return 20; // Тропические растения чаще
      case 'цветущее':
        return 15; // Цветущие растения чаще
      default:
        return 30; // Стандартно
    }
  }

  Plant copyWith({
    String? id,
    String? name,
    String? type,
    String? speciesId,
    DateTime? addedDate,
    DateTime? lastWatered,
    int? wateringInterval,
    int? fertilizingInterval,
    int? nextWateringNotificationId,
    int? nextFertilizingNotificationId,
    int? nextRepottingNotificationId,
    String? imagePath,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      speciesId: speciesId ?? this.speciesId,
      addedDate: addedDate ?? this.addedDate,
      lastWatered: lastWatered ?? this.lastWatered,
      wateringInterval: wateringInterval ?? this.wateringInterval,
      fertilizingInterval: fertilizingInterval ?? this.fertilizingInterval,
      nextWateringNotificationId: nextWateringNotificationId ?? this.nextWateringNotificationId,
      nextFertilizingNotificationId: nextFertilizingNotificationId ?? this.nextFertilizingNotificationId,
      nextRepottingNotificationId: nextRepottingNotificationId ?? this.nextRepottingNotificationId,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  // Метод для получения рекомендаций по уходу
  Map<String, String> getCareRecommendations() {
    return {
      'Полив': 'Каждые $wateringInterval дней',
      'Удобрение': 'Каждые $fertilizingInterval дней',
      'Пересадка': 'Каждые 365 дней (1 год)',
      'Освещение': _getLightRecommendation(type),
      'Температура': '18-25°C',
    };
  }

  static String _getLightRecommendation(String type) {
    switch (type.toLowerCase()) {
      case 'кактус':
        return 'Яркое солнце';
      case 'суккулент':
        return 'Яркий свет';
      case 'тропическое':
        return 'Рассеянный свет';
      case 'фикус':
        return 'Яркий рассеянный свет';
      default:
        return 'Умеренный свет';
    }
  }

  // Проверка нужно ли поливать
  bool get needsWatering {
    final daysSinceWatering = DateTime.now().difference(lastWatered).inDays;
    return daysSinceWatering >= wateringInterval;
  }

  // Проверка нужно ли удобрять (примерная логика)
  bool get needsFertilizing {
    // Для простоты считаем что удобряем через заданный интервал
    // В реальном приложении нужно хранить lastFertilized
    return false; // TODO: Добавить логику
  }

  // Получить цвет статуса полива
  Color get wateringStatusColor {
    final daysSinceWatering = DateTime.now().difference(lastWatered).inDays;
    final progress = daysSinceWatering / wateringInterval;
    
    if (progress < 0.5) return Colors.green;
    if (progress < 0.8) return Colors.orange;
    return Colors.red;
  }

  // Получить текст статуса полива
  String get wateringStatusText {
    final daysSinceWatering = DateTime.now().difference(lastWatered).inDays;
    
    if (daysSinceWatering == 0) return 'Полито сегодня';
    if (daysSinceWatering == 1) return 'Полито вчера';
    
    final daysUntilWatering = wateringInterval - daysSinceWatering;
    
    if (daysUntilWatering > 0) {
      return 'Полив через $daysUntilWatering ${_getDayWord(daysUntilWatering)}';
    } else {
      return 'Пора поливать!';
    }
  }

  String _getDayWord(int days) {
    if (days % 10 == 1 && days % 100 != 11) return 'день';
    if (days % 10 >= 2 && days % 10 <= 4 && (days % 100 < 10 || days % 100 >= 20)) {
      return 'дня';
    }
    return 'дней';
  }

  @override
  String toString() {
    return 'Plant{id: $id, name: $name, type: $type, wateringInterval: $wateringInterval, fertilizingInterval: $fertilizingInterval}';
  }
}