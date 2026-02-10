// lib/data/plant_images.dart
class PlantImages {
  static final Map<String, String> plantImagePaths = {
    'Монстера': 'assets/images/monstera.jpg',
    'Фикус Бенджамина': 'assets/images/ficus.jpg',
    'Замиокулькас': 'assets/images/zamioculcas.jpg',
    'Сансевиерия': 'assets/images/sansevieria.jpg',
    'Хлорофитум': 'assets/images/chlorophytum.jpg',
    'Крассула': 'assets/images/crassula.jpg',
    'Спатифиллум': 'assets/images/spathiphyllum.jpg',
    'Алоэ Вера': 'assets/images/aloe.jpg',
    'Антуриум': 'assets/images/anthurium.jpg',
    'Герань': 'assets/images/geranium.jpg',
    'Бегония': 'assets/images/begonia.jpg',
    'Драцена': 'assets/images/dracaena.jpg',
    'Шеффлера': 'assets/images/schefflera.jpg',
    'Фиалка': 'assets/images/violet.jpg',
    'Кактус': 'assets/images/cactus.jpg',
    'Плющ': 'assets/images/ivy.jpg',
  };

  static String getImagePath(String plantName) {
    return plantImagePaths[plantName] ?? 'assets/images/default_plant.jpg';
  }
  
  static List<String> getAllPlantNames() {
    return plantImagePaths.keys.toList();
  }
}