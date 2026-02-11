// lib/screens/plant_detail_screen.dart - ПОЛНОСТЬЮ ОБНОВЛЕННЫЙ
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/plant.dart';
import 'care_guide_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;
  
  const PlantDetailScreen({Key? key, required this.plant}) : super(key: key);
  
  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<File> _plantPhotos = [];
  bool _isWatering = false;
  final ImagePicker _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPlantPhotos();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Загрузка сохраненных фото
  Future<void> _loadPlantPhotos() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final plantPhotosDir = Directory('${appDir.path}/plant_photos/${widget.plant.id}');
      
      if (plantPhotosDir.existsSync()) {
        final files = plantPhotosDir.listSync()
            .where((file) => file is File && 
                (file.path.toLowerCase().endsWith('.jpg') || 
                 file.path.toLowerCase().endsWith('.jpeg') ||
                 file.path.toLowerCase().endsWith('.png')))
            .map((file) => File(file.path))
            .toList();
        
        // Сортируем по имени (дате создания)
        files.sort((a, b) => b.path.compareTo(a.path));
        
        setState(() {
          _plantPhotos = files;
        });
        
        print("📸 Загружено ${files.length} фото для растения ${widget.plant.name}");
      }
    } catch (e) {
      print("❌ Ошибка загрузки фото: $e");
    }
  }
  
  Future<void> _waterPlant() async {
    setState(() {
      _isWatering = true;
    });
    
    // Имитация полива
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      widget.plant.lastWatered = DateTime.now();
      _isWatering = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.plant.name} полито! 💧'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  Future<void> _addPhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Выбрать из галереи'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Сделать фото'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhotoWithCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        await _savePhoto(File(pickedFile.path));
      }
    } catch (e) {
      _showError('Ошибка выбора фото: $e');
    }
  }
  
  Future<void> _takePhotoWithCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        await _savePhoto(File(pickedFile.path));
      }
    } catch (e) {
      _showError('Ошибка камеры: $e');
    }
  }
  
  Future<void> _savePhoto(File photoFile) async {
    try {
      // Создаем папку для фото если ее нет
      final appDir = await getApplicationDocumentsDirectory();
      final plantPhotosDir = Directory('${appDir.path}/plant_photos/${widget.plant.id}');
      if (!plantPhotosDir.existsSync()) {
        plantPhotosDir.createSync(recursive: true);
      }
      
      // Создаем уникальное имя файла с timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'photo_$timestamp.jpg';
      final savedPath = '${plantPhotosDir.path}/$fileName';
      
      // Копируем файл
      await photoFile.copy(savedPath);
      
      setState(() {
        _plantPhotos.insert(0, File(savedPath)); // Добавляем в начало
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фото сохранено! 📸'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
    } catch (e) {
      _showError('Ошибка сохранения фото: $e');
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _editCareSchedule() {
    int wateringInterval = widget.plant.wateringInterval;
    int fertilizingInterval = widget.plant.fertilizingInterval;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Настройки ухода'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ПОЛИВ
                  const Text(
                    'Полив каждые:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: wateringInterval.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    label: '$wateringInterval дней',
                    onChanged: (value) {
                      setState(() {
                        wateringInterval = value.toInt();
                      });
                    },
                    activeColor: Colors.green,
                    inactiveColor: Colors.green[100],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$wateringInterval дней',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // УДОБРЕНИЕ
                  const Text(
                    'Удобрение каждые:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: fertilizingInterval.toDouble(),
                    min: 7,
                    max: 90,
                    divisions: 83,
                    label: '$fertilizingInterval дней',
                    onChanged: (value) {
                      setState(() {
                        fertilizingInterval = value.toInt();
                      });
                    },
                    activeColor: Colors.blue,
                    inactiveColor: Colors.blue[100],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$fertilizingInterval дней',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      widget.plant.wateringInterval = wateringInterval;
                      widget.plant.fertilizingInterval = fertilizingInterval;
                    });
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Настройки сохранены: полив - $wateringInterval дней, удобрение - $fertilizingInterval дней'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  int get _daysSinceWatering {
    return DateTime.now().difference(widget.plant.lastWatered).inDays;
  }
  
  Color get _wateringStatusColor {
    if (_daysSinceWatering < widget.plant.wateringInterval) {
      return Colors.green;
    } else if (_daysSinceWatering < widget.plant.wateringInterval * 2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant.name),
		foregroundColor: Colors.black87,  
        backgroundColor: Colors.green[50],
        actions: [
          // Кнопка Базы знаний
          IconButton(
            icon: const Icon(Icons.library_books, color: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CareGuideScreen(plantType: widget.plant.type),
                ),
              );
            },
            tooltip: 'База знаний',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editCareSchedule,
            tooltip: 'Редактировать',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Инфо'),
            Tab(icon: Icon(Icons.water_drop), text: 'Уход'),
            Tab(icon: Icon(Icons.photo_library), text: 'Фото'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildCareTab(),
          _buildPhotosTab(),
        ],
      ),
    );
  }
  
  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Карточка растения
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green[100],
                        radius: 30,
                        backgroundImage: widget.plant.imagePath != null
                            ? AssetImage(widget.plant.imagePath!)
                            : null,
                        onBackgroundImageError: (exception, stackTrace) {},
                        child: widget.plant.imagePath == null
                            ? Text(
                                widget.plant.name[0],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.plant.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.plant.type,
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
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('📅', 'Возраст', 
                          '${DateTime.now().difference(widget.plant.addedDate).inDays} дн.'),
                      _buildStatItem('💧', 'Полив', 
                          '$_daysSinceWatering дн. назад'),
                      _buildStatItem('🔄', 'Интервал', 
                          '${widget.plant.wateringInterval} дн.'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Кнопка полива
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isWatering ? null : _waterPlant,
              icon: _isWatering 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.water_drop),
              label: Text(
                _isWatering ? 'Поливаем...' : 'Отметить полив',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _wateringStatusColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Информация
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Информация',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Добавлено', 
                      DateFormat('dd.MM.yyyy').format(widget.plant.addedDate)),
                  _buildInfoRow('Последний полив', 
                      DateFormat('dd.MM.yyyy HH:mm').format(widget.plant.lastWatered)),
                  _buildInfoRow('ID растения', widget.plant.id.substring(0, 8)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Блок Базы знаний
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.library_books, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '📚 База знаний: ${widget.plant.type}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'В нашей базе знаний есть подробная информация об уходе за ${widget.plant.type.toLowerCase()}.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                      const SizedBox(width: 8),
                      const Text('Полное руководство по уходу'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                      const SizedBox(width: 8),
                      const Text('Ответы на частые вопросы'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                      const SizedBox(width: 8),
                      const Text('Советы по поливу и освещению'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CareGuideScreen(plantType: widget.plant.type),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book),
                      label: const Text('Открыть базу знаний'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCareTab() {
    final daysUntilWatering = widget.plant.wateringInterval - _daysSinceWatering;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Статус ухода
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        color: _wateringStatusColor,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Статус полива',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _daysSinceWatering == 0 
                                ? 'Полито сегодня'
                                : 'Полито $_daysSinceWatering ${_getDayWord(_daysSinceWatering)} назад',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _wateringStatusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _daysSinceWatering / widget.plant.wateringInterval,
                    backgroundColor: Colors.grey[200],
                    color: _wateringStatusColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    daysUntilWatering > 0
                      ? 'Следующий полив через $daysUntilWatering ${_getDayWord(daysUntilWatering)}'
                      : 'Пора поливать!',
                    style: TextStyle(
                      color: daysUntilWatering > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Уход
          const Text(
            '📋 Режим ухода',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          _buildCareItem(
            icon: Icons.water_drop,
            title: 'Полив',
            value: 'Каждые ${widget.plant.wateringInterval} дней',
            color: Colors.blue,
          ),
          
          _buildCareItem(
            icon: Icons.grass,
            title: 'Удобрение',
            value: 'Каждые ${widget.plant.fertilizingInterval} дней',
            color: Colors.green,
          ),
          
          _buildCareItem(
            icon: Icons.light_mode,
            title: 'Свет',
            value: 'Яркий рассеянный',
            color: Colors.amber,
          ),
          
          _buildCareItem(
            icon: Icons.thermostat,
            title: 'Температура',
            value: '20-25°C',
            color: Colors.orange,
          ),
          
          const SizedBox(height: 20),
          
          // История ухода
          const Text(
            '📅 История ухода',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHistoryItem(
                    'Полив',
                    DateFormat('dd.MM.yyyy HH:mm').format(widget.plant.lastWatered),
                    Colors.blue,
                  ),
                  const Divider(),
                  _buildHistoryItem(
                    'Удобрение',
                    DateFormat('dd.MM.yyyy').format(
                      widget.plant.lastWatered.subtract(const Duration(days: 15))
                    ),
                    Colors.green,
                  ),
                  const Divider(),
                  _buildHistoryItem(
                    'Опрыскивание',
                    DateFormat('dd.MM.yyyy').format(
                      widget.plant.lastWatered.subtract(const Duration(days: 3))
                    ),
                    Colors.cyan,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPhotosTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _addPhoto,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Добавить фото'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        
        Expanded(
          child: _plantPhotos.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 100,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Нет фотографий',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Добавьте фото роста вашего растения',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _plantPhotos.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showPhotoDialog(index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _plantPhotos[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image, color: Colors.grey),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Фото ${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  // Метод для просмотра фото в полном размере
  void _showPhotoDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _plantPhotos[index],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white, size: 24),
                    onPressed: () => _deletePhoto(index),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Метод удаления фото
  void _deletePhoto(int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить фото?'),
          content: const Text('Это действие нельзя отменить.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Закрыть диалог подтверждения
                Navigator.pop(context); // Закрыть диалог просмотра фото
                
                try {
                  final file = _plantPhotos[index];
                  file.deleteSync();
                  
                  setState(() {
                    _plantPhotos.removeAt(index);
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Фото удалено'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  _showError('Ошибка удаления фото: $e');
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildStatItem(String emoji, String title, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  Widget _buildCareItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHistoryItem(String action, String date, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.check, color: color, size: 20),
      ),
      title: Text(action),
      subtitle: Text(date),
      trailing: null,
    );
  }
  
  String _getDayWord(int days) {
    if (days % 10 == 1 && days % 100 != 11) return 'день';
    if (days % 10 >= 2 && days % 10 <= 4 && (days % 100 < 10 || days % 100 >= 20)) {
      return 'дня';
    }
    return 'дней';
  }
}
