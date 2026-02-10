// lib/services/notification_service.dart
import 'package:flutter/services.dart';

class NotificationService {
  static const MethodChannel _channel = MethodChannel('plant_care/notifications');
  
  // Инициализация - ничего не делаем для нативной реализации
  static Future<void> init() async {
    print("NotificationService: Инициализация нативной системы уведомлений");
    
    // Проверяем наличие разрешений на Android 13+
    try {
      if (await hasNotificationPermission() == false) {
        print("NotificationService: Разрешения не предоставлены");
        // Можно запросить разрешение через нативную сторону
      }
    } catch (e) {
      print("NotificationService: Ошибка проверки разрешений: $e");
    }
  }
  
  // Проверить разрешения (только для Android 13+)
  static Future<bool> hasNotificationPermission() async {
    try {
      return await _channel.invokeMethod('hasNotificationPermission') ?? false;
    } catch (e) {
      print("Ошибка проверки разрешений: $e");
      return false;
    }
  }
  
  // Запросить разрешения (только для Android 13+)
  static Future<bool> requestNotificationPermission() async {
    try {
      return await _channel.invokeMethod('requestNotificationPermission') ?? false;
    } catch (e) {
      print("Ошибка запроса разрешений: $e");
      return false;
    }
  }
  
  // Запланировать уведомление
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? payload, // Дополнительные данные
  }) async {
    try {
      print("NotificationService: Планирование уведомления $id на $scheduledTime");
      
      final args = {
        'id': id,
        'title': title,
        'body': body,
        'timeInMillis': scheduledTime.millisecondsSinceEpoch,
        'payload': payload ?? {},
      };
      
      final result = await _channel.invokeMethod('scheduleNotification', args);
      
      if (result == true) {
        print("NotificationService: Уведомление $id успешно запланировано");
      } else {
        print("NotificationService: Ошибка при планировании уведомления $id");
      }
    } catch (e) {
      print('Ошибка планирования уведомления: $e');
      rethrow;
    }
  }
  
  // Запланировать повторяющееся уведомление (ежедневное, еженедельное)
  static Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required DateTime initialTime,
    required int intervalHours, // Интервал в часах (0 для ежедневно в то же время)
    Map<String, dynamic>? payload,
  }) async {
    try {
      print("NotificationService: Планирование повторяющегося уведомления $id");
      
      final args = {
        'id': id,
        'title': title,
        'body': body,
        'timeInMillis': initialTime.millisecondsSinceEpoch,
        'intervalHours': intervalHours,
        'payload': payload ?? {},
      };
      
      final result = await _channel.invokeMethod('scheduleRepeatingNotification', args);
      
      if (result == true) {
        print("NotificationService: Повторяющееся уведомление $id успешно запланировано");
      } else {
        print("NotificationService: Ошибка при планировании повторяющегося уведомления $id");
      }
    } catch (e) {
      print('Ошибка планирования повторяющегося уведомления: $e');
      rethrow;
    }
  }
  
  // Отменить уведомление
  static Future<void> cancelNotification(int id) async {
    try {
      print("NotificationService: Отмена уведомления $id");
      
      final result = await _channel.invokeMethod('cancelNotification', {'id': id});
      
      if (result == true) {
        print("NotificationService: Уведомление $id успешно отменено");
      } else {
        print("NotificationService: Ошибка при отмене уведомления $id");
      }
    } catch (e) {
      print('Ошибка отмены уведомления: $e');
      rethrow;
    }
  }
  
  // Отменить все уведомления
  static Future<void> cancelAllNotifications() async {
    try {
      print("NotificationService: Отмена всех уведомлений");
      
      final result = await _channel.invokeMethod('cancelAllNotifications');
      
      if (result == true) {
        print("NotificationService: Все уведомления успешно отменены");
      } else {
        print("NotificationService: Ошибка при отмене всех уведомлений");
      }
    } catch (e) {
      print('Ошибка отмены всех уведомлений: $e');
      rethrow;
    }
  }
  
  // Получить все запланированные уведомления
  static Future<List<Map<String, dynamic>>> getScheduledNotifications() async {
    try {
      final result = await _channel.invokeMethod('getScheduledNotifications');
      return List<Map<String, dynamic>>.from(result ?? []);
    } catch (e) {
      print('Ошибка получения списка уведомлений: $e');
      return [];
    }
  }
  
  // Проверить, запланировано ли уведомление
  static Future<bool> isNotificationScheduled(int id) async {
    try {
      return await _channel.invokeMethod('isNotificationScheduled', {'id': id}) ?? false;
    } catch (e) {
      print('Ошибка проверки уведомления: $e');
      return false;
    }
  }
  
  // Отобразить уведомление немедленно (для тестирования)
  static Future<void> showNotificationNow({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final args = {
        'id': id,
        'title': title,
        'body': body,
        'payload': payload ?? {},
      };
      
      await _channel.invokeMethod('showNotificationNow', args);
      print("NotificationService: Немедленное уведомление $id показано");
    } catch (e) {
      print('Ошибка отображения уведомления: $e');
    }
  }
  
  // Вспомогательные методы для работы с растениями
  static Future<void> scheduleWateringReminder({
    required int plantId,
    required String plantName,
    required DateTime wateringTime,
    int notificationIdOffset = 1000, // Базовый ID для полива
  }) async {
    final id = notificationIdOffset + plantId;
    
    await scheduleNotification(
      id: id,
      title: 'Пора полить растение 🌱',
      body: 'Не забудьте полить $plantName',
      scheduledTime: wateringTime,
      payload: {
        'type': 'watering',
        'plantId': plantId,
        'plantName': plantName,
      },
    );
  }
  
  static Future<void> scheduleFertilizingReminder({
    required int plantId,
    required String plantName,
    required DateTime fertilizingTime,
    int notificationIdOffset = 2000, // Базовый ID для удобрения
  }) async {
    final id = notificationIdOffset + plantId;
    
    await scheduleNotification(
      id: id,
      title: 'Время удобрить растение 🌿',
      body: 'Не забудьте удобрить $plantName',
      scheduledTime: fertilizingTime,
      payload: {
        'type': 'fertilizing',
        'plantId': plantId,
        'plantName': plantName,
      },
    );
  }
  
  // Отменить все напоминания для растения
  static Future<void> cancelAllPlantReminders(int plantId) async {
    // Отменяем уведомления полива
    await cancelNotification(1000 + plantId);
    
    // Отменяем уведомления удобрения
    await cancelNotification(2000 + plantId);
    
    print("NotificationService: Все напоминания для растения $plantId отменены");
  }
  
  // Простая заглушка для тестирования
  static Future<void> testNotification() async {
    await showNotificationNow(
      id: 999,
      title: 'Тест уведомления ✅',
      body: 'Нативная система уведомлений работает!',
    );
  }
}