import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/plant.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Название растения
              _buildSectionTitle('Название растения'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hintText: 'Например, Томат',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название растения';
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
                hintText: 'Например, Черри Блоссом',
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
        onPressed: _savePlant,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
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

  void _savePlant() {
    if (_formKey.currentState!.validate() && _plantingDate != null) {
      // Здесь сохраняем растение
      final plant = Plant(
        id: widget.plant?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        variety: _varietyController.text.isNotEmpty ? _varietyController.text : null,
        description: widget.plant?.description ?? 'Описание растения',
        plantingDate: _plantingDate!,
        growthStage: _selectedGrowthStage ?? 'Взрослое растение',
        imageUrl: widget.plant?.imageUrl ?? 'https://via.placeholder.com/150?text=Plant',
        category: '',
      );

      Navigator.pop(context, plant);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.plant != null
              ? 'Растение обновлено!'
              : 'Растение добавлено в ваш сад!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (_plantingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, выберите дату посадки'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}