// lib/services/care_guide_service.dart
import '../data/plant_care_database.dart';
import '../models/plant_care_guide.dart';

class CareGuideService {
  // Найти руководство по уходу для растения
  static PlantCareGuide? getCareGuide(String plantName) {
    return PlantCareDatabase.findPlant(plantName);
  }

  // Получить ответ на вопрос о растении
  static String answerQuestion(String plantName, String question) {
    final guide = getCareGuide(plantName);
    
    if (guide == null) {
      return _getGeneralAdvice(plantName, question);
    }
    
    final lowerQuestion = question.toLowerCase();
    
    // Определяем категорию вопроса
    if (lowerQuestion.contains('полив') || lowerQuestion.contains('вода') || 
        lowerQuestion.contains('полит')) {
      return _formatAnswer('💧 ПОЛИВ ${guide.name.toUpperCase()}', guide.watering);
    }
    
    if (lowerQuestion.contains('свет') || lowerQuestion.contains('солнц') || 
        lowerQuestion.contains('освещен') || lowerQuestion.contains('куда поставить')) {
      return _formatAnswer('☀️ ОСВЕЩЕНИЕ ДЛЯ ${guide.name.toUpperCase()}', guide.light);
    }
    
    if (lowerQuestion.contains('температур') || lowerQuestion.contains('тепл') || 
        lowerQuestion.contains('холод') || lowerQuestion.contains('жара')) {
      return _formatAnswer('🌡️ ТЕМПЕРАТУРА ДЛЯ ${guide.name.toUpperCase()}', guide.temperature);
    }
    
    if (lowerQuestion.contains('почв') || lowerQuestion.contains('грунт') || 
        lowerQuestion.contains('земл')) {
      return _formatAnswer('🪴 ПОЧВА ДЛЯ ${guide.name.toUpperCase()}', guide.soil);
    }
    
    if (lowerQuestion.contains('удобр') || lowerQuestion.contains('подкорм') || 
        lowerQuestion.contains('питани') || lowerQuestion.contains('чем кормить')) {
      return _formatAnswer('🌿 УДОБРЕНИЕ ${guide.name.toUpperCase()}', guide.fertilization);
    }
    
    if (lowerQuestion.contains('влажн') || lowerQuestion.contains('опрыскиван')) {
      return _formatAnswer('💦 ВЛАЖНОСТЬ ДЛЯ ${guide.name.toUpperCase()}', guide.humidity);
    }
    
    if (lowerQuestion.contains('пересад') || lowerQuestion.contains('горшок')) {
      return _formatAnswer('🔄 ПЕРЕСАДКА ${guide.name.toUpperCase()}', guide.repotting);
    }
    
    if (lowerQuestion.contains('размнож') || lowerQuestion.contains('черенк')) {
      return _formatAnswer('🌱 РАЗМНОЖЕНИЕ ${guide.name.toUpperCase()}', guide.propagation);
    }
    
    if (lowerQuestion.contains('обрез') || lowerQuestion.contains('стриж')) {
      return _formatAnswer('✂️ ОБРЕЗКА ${guide.name.toUpperCase()}', guide.pruning);
    }
    
    if (lowerQuestion.contains('болезн') || lowerQuestion.contains('проблем') || 
        lowerQuestion.contains('вред') || lowerQuestion.contains('лечить')) {
      return _formatAnswer('⚠️ ПРОБЛЕМЫ ${guide.name.toUpperCase()}', guide.commonProblems);
    }
    
    if (lowerQuestion.contains('токсичн') || lowerQuestion.contains('опасн') || 
        lowerQuestion.contains('яд') || lowerQuestion.contains('безопасн')) {
      return _formatAnswer('🚫 ТОКСИЧНОСТЬ ${guide.name.toUpperCase()}', guide.toxicity);
    }
    
    if (lowerQuestion.contains('польз') || lowerQuestion.contains('преимущ')) {
      return _formatAnswer('✅ ПОЛЬЗА ${guide.name.toUpperCase()}', 
          '• ${guide.benefits.join('\n• ')}');
    }
    
    if (lowerQuestion.contains('совет') || lowerQuestion.contains('подсказ') || 
        lowerQuestion.contains('рекоменд')) {
      return _formatAnswer('💡 СОВЕТЫ ПО ${guide.name.toUpperCase()}', 
          '• ${guide.tips.join('\n• ')}');
    }
    
    if (lowerQuestion.contains('описан') || lowerQuestion.contains('что такое') || 
        lowerQuestion.contains('информац')) {
      return _formatGeneralGuide(guide);
    }
    
    // Если вопрос общий или "всё"
    if (lowerQuestion.contains('все') || lowerQuestion.contains('всё') || 
        lowerQuestion.contains('полн') || lowerQuestion.contains('общ')) {
      return _formatGeneralGuide(guide);
    }
    
    // Если не распознали вопрос
    return '''
🤖 **ПОМОЩНИК ПО УХОДУ ЗА ${guide.name.toUpperCase()}**

Я не совсем понял ваш вопрос о "${question}".

💡 **ЗАДАЙТЕ ВОПРОС О:**
• Поливе
• Освещении  
• Температуре
• Удобрении
• Пересадке
• Проблемах
• Или напишите "всё" для полного руководства

${_formatAnswer('📋 КРАТКО О ${guide.name.toUpperCase()}', guide.description)}''';
  }

  static String _formatAnswer(String title, String content) {
    return '''
🤖 **$title**

$content

💡 **Совет:** Каждое растение уникально, наблюдайте за его реакцией на уход.''';
  }

  static String _formatGeneralGuide(PlantCareGuide guide) {
    return '''
🌿 **${guide.name.toUpperCase()}** (${guide.scientificName})

${guide.description}

📋 **ОСНОВНОЙ УХОД:**

${guide.light}

${guide.temperature}

${guide.watering}

${guide.humidity}

🌱 **ДОПОЛНИТЕЛЬНО:**

${guide.soil}

${guide.fertilization}

${guide.repotting}

${guide.propagation}

${guide.pruning}

⚠️ **ВНИМАНИЕ:** ${guide.toxicity}

${guide.commonProblems}

✅ **ПОЛЬЗА РАСТЕНИЯ:**
• ${guide.benefits.join('\n• ')}

💡 **ПОЛЕЗНЫЕ СОВЕТЫ:**
• ${guide.tips.join('\n• ')}

🏷️ **ИНФОРМАЦИЯ:** ${guide.family}, ${guide.origin}, Сложность: ${guide.difficulty}
''';
  }

  static String _getGeneralAdvice(String plantName, String question) {
    final lowerQuestion = question.toLowerCase();
    
    if (lowerQuestion.contains('полив') || lowerQuestion.contains('вода')) {
      return '''
💧 **ОБЩИЙ СОВЕТ ПО ПОЛИВУ РАСТЕНИЙ:**

• Поливайте ${plantName}, когда верхний слой почвы (2-3 см) просохнет
• Используйте отстоявшуюся воду комнатной температуры
• Лучше поливать утром
• Избегайте перелива - это основная причина гибели растений
• Зимой полив сокращайте на 50-70%

💡 **ПРАВИЛО:** Лучше недолить, чем перелить. Большинство растений легче переносят засуху, чем переувлажнение.''';
    }
    
    if (lowerQuestion.contains('свет') || lowerQuestion.contains('солнц')) {
      return '''
☀️ **ОБЩИЙ СОВЕТ ПО ОСВЕЩЕНИЮ:**

• Большинство растений любят яркий рассеянный свет
• Южные окна: кактусы, суккуленты, герань
• Восточные/западные окна: большинство комнатных растений
• Северные окна: теневыносливые растения (папоротники, сансевиерия)
• Избегайте прямых солнечных лучей для растений с нежными листьями

💡 **ПРИЗНАКИ:** Бледные листья - мало света, ожоги на листьях - слишком много солнца.''';
    }
    
    if (lowerQuestion.contains('температур') || lowerQuestion.contains('тепл')) {
      return '''
🌡️ **ОБЩАЯ ТЕМПЕРАТУРА ДЛЯ РАСТЕНИЙ:**

• Идеальная температура: 18-25°C
• Минимум для тропических растений: 16°C
• Минимум для выносливых растений: 10°C
• Избегайте резких перепадов температуры и сквозняков
• Зимой держите растения подальше от батарей и холодных окон

💡 **ВАЖНО:** Большинство растений зимой нуждаются в периоде покоя с пониженной температурой.''';
    }
    
    if (lowerQuestion.contains('удобр') || lowerQuestion.contains('подкорм')) {
      return '''
🌿 **ОБЩИЕ ПРАВИЛА УДОБРЕНИЯ:**

• Удобряйте только в период активного роста (весна-лето)
• Зимой большинство растений не удобряют
• Используйте специальные удобрения для каждого типа растений
• Разводите удобрения согласно инструкции
• Не удобряйте больные, только пересаженные или отдыхающие растения

💡 **ПРАВИЛО:** Лучше недокормить, чем перекормить. Избыток удобрений вреднее их недостатка.''';
    }
    
    // Общий ответ для неизвестного растения
    return '''
🤖 **ПОМОЩНИК ПО УХОДУ ЗА РАСТЕНИЯМИ**

К сожалению, ${plantName} пока нет в нашей базе знаний.

💡 **ОБЩИЕ РЕКОМЕНДАЦИИ ДЛЯ КОМНАТНЫХ РАСТЕНИЙ:**

1. **ПОЛИВ:** Когда верхний слой почвы подсохнет
2. **СВЕТ:** Яркий рассеянный для большинства растений
3. **ТЕМПЕРАТУРА:** 18-25°C, избегайте сквозняков
4. **ВЛАЖНОСТЬ:** Опрыскивайте при сухом воздухе
5. **УДОБРЕНИЕ:** Весной-летом раз в 2-3 недели

⚠️ **ВАЖНО:** Наблюдайте за растением - оно само подскажет, что ему нужно!

🌿 **НАШИ РАСТЕНИЯ:** Монстера, Фикус, Замиокулькас, Сансевиерия, Хлорофитум, Крассула, Спатифиллум, Алоэ, Антуриум, Герань, Бегония, Драцена, Шеффлера, Фиалка, Кактус, Плющ

Мы постоянно расширяем нашу базу знаний!''';
  }
}