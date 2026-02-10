// lib/main.dart - ИСПРАВЛЕННЫЙ ВАРИАНТ
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:plant_care_app/models/plant.dart'; 
import 'package:plant_care_app/screens/home_screen.dart';
import 'package:plant_care_app/screens/add_plant_screen.dart';
import 'package:plant_care_app/services/notification_service.dart';
import 'package:plant_care_app/utils/hive_adapters.dart';
import 'package:plant_care_app/repositories/plant_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("🚀 Запуск приложения PlantCare");
  
  try {
    // Инициализация Hive
    await Hive.initFlutter();
    
    print("🧹 Проверяем, нужно ли очищать базу...");
    // await Hive.deleteBoxFromDisk('plants'); // ← ЗАКОММЕНТИРУЙТЕ после 1 запуска!
    
    // Регистрация адаптеров
    registerAdapters();  
    
    // Открытие Box для растений
    final plantBox = await Hive.openBox<Plant>('plants');
    print("✅ База данных готова. Растений в базе: ${plantBox.length}");
    
    // Проверка содержимого
    if (plantBox.isEmpty) {
      print("📭 База растений пуста");
    } else {
      print("📚 В базе найдено ${plantBox.length} растений:");
      for (var i = 0; i < plantBox.length; i++) {
        final plant = plantBox.getAt(i);
        if (plant != null) {
          print("   ${i + 1}. ${plant.name} (${plant.type}) - Полив каждые ${plant.wateringInterval} дней");
        }
      }
    }

    // Инициализация репозитория растений
    await PlantRepository.init();
    print("📦 Репозиторий растений инициализирован");

    // Инициализация уведомлений
    await NotificationService.init();
    print("🔔 Сервис уведомлений инициализирован");
    
    // Показать статистику
    _showStartupStats();
    
    print("🎉 Приложение успешно инициализировано");
    
  } catch (e, stackTrace) {
    print("❌ Ошибка инициализации приложения: $e");
    print("📝 Stack trace: $stackTrace");
  }

  runApp(const MyApp());
}

void _showStartupStats() {
  try {
    final plants = PlantRepository.getAllPlants();
    if (plants.isNotEmpty) {
      final needsWater = plants.where((p) => p.needsWatering).length;
      print("📊 Статистика запуска:");
      print("   Всего растений: ${plants.length}");
      print("   Требуют полива: $needsWater");
      
      // Группировка по типам
      final typeCounts = <String, int>{};
      for (final plant in plants) {
        typeCounts[plant.type] = (typeCounts[plant.type] ?? 0) + 1;
      }
      
      print("   По типам:");
      typeCounts.forEach((type, count) {
        print("     - $type: $count");
      });
    }
  } catch (e) {
    print("⚠️ Не удалось получить статистику: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantCare',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/add_plant': (context) => const AddPlantScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}