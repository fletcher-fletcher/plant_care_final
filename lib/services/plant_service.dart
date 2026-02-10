// lib/services/plant_service.dart - ПОЛНЫЙ ИСПРАВЛЕННЫЙ ФАЙЛ
import 'package:hive/hive.dart';
import '../models/plant.dart';
import '../services/notification_service.dart';

class PlantService {
  static final Box<Plant> _box = Hive.box<Plant>('plants');
  static int _nextNotificationId = 1;

  static int _generateNotificationId() {
    if (_nextNotificationId >= 2147483647) {
      _nextNotificationId = 1;
    }
    return _nextNotificationId++;
  }

  static List<Plant> getAllPlants() {
    return _box.values.toList();
  }

  static void updatePlant(Plant plant) {
    _box.put(plant.id, plant);
  }

  static Plant? getPlant(String id) {
    return _box.get(id);
  }

  /// Добавляет растение и планирует первые уведомления
  static Future<String> addPlantWithNotifications(Plant plant) async {
    print("🌱 PlantService: Добавление растения '${plant.name}'");
    print("   📦 Box 'plants' ДО добавления: ${_box.length} растений");
    
    try {
      print("   📋 Используем базовые настройки...");
      
      // Фиксированные значения для ухода (можно настраивать позже)
      final wateringIntervalDays = plant.wateringInterval; // Используем значение из растения
      final fertilizingIntervalMonths = 1; // Удобрение каждый месяц
      final repottingYears = 1; // Пересадка каждый год
      
      // Генерируем безопасные ID
      final wateringId = _generateNotificationId();
      print("   💧 ID уведомления полива: $wateringId");

      // Планируем полив
      final nextWatering = DateTime.now().add(Duration(days: wateringIntervalDays));
      print("   ⏰ Следующий полив: $nextWatering");
      
      await NotificationService.scheduleNotification(
        id: wateringId,
        title: 'Пора полить растение!',
        body: 'Не забудьте полить «${plant.name}».',
        scheduledTime: nextWatering,
      );
      print("   ✅ Уведомление полива запланировано");

      int? fertilizingId;
      int? repottingId;

      // Планируем удобрение
      fertilizingId = _generateNotificationId();
      final nextFertilizing = DateTime.now().add(Duration(days: fertilizingIntervalMonths * 30));
      await NotificationService.scheduleNotification(
        id: fertilizingId,
        title: 'Время подкормить растение!',
        body: 'Подкормите «${plant.name}» удобрением.',
        scheduledTime: nextFertilizing,
      );
      print("   ✅ Уведомление удобрения запланировано");

      // Планируем пересадку
      repottingId = _generateNotificationId();
      final nextRepotting = DateTime.now().add(Duration(days: repottingYears * 365));
      await NotificationService.scheduleNotification(
        id: repottingId,
        title: 'Пора пересадить растение!',
        body: '«${plant.name}» пора пересадить в новый горшок.',
        scheduledTime: nextRepotting,
      );
      print("   ✅ Уведомление пересадки запланировано");

      // Сохраняем ID уведомлений в модель
      final updatedPlant = plant.copyWith(
        nextWateringNotificationId: wateringId,
        nextFertilizingNotificationId: fertilizingId,
        nextRepottingNotificationId: repottingId,
      );
      
      print("   💾 Сохранение в Hive...");
      print("   🔑 ID растения: ${updatedPlant.id}");
      
      _box.put(updatedPlant.id, updatedPlant);
      
      // Проверяем что сохранилось
      final savedPlant = _box.get(updatedPlant.id);
      print("   🔍 Проверка сохранения: ${savedPlant?.name ?? 'НЕ СОХРАНИЛОСЬ!'}");
      print("   📊 Box 'plants' ПОСЛЕ добавления: ${_box.length} растений");
      
      // Выводим все ключи
      print("   🔑 Все ключи в Box: ${_box.keys.toList()}");
      
      return updatedPlant.id;
      
    } catch (e) {
      print("❌ Ошибка в addPlantWithNotifications: $e");
      print("Stack trace: ${e.toString()}");
      rethrow;
    }
  }

  /// Обновляет дату последнего полива и перепланирует уведомление
  static Future<void> markWatered(String plantId) async {
    final plant = _box.get(plantId);
    if (plant == null) return;

    // Используем интервал полива из растения
    final wateringIntervalDays = plant.wateringInterval;
    
    final nextWatering = DateTime.now().add(Duration(days: wateringIntervalDays));
    final newId = _generateNotificationId();
    await NotificationService.scheduleNotification(
      id: newId,
      title: 'Пора полить растение!',
      body: 'Не забудьте полить «${plant.name}».',
      scheduledTime: nextWatering,
    );

    final updatedPlant = plant.copyWith(
      lastWatered: DateTime.now(),
      nextWateringNotificationId: newId,
    );
    
    _box.put(updatedPlant.id, updatedPlant);
  }

  static void deletePlant(String id) {
    _box.delete(id);
  }
}