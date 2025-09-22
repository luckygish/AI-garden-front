import 'package:flutter/material.dart';
import '../models/user.dart';

class RegistrationScreen extends StatefulWidget {
  final Function(User) onComplete;

  const RegistrationScreen({super.key, required this.onComplete});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedRegion;
  String? _selectedGardenType;

  final List<String> _regions = [
    'Центральный',
    'Северо-Западный',
    'Южный',
    'Северо-Кавказский',
    'Приволжский',
    'Уральский',
    'Сибирский',
    'Дальневосточный'
  ];

  final List<String> _gardenTypes = [
    'Открытый грунт',
    'Теплица'

  ];

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Регистрация'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ваше имя',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: const InputDecoration(
                  labelText: 'Выберите ваш регион *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: _regions.map((String region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedRegion = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Пожалуйста, выберите регион';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedGardenType,
                decoration: const InputDecoration(
                  labelText: 'Тип участка *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: _gardenTypes.map((String type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedGardenType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Пожалуйста, выберите тип участка';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.green.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Сохранить',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Имитация задержки для сохранения в БД
      await Future.delayed(const Duration(milliseconds: 500));

      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        region: _selectedRegion!,
        gardenType: _selectedGardenType!,
      );

      // Сохраняем пользователя (здесь будет логика сохранения в БД)
      _saveUserToDatabase(user);

      // Вызываем колбэк для завершения онбординга
      widget.onComplete(user);

      // Закрываем экран регистрации и возвращаемся к основному потоку
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveUserToDatabase(User user) {
    // Здесь будет реальная логика сохранения в базу данных
    print('Сохранение пользователя в БД: ${user.toJson()}');
  }
}

// Добавляем метод toJson в модель User
extension UserExtensions on User {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'gardenType': gardenType,
      'notificationsEnabled': notificationsEnabled,
    };
  }
}