import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/plant.dart';
import '../api/api_service.dart';
import '../widgets/plant_creation_loader.dart';
import '../services/pending_plants_service.dart';

class AddPlantScreen extends StatefulWidget {
  final Plant? plant;
  final User user;

  const AddPlantScreen({super.key, required this.user, this.plant});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _varietyController = TextEditingController();
  DateTime? _plantingDate;
  String? _selectedGrowthStage;

  bool _submitting = false;

  final List<String> _growthStages = [
    'Семя',
    'Росток',
    'Саженец',
    'Взрослое растение',
    'Цветение',
    'Плодоношение'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.plant != null) {
      _nameController.text = widget.plant!.name;
      _varietyController.text = widget.plant!.variety ?? '';
      _plantingDate = widget.plant!.plantingDate;
      _selectedGrowthStage = widget.plant!.growthStage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.plant != null ? 'Редактировать растение' : 'Добавить новое растение',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxHeight < 600;
            final padding = isSmallScreen ? 16.0 : 20.0;
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isSmallScreen ? 8 : 20),

                    // Название/культура растения
                    _buildSectionTitle('Культура (название растения)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Например, Огурец',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите название культуры';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Сорт
                    _buildSectionTitle('Сорт (необязательно)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _varietyController,
                      hintText: 'Например, Зозуля',
                    ),
                    const SizedBox(height: 24),

                    // Дата посадки
                    _buildSectionTitle('Дата посадки/посева'),
                    const SizedBox(height: 8),
                    _buildDateField(),
                    const SizedBox(height: 24),

                    // Стадия роста
                    _buildSectionTitle('Стадия роста (необязательно)'),
                    const SizedBox(height: 8),
                    _buildGrowthStageField(),
                    const SizedBox(height: 40),

                    // Кнопка сохранения
                    _buildSaveButton(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(fontSize: 16),
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _plantingDate != null
                  ? '${_plantingDate!.day}.${_plantingDate!.month}.${_plantingDate!.year}'
                  : 'Выберите дату',
              style: TextStyle(
                fontSize: 16,
                color: _plantingDate != null ? Colors.black : Colors.grey,
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthStageField() {
    return GestureDetector(
      onTap: _showGrowthStagePicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedGrowthStage ?? 'Выберите стадию',
              style: TextStyle(
                fontSize: 16,
                color: _selectedGrowthStage != null ? Colors.black : Colors.grey,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitting ? null : _savePlant,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _submitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Сохранить растение',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _plantingDate) {
      setState(() {
        _plantingDate = picked;
      });
    }
  }

  void _showGrowthStagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Выберите стадию роста',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._growthStages.map((stage) => ListTile(
                    title: Text(stage),
                    onTap: () {
                      setState(() {
                        _selectedGrowthStage = stage;
                      });
                      Navigator.pop(context);
                    },
                  )).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate() || _plantingDate == null) {
      if (_plantingDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пожалуйста, выберите дату посадки'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Дополнительная валидация
    if (_selectedGrowthStage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, выберите стадию роста'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Проверка на будущую дату
    if (_plantingDate!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дата посадки не может быть в будущем'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    
    // Показываем лоадер с настройками времени
    PlantCreationLoaderUtils.show(
      context: context,
      plantName: _nameController.text.trim(),
      minDisplayTime: const Duration(seconds: 3), // Минимум 3 секунды
      maxDisplayTime: const Duration(minutes: 2), // Максимум 2 минуты
      onCancel: () {
        setState(() => _submitting = false);
        Navigator.of(context).pop(); // Закрываем лоадер
      },
    );

    // Маппинг синонимов для корректного поиска плана ухода
    String culture = _nameController.text.trim();
    culture = _mapCultureToCanonical(culture);

    try {
      
      // Обновляем прогресс
      PlantCreationLoaderUtils.updateProgress(0.1, 'Проверяем базу данных...');
      
      // Добавляем промежуточные обновления прогресса
      PlantCreationLoaderUtils.updateProgress(0.2, 'Подготавливаем данные...');
      
      // Выполняем запрос с повторными попытками
      final created = await _addPlantWithRetry(
        culture: culture,
        name: _nameController.text.trim(),
        variety: _varietyController.text.trim().isNotEmpty ? _varietyController.text.trim() : null,
        plantingDate: _plantingDate!,
        growthStage: _selectedGrowthStage,
      );

      // Обновляем прогресс после успешного сохранения
      PlantCreationLoaderUtils.updateProgress(0.9, 'Сохраняем в базу данных...');
      PlantCreationLoaderUtils.updateProgress(1.0, 'Растение успешно добавлено!');

      // Собираем локальную модель для UI, используя id с бэкенда
      final plant = Plant(
        id: (created['id'] ?? created['plantId'] ?? DateTime.now().millisecondsSinceEpoch.toString()).toString(),
        name: _nameController.text.trim(),
        variety: _varietyController.text.trim().isNotEmpty ? _varietyController.text.trim() : null,
        description: widget.plant?.description ?? 'Описание растения',
        plantingDate: _plantingDate!,
        growthStage: _selectedGrowthStage ?? 'Взрослое растение',
        imageUrl: widget.plant?.imageUrl ?? 'lib/assets/images/plant_placeholder.svg',
        category: '',
        culture: culture, // Передаем каноническое название культуры
      );

      if (!mounted) return;
      
      // Ждем пока лоадер можно будет закрыть
      while (!PlantCreationLoaderUtils.canClose) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Закрываем лоадер
      PlantCreationLoaderUtils.hide(context);
      
      Navigator.pop(context, plant);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.plant != null ? 'Растение обновлено!' : 'Растение добавлено в ваш сад!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      String errorMessage = 'Произошла ошибка при добавлении растения';
      
      // Более детальная обработка ошибок
      if (e.toString().contains('План ухода не найден')) {
        errorMessage = 'План ухода для данной культуры не найден. Попробуйте другое название растения.';
      } else if (e.toString().contains('timeout') || e.toString().contains('TimeoutException') || e.toString().contains('Таймаут')) {
        errorMessage = 'Запрос в работе, растение скоро появится в вашем саду';
        // Добавляем растение в список ожидающих
        await _addToPendingPlants(culture, _nameController.text.trim());
      } else if (e.toString().contains('Не удалось добавить растение после')) {
        errorMessage = 'Запрос в работе, растение скоро появится в вашем саду';
        // Добавляем растение в список ожидающих
        await _addToPendingPlants(culture, _nameController.text.trim());
      } else if (e.toString().contains('Connection') || e.toString().contains('Ошибка подключения')) {
        errorMessage = 'Проблема с подключением к серверу. Проверьте интернет-соединение.';
      } else if (e.toString().contains('500') || e.toString().contains('Internal Server Error')) {
        errorMessage = 'Ошибка сервера. Возможно, проблема с DeepSeek API';
      } else if (e.toString().contains('DeepSeek')) {
        errorMessage = 'Ошибка при обращении к DeepSeek API. Попробуйте позже';
      } else if (e.toString().contains('Сессия истекла')) {
        errorMessage = 'Сессия истекла. Пожалуйста, войдите в систему заново.';
      } else if (e.toString().contains('Культура не может быть пустой')) {
        errorMessage = 'Пожалуйста, введите название растения.';
      } else if (e.toString().contains('Дата посадки обязательна')) {
        errorMessage = 'Пожалуйста, выберите дату посадки.';
      } else if (e.toString().contains('Стадия роста не может быть пустой')) {
        errorMessage = 'Пожалуйста, выберите стадию роста.';
      }
      
      if (mounted) {
        // Обновляем прогресс при ошибке
        PlantCreationLoaderUtils.updateProgress(0.0, 'Произошла ошибка: $errorMessage');
        
        // Ждем минимальное время перед закрытием
        await Future.delayed(const Duration(seconds: 2));
        
        // Закрываем лоадер при ошибке
        PlantCreationLoaderUtils.hide(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: errorMessage.contains('Запрос в работе') ? Colors.green : Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Повторить',
              textColor: Colors.white,
              onPressed: () {
                _savePlant();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // Маппинг синонимов на канонические названия культур
  String _mapCultureToCanonical(String input) {
    final cultureMap = {
      'томат': 'Помидор',
      'томаты': 'Помидор',
      'помидоры': 'Помидор',
      'помидор': 'Помидор',
      'огурец': 'Огурец',
      'огурцы': 'Огурец',
      'перец': 'Перец',
      'перцы': 'Перец',
      'баклажан': 'Баклажан',
      'баклажаны': 'Баклажан',
      'капуста': 'Капуста',
      'морковь': 'Морковь',
      'свекла': 'Свекла',
      'свёкла': 'Свекла',
      'лук': 'Лук',
      'чеснок': 'Чеснок',
      'картофель': 'Картофель',
      'картошка': 'Картофель',
      'редис': 'Редис',
      'редиска': 'Редис',
      'салат': 'Салат',
      'укроп': 'Укроп',
      'петрушка': 'Петрушка',
      'базилик': 'Базилик',
      'мята': 'Мята',
      'розмарин': 'Розмарин',
      'тимьян': 'Тимьян',
      'шпинат': 'Шпинат',
      'руккола': 'Руккола',
      'клубника': 'Клубника',
      'земляника': 'Клубника',
      'малина': 'Малина',
      'смородина': 'Смородина',
      'крыжовник': 'Крыжовник',
      'виноград': 'Виноград',
      'яблоня': 'Яблоня',
      'груша': 'Груша',
      'слива': 'Слива',
      'вишня': 'Вишня',
      'черешня': 'Черешня',
    };
    
    String normalized = input.toLowerCase().trim();
    return cultureMap[normalized] ?? input; // Возвращаем каноническое название или исходное
  }

  /// Выполняет добавление растения с повторными попытками при ошибках
  Future<Map<String, dynamic>> _addPlantWithRetry({
    required String culture,
    required String name,
    String? variety,
    required DateTime plantingDate,
    String? growthStage,
  }) async {
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 5);
    
    Exception? lastException;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Обновляем прогресс с информацией о попытке
        if (attempt > 1) {
          PlantCreationLoaderUtils.updateProgress(
            0.3 + (attempt - 1) * 0.1, 
            'ИИ-модель работает медленно. Продолжаем обработку...'
          );
        } else {
          PlantCreationLoaderUtils.updateProgress(0.3, 'Обращаемся к ИИ-модели...');
        }
        
        // Выполняем запрос
        final result = await ApiService.addPlant(
          culture: culture,
          name: name,
          variety: variety,
          plantingDate: plantingDate,
          growthStage: growthStage,
        );
        
        // Если успешно, возвращаем результат
        return result;
        
      } catch (e) {
        lastException = e as Exception;
        
        // Проверяем, стоит ли повторять попытку
        bool shouldRetry = _shouldRetry(e);
        
        if (attempt < maxRetries && shouldRetry) {
          // Обновляем прогресс с информацией о повторной попытке
          PlantCreationLoaderUtils.updateProgress(
            0.2 + attempt * 0.1,
            'ИИ-модель работает медленно. Продолжаем обработку...'
          );
          
          // Ждем перед следующей попыткой
          await Future.delayed(retryDelay);
        } else {
          // Если это последняя попытка или не стоит повторять, выбрасываем исключение
          break;
        }
      }
    }
    
    // Если все попытки неудачны, выбрасываем последнее исключение
    throw lastException ?? Exception('Не удалось добавить растение после $maxRetries попыток');
  }

  /// Определяет, стоит ли повторять попытку при данной ошибке
  bool _shouldRetry(Exception e) {
    final errorString = e.toString().toLowerCase();
    
    // Повторяем при ошибках, связанных с перегрузкой или временными проблемами
    return errorString.contains('timeout') ||
           errorString.contains('таймаут') ||
           errorString.contains('connection') ||
           errorString.contains('подключение') ||
           errorString.contains('500') ||
           errorString.contains('503') ||
           errorString.contains('502') ||
           errorString.contains('504') ||
           errorString.contains('deepseek') ||
           errorString.contains('перегружен') ||
           errorString.contains('overloaded') ||
           errorString.contains('rate limit') ||
           errorString.contains('too many requests');
  }

  /// Добавляет растение в список ожидающих
  Future<void> _addToPendingPlants(String culture, String plantName) async {
    try {
      // Генерируем временный ID для отслеживания
      final tempPlantId = 'temp_${DateTime.now().millisecondsSinceEpoch}_${plantName.hashCode}';
      
      await PendingPlantsService.addPendingPlant(
        plantId: tempPlantId,
        plantName: plantName,
        culture: culture,
      );
    } catch (e) {
      // Игнорируем ошибки при добавлении в список ожидающих
      print('Ошибка добавления в список ожидающих: $e');
    }
  }
}