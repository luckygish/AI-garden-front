import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../api/shared_prefs_service.dart';
import '../models/user.dart';
import 'registration_screen.dart';

class AuthScreen extends StatefulWidget {
  final Function(User) onAuthenticated;

  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _LoginTab(onSuccess: widget.onAuthenticated),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.isEmpty) ? 'Введите email' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              obscureText: true,
              validator: (v) => (v == null || v.isEmpty) ? 'Введите пароль' : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.green.withOpacity(0.5),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Войти',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Переход к экрану регистрации
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrationScreen(
                      onComplete: (user) {
                        // После регистрации возвращаемся к главному экрану
                        Navigator.pop(context);
                        widget.onSuccess(user);
                      },
                    ),
                  ),
                );
              },
              child: const Text(
                'Нет аккаунта? Зарегистрироваться',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                ),
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

      // Сохраняем данные пользователя
      await SharedPrefsService.saveUserData(user);

      if (!mounted) return;
      widget.onSuccess(user);
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'Ошибка входа';
      if (e.toString().contains('Invalid credentials')) {
        errorMessage = 'Неверный email или пароль';
      } else if (e.toString().contains('Сессия истекла')) {
        errorMessage = 'Сессия истекла. Пожалуйста, войдите снова';
      } else {
        errorMessage = 'Ошибка входа: $e';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

}