// lib/utils/hive_adapters.dart
import 'package:hive/hive.dart';
import '../models/plant.dart';

void registerAdapters() {
  // РЕГИСТРИРУЕМ адаптер вручную!
  if (!Hive.isAdapterRegistered(0)) {  // typeId = 0
    Hive.registerAdapter(PlantAdapter());
    print("✅ Адаптер Plant зарегистрирован (typeId: 0)");
  } else {
    print("✅ Адаптер Plant уже зарегистрирован");
  }
}