import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/plant.dart';

class TestHiveScreen extends StatelessWidget {
  const TestHiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Plant>('plants');
    
    return Scaffold(
      appBar: AppBar(title: const Text('Тест Hive')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Растений в Box: ${box.length}'),
            
            ElevatedButton(
              onPressed: () {
                // Простой тест без уведомлений
                final testPlant = Plant(
                  id: 'test_${DateTime.now().millisecondsSinceEpoch}',
                  name: 'Тестовое растение',
                  type: 'Тест',
                  addedDate: DateTime.now(),
                  lastWatered: DateTime.now(),
                  wateringInterval: 7,
                );
                
                print("🟢 Сохранение тестового растения: ${testPlant.id}");
                box.put(testPlant.id, testPlant);
                print("✅ Сохранено. Теперь растений: ${box.length}");
                
                // Проверяем сразу
                final saved = box.get(testPlant.id);
                print("🔍 Проверка: ${saved?.name ?? 'НЕ СОХРАНИЛОСЬ'}");
              },
              child: const Text('Добавить тестовое растение'),
            ),
            
            ElevatedButton(
              onPressed: () {
                print("📊 Содержимое Box:");
                print("   Количество: ${box.length}");
                print("   Ключи: ${box.keys.toList()}");
                
                for (var key in box.keys) {
                  final plant = box.get(key);
                  print("   $key: ${plant?.name} (${plant?.type})");
                }
              },
              child: const Text('Показать содержимое Box'),
            ),
            
            ElevatedButton(
              onPressed: () {
                box.clear();
                print("🧹 Box очищен");
              },
              child: const Text('Очистить Box'),
            ),
            
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Вернуться'),
            ),
          ],
        ),
      ),
    );
  }
}