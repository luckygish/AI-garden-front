import 'package:flutter/material.dart';
import '../models/user.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
    'Теплица',
    'Балкон',
    'Подоконник'
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name ?? '';
    _selectedRegion = widget.user.region;
    _selectedGardenType = widget.user.gardenType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование профиля'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ваше имя',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: const InputDecoration(
                  labelText: 'Регион',
                  border: OutlineInputBorder(),
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
                  labelText: 'Тип участка',
                  border: OutlineInputBorder(),
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

              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Сохранить изменения'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Здесь сохраняем изменения профиля
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль успешно обновлен!')),
      );
    }
  }
}