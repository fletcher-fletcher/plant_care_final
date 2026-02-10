// lib/screens/care_guide_screen.dart - ПОЛНОСТЬЮ ИСПРАВЛЕННЫЙ
import 'package:flutter/material.dart';
import '../services/care_guide_service.dart';
import '../models/plant_care_guide.dart';

class CareGuideScreen extends StatefulWidget {
  final String plantType; // Используем plantType вместо plantName

  const CareGuideScreen({super.key, required this.plantType});

  @override
  State<CareGuideScreen> createState() => _CareGuideScreenState();
}

class _CareGuideScreenState extends State<CareGuideScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  PlantCareGuide? _plantGuide;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPlantGuide();
  }

  void _loadPlantGuide() {
    _plantGuide = CareGuideService.getCareGuide(widget.plantType); // Исправлено на plantType
    
    if (_plantGuide != null) {
      _addMessage('assistant', '''
🌿 **ДОБРО ПОЖАЛОВАТЬ В ГИД ПО УХОДУ ЗА ${widget.plantType.toUpperCase()}!**

Я помогу вам правильно ухаживать за вашим растением.

💡 **ЗАДАЙТЕ ВОПРОС О:**
• Поливе
• Освещении  
• Температуре
• Удобрении
• Пересадке
• Проблемах
• Или напишите "всё" для полного руководства

👇 **Используйте быстрые кнопки ниже**''');
    } else {
      _addMessage('assistant', '''
🤖 **ПОМОЩНИК ПО УХОДУ ЗА РАСТЕНИЯМИ**

${widget.plantType} пока нет в нашей базе, но я могу дать общие советы!

💡 **СПРОСИТЕ О:**
• Как поливать комнатные растения
• Какое нужно освещение  
• Оптимальная температура
• Как удобрять растения
• Признаки болезней растений

👇 **Используйте быстрые кнопки ниже**''');
    }
  }

  void _addMessage(String role, String text) {
    setState(() {
      _messages.add({
        'role': role,
        'text': text,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isEmpty || _isLoading) return;

    _controller.clear();
    _addMessage('user', message);

    setState(() => _isLoading = true);

    // Имитация задержки обработки
    Future.delayed(const Duration(milliseconds: 300), () {
      final response = CareGuideService.answerQuestion(widget.plantType, message); // Исправлено на plantType
      _addMessage('assistant', response);
      setState(() => _isLoading = false);
    });
  }

  void _showFullGuide() {
    if (_plantGuide == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _buildFullGuideSheet();
      },
    );
  }

  Widget _buildFullGuideSheet() {
    final guide = _plantGuide!;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Заголовок
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🌿 Полное руководство',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          const Divider(),
          
          // Содержимое
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Изображение и название растения
                  Center(
                    child: Column(
                      children: [
                        // Изображение растения
                        Container(
                          width: 140,
                          height: 140,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              guide.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Если изображение не загрузилось
                                return Container(
                                  color: Colors.green[100],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          '🌱',
                                          style: TextStyle(fontSize: 40),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          guide.name[0],
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        
                        // Название растения
                        Text(
                          guide.name,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          guide.scientificName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        
                        // Чипы с информацией
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            Chip(
                              label: Text(
                                guide.difficulty,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: _getDifficultyColor(guide.difficulty),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            Chip(
                              label: Text(
                                guide.family,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.green[50],
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            Chip(
                              label: Text(
                                guide.origin.split(',').first,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.blue[50],
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Основные разделы
                  _buildGuideSection('📖 Описание', guide.description),
                  _buildGuideSection('🌍 Происхождение', '${guide.family}, ${guide.origin}'),
                  _buildGuideSection('☀️ Освещение', guide.light),
                  _buildGuideSection('🌡️ Температура', guide.temperature),
                  _buildGuideSection('💧 Полив', guide.watering),
                  _buildGuideSection('💦 Влажность', guide.humidity),
                  _buildGuideSection('🪴 Почва', guide.soil),
                  _buildGuideSection('🌿 Удобрение', guide.fertilization),
                  _buildGuideSection('🔄 Пересадка', guide.repotting),
                  _buildGuideSection('🌱 Размножение', guide.propagation),
                  _buildGuideSection('✂️ Обрезка', guide.pruning),
                  
                  // Проблемы
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red[100]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.red[700], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Распространенные проблемы',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          guide.commonProblems,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  
                  // Токсичность
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange[100]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.dangerous, color: Colors.orange[700], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Токсичность',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          guide.toxicity,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  
                  // Польза
                  if (guide.benefits.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green[100]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.verified, color: Colors.green[700], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Польза растения',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: guide.benefits.map((benefit) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(fontSize: 16)),
                                  Expanded(
                                    child: Text(
                                      benefit,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Советы
                  if (guide.tips.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue[100]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb, color: Colors.blue[700], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Полезные советы',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: guide.tips.map((tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('💡 ', style: TextStyle(fontSize: 16)),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'очень легкая':
        return Colors.green[100]!;
      case 'легкая':
        return Colors.lightGreen[100]!;
      case 'средняя':
        return Colors.orange[100]!;
      case 'сложная':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Widget _buildGuideSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title.split(' ')[0], // Эмодзи
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.substring(2), // Текст без эмодзи
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📚 Гид по уходу: ${widget.plantType}'), // Исправлено на plantType
        backgroundColor: Colors.green[50],
        actions: [
          if (_plantGuide != null)
            IconButton(
              icon: const Icon(Icons.menu_book, color: Colors.green),
              onPressed: _showFullGuide,
              tooltip: 'Полное руководство',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: _plantGuide != null && index == 0
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      _plantGuide!.imageUrl,
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Text('🌿', style: TextStyle(fontSize: 16));
                                      },
                                    ),
                                  )
                                : const Text('🌿', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      
                      const SizedBox(width: 8),
                      
                      Expanded(
                        child: Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser ? Colors.green[50] : Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isUser ? Colors.green[100]! : Colors.blue[100]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                message['text'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      if (isUser) const SizedBox(width: 8),
                      
                      if (isUser)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Icon(Icons.person, size: 18, color: Colors.green),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Индикатор загрузки
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('🌿', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Ищу информацию...'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Нижняя панель
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                // Быстрые кнопки
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickButton('💧', 'Полив'),
                      _buildQuickButton('☀️', 'Свет'),
                      _buildQuickButton('🌡️', 'Температура'),
                      _buildQuickButton('🌿', 'Удобрение'),
                      _buildQuickButton('🔄', 'Пересадка'),
                      _buildQuickButton('⚠️', 'Проблемы'),
                      if (_plantGuide != null)
                        _buildQuickButton('📖', 'Всё'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Поле ввода
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Задайте вопрос о уходе...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            style: const TextStyle(fontSize: 15),
                            onSubmitted: (_) => _sendMessage(),
                            maxLines: 3,
                            minLines: 1,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _sendMessage,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String emoji, String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 1,
        child: InkWell(
          onTap: () {
            _controller.text = text.toLowerCase();
            _sendMessage();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}