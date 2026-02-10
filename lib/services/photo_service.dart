// lib/services/photo_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PhotoService {
  // Сохранить фото растения
  static Future<String> savePlantPhoto(File imageFile, String plantId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final plantsDir = Directory('${appDir.path}/plants/$plantId');
      
      if (!await plantsDir.exists()) {
        await plantsDir.create(recursive: true);
      }
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${plantsDir.path}/$fileName';
      
      await imageFile.copy(savedPath);
      
      return fileName; // Сохраняем только имя файла
    } catch (e) {
      print('❌ Ошибка сохранения фото: $e');
      rethrow;
    }
  }
  
  // Получить фото растения
  static Future<File?> getPlantPhoto(String plantId, String fileName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final photoPath = '${appDir.path}/plants/$plantId/$fileName';
      
      final file = File(photoPath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('❌ Ошибка загрузки фото: $e');
      return null;
    }
  }
  
  // Получить все фото растения
  static Future<List<String>> getPlantPhotoPaths(String plantId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final plantsDir = Directory('${appDir.path}/plants/$plantId');
      
      if (await plantsDir.exists()) {
        final files = await plantsDir.list()
            .where((entity) => entity is File)
            .map((entity) => (entity as File).path.split('/').last)
            .toList();
        
        files.sort((a, b) => b.compareTo(a)); // Сначала новые
        return files;
      }
      return [];
    } catch (e) {
      print('❌ Ошибка получения списка фото: $e');
      return [];
    }
  }
  
  // Удалить фото
  static Future<void> deletePhoto(String plantId, String fileName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final photoPath = '${appDir.path}/plants/$plantId/$fileName';
      
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('❌ Ошибка удаления фото: $e');
    }
  }
}