import 'package:flutter/material.dart';
import '../models/user.dart';
import '../api/api_service.dart';
import '../api/shared_prefs_service.dart';

class RegistrationScreen extends StatefulWidget {
  final Function(User) onComplete;

  const RegistrationScreen({super.key, required this.onComplete});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите email';
                  }
                  if (!value.contains('@')) {
                    return 'Введите корректный email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Пароль *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  if (value.length < 6) {
                    return 'Пароль должен быть не менее 6 символов';
                  }
                  return null;
                },
              ),
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
                initialValue: _selectedRegion,
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
                initialValue: _selectedGardenType,
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

      try {
        // Вызываем API для регистрации
        final res = await ApiService.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          region: _selectedRegion!,
          gardenType: _selectedGardenType!,
        );

        final user = User(
          id: (res['userId'] ?? '').toString(),
          name: res['name'] as String?,
          region: (res['region'] ?? '').toString(),
          gardenType: (res['gardenType'] ?? '').toString(),
        );

        // Сохраняем данные пользователя
        await SharedPrefsService.saveUserData(user);

        // Вызываем колбэк для завершения регистрации
        widget.onComplete(user);

        // Закрываем экран регистрации и возвращаемся к основному потоку
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка регистрации: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
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