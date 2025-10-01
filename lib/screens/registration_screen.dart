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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Адаптивные отступы в зависимости от размера экрана
            final isSmallScreen = constraints.maxHeight < 600;
            final padding = isSmallScreen ? 16.0 : 20.0;
            final spacing = isSmallScreen ? 12.0 : 16.0;
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isSmallScreen ? 8 : 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: isSmallScreen ? 12 : 14,
                        ),
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
                    SizedBox(height: spacing),

                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Пароль *',
                        hintText: '8-12 символов, буквы A-z и цифры',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: isSmallScreen ? 12 : 14,
                        ),
                      ),
                      obscureText: true,
                      maxLength: 12,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }
                        if (value.length < 8) {
                          return 'Пароль должен содержать минимум 8 символов';
                        }
                        if (value.length > 12) {
                          return 'Пароль должен содержать максимум 12 символов';
                        }
                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return 'Пароль должен содержать хотя бы одну заглавную букву';
                        }
                        if (!RegExp(r'[a-z]').hasMatch(value)) {
                          return 'Пароль должен содержать хотя бы одну строчную букву';
                        }
                        if (!RegExp(r'\d').hasMatch(value)) {
                          return 'Пароль должен содержать хотя бы одну цифру';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: spacing),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Ваше имя',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ),
                    SizedBox(height: spacing),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedRegion,
                      decoration: InputDecoration(
                        labelText: 'Выберите ваш регион *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: isSmallScreen ? 12 : 14,
                        ),
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
                    SizedBox(height: spacing),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedGardenType,
                      decoration: InputDecoration(
                        labelText: 'Тип участка *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: isSmallScreen ? 12 : 14,
                        ),
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
                    SizedBox(height: isSmallScreen ? 20 : 24),

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
            );
          },
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