// lib/repositories/plant_repository.dart
import 'package:hive/hive.dart';
import '../models/plant.dart';

class PlantRepository {
  static late Box<Plant> _plantsBox;

  static Future<void> init() async {
    _plantsBox = Hive.box<Plant>('plants');
  }

  // Получить все растения
  static List<Plant> getAllPlants() {
    return _plantsBox.values.toList();
  }

  // Добавить растение
  static Future<void> addPlant(Plant plant) async {
    await _plantsBox.add(plant);
  }

  // Обновить растение (исправленный метод с одним параметром)
  static Future<void> updatePlant(Plant plant) async {
    final index = _plantsBox.values.toList().indexWhere((p) => p.id == plant.id);
    if (index != -1) {
      await _plantsBox.putAt(index, plant);
    }
  }

  // Удалить растение по индексу
  static Future<void> deletePlant(int index) async {
    await _plantsBox.deleteAt(index);
  }

  // Удалить растение по ID
  static Future<void> deletePlantById(String id) async {
    final index = _plantsBox.values.toList().indexWhere((plant) => plant.id == id);
    if (index != -1) {
      await _plantsBox.deleteAt(index);
    }
  }

  // Найти растение по ID
  static Plant? getPlantById(String id) {
    return _plantsBox.values.firstWhere((plant) => plant.id == id);
  }

  // Получить растения, требующие полива
  static List<Plant> getPlantsNeedingWater() {
    return _plantsBox.values.where((plant) => plant.needsWatering).toList();
  }

  // Обновить дату полива (исправленный метод с одним параметром)
  static Future<void> waterPlant(Plant plant) async {
    plant.lastWatered = DateTime.now();
    await updatePlant(plant);
  }

  // Получить индекс растения
  static int getPlantIndex(Plant plant) {
    return _plantsBox.values.toList().indexWhere((p) => p.id == plant.id);
  }

  // Получить количество растений
  static int getCount() {
    return _plantsBox.length;
  }

  // Получить Box для ValueListenableBuilder
  static Box<Plant> get box => _plantsBox;
}