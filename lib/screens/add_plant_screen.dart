// lib/screens/add_plant_screen.dart - ИСПРАВЛЕННЫЙ ВАРИАНТ
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plant_care_app/repositories/plant_repository.dart';
import 'package:plant_care_app/models/plant.dart';
import 'package:plant_care_app/data/plant_images.dart';
import 'package:plant_care_app/services/notification_service.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _nameController = TextEditingController();
  String? _selectedPlantType;
  int _wateringInterval = 7;
  int _fertilizingInterval = 30;

  @override
  void initState() {
    super.initState();
    _selectedPlantType = PlantImages.getAllPlantNames().first;
    // Устанавливаем интервалы по умолчанию для выбранного типа
    _updateIntervalsForType(_selectedPlantType!);
  }

  void _updateIntervalsForType(String plantType) {
    // Логика определения интервалов полива
    switch (plantType.toLowerCase()) {
      case 'кактус':
        _wateringInterval = 14;
        _fertilizingInterval = 60;
        break;
      case 'суккулент':
        _wateringInterval = 10;
        _fertilizingInterval = 45;
        break;
      case 'тропическое':
        _wateringInterval = 5;
        _fertilizingInterval = 20;
        break;
      case 'цветущее':
        _wateringInterval = 4;
        _fertilizingInterval = 15;
        break;
      case 'фикус':
        _wateringInterval = 6;
        _fertilizingInterval = 25;
        break;
      case 'орхидея':
        _wateringInterval = 3;
        _fertilizingInterval = 10;
        break;
      case 'пальма':
        _wateringInterval = 5;
        _fertilizingInterval = 30;
        break;
      default:
        _wateringInterval = 7;
        _fertilizingInterval = 30;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantNames = PlantImages.getAllPlantNames();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить растение'),
		foregroundColor: Colors.black87,  
        backgroundColor: Colors.green[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Добавьте новое растение',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Поле для названия
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Название растения',
                hintText: 'Например: "Мой фикус в гостиной"',
                prefixIcon: const Icon(Icons.spa, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.green[50],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Выбор типа растения
            Text(
              'Выберите тип растения:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Выпадающий список с растениями
            Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPlantType,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                  iconSize: 30,
                  elevation: 16,
                  style: TextStyle(color: Colors.green[800], fontSize: 16),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPlantType = newValue;
                        _updateIntervalsForType(newValue);
                      });
                    }
                  },
                  items: plantNames.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(_getPlantIcon(value), color: Colors.green, size: 20),
                            const SizedBox(width: 12),
                            Text(value),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Отображение интервалов ухода
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Рекомендации по уходу:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('Полив:'),
                        const Spacer(),
                        Text(
                          'раз в $_wateringInterval ${_getDayWord(_wateringInterval)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.eco, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Удобрение:'),
                        const Spacer(),
                        Text(
                          'раз в $_fertilizingInterval ${_getDayWord(_fertilizingInterval)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Сетка с изображениями растений
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.9,
                ),
                itemCount: plantNames.length,
                itemBuilder: (context, index) {
                  final plantName = plantNames[index];
                  final isSelected = _selectedPlantType == plantName;
                  final imagePath = PlantImages.getImagePath(plantName);
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlantType = plantName;
                        _updateIntervalsForType(plantName);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green[50] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Изображение растения
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.asset(
                                imagePath,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.green[100],
                                    child: Center(
                                      child: Icon(
                                        _getPlantIcon(plantName),
                                        size: 36,
                                        color: Colors.green,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Название растения
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              plantName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.green[800] : Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Кнопка добавления
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _addPlant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Добавить растение',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayWord(int days) {
    if (days % 10 == 1 && days % 100 != 11) return 'день';
    if (days % 10 >= 2 && days % 10 <= 4 && (days % 100 < 10 || days % 100 >= 20)) {
      return 'дня';
    }
    return 'дней';
  }

  // Метод для получения иконки по типу растения
  IconData _getPlantIcon(String plantType) {
    switch (plantType) {
      case 'Монстера':
        return Icons.eco;
      case 'Фикус Бенджамина':
        return Icons.park;
      case 'Замиокулькас':
        return Icons.attach_money;
      case 'Сансевиерия':
        return Icons.grass;
      case 'Хлорофитум':
        return Icons.waves;
      case 'Крассула':
        return Icons.monetization_on;
      case 'Спатифиллум':
        return Icons.favorite;
      case 'Алоэ Вера':
        return Icons.medical_services;
      case 'Антуриум':
        return Icons.local_florist;
      case 'Герань':
        return Icons.local_florist;
      case 'Бегония':
        return Icons.eco;
      case 'Драцена':
        return Icons.palette;
      case 'Шеффлера':
        return Icons.umbrella;
      case 'Фиалка':
        return Icons.filter_vintage;
      case 'Кактус':
        return Icons.grass;
      case 'Плющ':
        return Icons.psychology;
      default:
        return Icons.spa;
    }
  }

Future<void> _addPlant() async {
  if (_nameController.text.isEmpty || _selectedPlantType == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Заполните название и выберите тип растения'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  final imagePath = PlantImages.getImagePath(_selectedPlantType!);
  print("🖼️ ========== ДОБАВЛЕНИЕ РАСТЕНИЯ ==========");
  print("📝 Пользовательское имя: ${_nameController.text}");
  print("🌿 Тип растения: $_selectedPlantType");
  print("💧 Интервал полива: $_wateringInterval дней");
  print("🌱 Интервал удобрения: $_fertilizingInterval дней");
  print("🖼️ Путь к изображению: $imagePath");

  try {
    // СОЗДАЕМ новое растение
    final newPlant = Plant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      type: _selectedPlantType!,
      speciesId: _selectedPlantType!,
      addedDate: DateTime.now(),
      lastWatered: DateTime.now(),
      wateringInterval: _wateringInterval,
      fertilizingInterval: _fertilizingInterval,
      nextWateringNotificationId: null,
      nextFertilizingNotificationId: null,
      nextRepottingNotificationId: null,
      imagePath: imagePath,
    );

    print("🌿 Создан объект Plant:");
    print("   • ID: ${newPlant.id}");
    print("   • Имя: ${newPlant.name}");
    print("   • Тип: ${newPlant.type}");
    print("   • ImagePath: ${newPlant.imagePath}");
    print("   • Интервал полива: ${newPlant.wateringInterval} дней");

    // 1. Сохраняем в Hive через PlantRepository
    await PlantRepository.addPlant(newPlant);
    print("✅ Растение сохранено в Hive");

    // 2. СОЗДАЕМ УВЕДОМЛЕНИЕ О ПОЛИВЕ (используем ваш метод)
    try {
      // Создаем ID для уведомления (используем millisecondsSinceEpoch как plantId)
      final plantIdForNotification = int.parse(newPlant.id.substring(newPlant.id.length - 6));
      
      // Рассчитываем время следующего полива
      final nextWateringTime = DateTime.now().add(Duration(days: _wateringInterval));
      
      // Запланировать уведомление о поливе
      await NotificationService.scheduleWateringReminder(
        plantId: plantIdForNotification,
        plantName: newPlant.name,
        wateringTime: nextWateringTime,
      );
      
      // Сохраняем ID уведомления в растение
      // Для вашего сервиса ID уведомления = 1000 + plantId
      newPlant.nextWateringNotificationId = 1000 + plantIdForNotification;
      
      // Обновляем растение с ID уведомления
      await PlantRepository.updatePlant(newPlant);
      
      print("🔔 Уведомление о поливе запланировано на $nextWateringTime");
      print("   ID уведомления: ${newPlant.nextWateringNotificationId}");
      
    } catch (e) {
      print("⚠️ Не удалось запланировать уведомление: $e");
      // Продолжаем работу даже если уведомления не работают
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Растение "${newPlant.name}" добавлено!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Возвращаемся на предыдущий экран
    if (mounted) {
      Navigator.pop(context, true);
    }
    
  } catch (e, stackTrace) {
    print("❌ ОШИБКА добавления растения:");
    print("Ошибка: $e");
    print("StackTrace: $stackTrace");
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Не удалось добавить растение'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
}
