import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/user.dart';

class AuthScreen extends StatefulWidget {
  final Function(User) onAuthenticated;

  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход / Регистрация'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Войти'),
            Tab(text: 'Регистрация'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LoginTab(onSuccess: widget.onAuthenticated),
          _RegisterTab(onSuccess: widget.onAuthenticated),
        ],
      ),
    );
  }
}

class _LoginTab extends StatefulWidget {
  final Function(User) onSuccess;
  const _LoginTab({required this.onSuccess});

  @override
  State<_LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<_LoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.isEmpty) ? 'Введите email' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Пароль (ровно 6 символов)'),
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Введите пароль';
                if (v.length != 6) return 'Длина ровно 6';
                final hasLetter = v.contains(RegExp(r'[A-Za-zА-Яа-я]'));
                final hasDigit = v.contains(RegExp(r'\d'));
                if (!hasLetter || !hasDigit) return 'Пароль: буквы и цифры';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Войти'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final user = User(
        id: (res['userId'] ?? '').toString(),
        name: res['name'] as String?,
        region: (res['region'] ?? '').toString(),
        gardenType: (res['gardenType'] ?? '').toString(),
      );
      if (!mounted) return;
      widget.onSuccess(user);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _RegisterTab extends StatefulWidget {
  final Function(User) onSuccess;
  const _RegisterTab({required this.onSuccess});

  @override
  State<_RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<_RegisterTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _region;
  String? _gardenType;
  bool _loading = false;

  final _regions = const [
    'Московская область',
    'Центральный',
    'Северо-Западный',
    'Южный',
    'Северо-Кавказский',
    'Приволжский',
    'Уральский',
    'Сибирский',
    'Дальневосточный',
  ];

  final _gardenTypes = const [
    'Открытый грунт',
    'Теплица',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.isEmpty) ? 'Введите email' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Имя'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _region,
              items: _regions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              decoration: const InputDecoration(labelText: 'Регион'),
              validator: (v) => v == null ? 'Выберите регион' : null,
              onChanged: (v) => setState(() => _region = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _gardenType,
              items: _gardenTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              decoration: const InputDecoration(labelText: 'Тип участка'),
              validator: (v) => v == null ? 'Выберите тип участка' : null,
              onChanged: (v) => setState(() => _gardenType = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Пароль (ровно 6 символов)'),
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Введите пароль';
                if (v.length != 6) return 'Длина ровно 6';
                final hasLetter = v.contains(RegExp(r'[A-Za-zА-Яа-я]'));
                final hasDigit = v.contains(RegExp(r'\d'));
                if (!hasLetter || !hasDigit) return 'Пароль: буквы и цифры';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Зарегистрироваться'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        region: _region!,
        gardenType: _gardenType!,
      );
      final user = User(
        id: (res['userId'] ?? '').toString(),
        name: res['name'] as String?,
        region: (res['region'] ?? '').toString(),
        gardenType: (res['gardenType'] ?? '').toString(),
      );
      if (!mounted) return;
      widget.onSuccess(user);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка регистрации: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
