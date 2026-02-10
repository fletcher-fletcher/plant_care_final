// lib/services/hive_service.dart
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/plant.dart';

class HiveService {
  static Future<void> initHive() async {
    // Инициализация Hive с постоянным путем
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    
    print("📁 Hive инициализирован по пути: ${appDocumentDir.path}");
    
    // Регистрация адаптеров
    await _registerAdapters();
    
    // Открытие Box'ов
    await _openBoxes();
  }
  
  static Future<void> _registerAdapters() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PlantAdapter());
      print("✅ Адаптер Plant зарегистрирован (typeId: 0)");
    }
  }
  
  static Future<void> _openBoxes() async {
    // Открываем Box для растений
    await Hive.openBox<Plant>('plants');
    print("📦 Box 'plants' открыт");
    
    // Можно добавить другие Box'ы здесь
    // await Hive.openBox('settings');
  }
  
  // Геттер для удобного доступа к Box
  static Box<Plant> get plantsBox => Hive.box<Plant>('plants');
  
  // Закрытие Hive при выходе из приложения
  static Future<void> closeHive() async {
    await Hive.close();
    print("🔒 Hive закрыт");
  }
}