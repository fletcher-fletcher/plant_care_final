// lib/screens/home_screen.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:plant_care_app/models/plant.dart';
import 'package:plant_care_app/repositories/plant_repository.dart';
import 'package:plant_care_app/screens/plant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои растения'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showStats,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: PlantRepository.box.listenable(),
        builder: (context, Box<Plant> box, _) {
          final plants = box.values.toList();
          
          if (plants.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return _buildPlantCard(plant, index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPlant,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            size: 100,
            color: Colors.green.shade300,
          ),
          const SizedBox(height: 20),
          const Text(
            'Пока нет растений',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          const Text(
            'Нажмите + чтобы добавить первое растение',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard(Plant plant, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: plant.wateringStatusColor.withOpacity(0.2),
          child: Icon(
            _getPlantIcon(plant.type),
            color: plant.wateringStatusColor,
          ),
        ),
        title: Text(
          plant.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plant.type.isNotEmpty) Text(plant.type),
            Text(
              plant.wateringStatusText,
              style: TextStyle(
                color: plant.wateringStatusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: plant.needsWatering
            ? const Icon(Icons.water_drop, color: Colors.blue)
            : null,
        onTap: () => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PlantDetailScreen(plant: plant),
  ),
),
      ),
    );
  }

  IconData _getPlantIcon(String type) {
    switch (type.toLowerCase()) {
      case 'кактус':
        return Icons.eco;
      case 'суккулент':
        return Icons.grass;
      case 'тропическое':
        return Icons.park;
      case 'цветущее':
        return Icons.local_florist;
      default:
        return Icons.eco;
    }
  }

void _navigateToAddPlant() {
  Navigator.pushNamed(context, '/add_plant').then((value) {
    if (value == true) {
      setState(() {}); // Обновляем список
    }
  });
}

  void _showPlantDetails(Plant plant, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Заголовок с иконкой
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: plant.wateringStatusColor.withOpacity(0.2),
                          radius: 30,
                          child: Icon(
                            _getPlantIcon(plant.type),
                            size: 30,
                            color: plant.wateringStatusColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plant.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (plant.type.isNotEmpty)
                                Text(
                                  plant.type,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Карточка с информацией
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Информация о растении',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            _buildInfoRow('Добавлено:', _formatDate(plant.addedDate)),
                            _buildInfoRow('Последний полив:', _formatDate(plant.lastWatered)),
                            _buildInfoRow('Интервал полива:', '${plant.wateringInterval} дней'),
                            _buildInfoRow('Интервал удобрения:', '${plant.fertilizingInterval} дней'),
                            _buildInfoRow('Статус полива:', plant.wateringStatusText),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Рекомендации по уходу
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Рекомендации по уходу',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...plant.getCareRecommendations().entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      '${entry.key}: ',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Expanded(child: Text(entry.value)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Кнопка полива
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await PlantRepository.waterPlant(plant);
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${plant.name} полито!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.water_drop, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Полить сейчас',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Кнопка закрытия
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Закрыть'),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showStats() {
    final plants = PlantRepository.getAllPlants();
    final needWater = plants.where((p) => p.needsWatering).length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Статистика'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Всего растений: ${plants.length}'),
            Text('Требуют полива: $needWater'),
            const SizedBox(height: 10),
            if (plants.isNotEmpty) ...[
              const Text('Растения:'),
              for (var i = 0; i < plants.length; i++)
                Text('  ${i + 1}. ${plants[i].name} - ${plants[i].wateringStatusText}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}