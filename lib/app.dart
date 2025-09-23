import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/auth_screen.dart';
import 'models/user.dart';
import 'api/api_service.dart';
import 'api/shared_prefs_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  User? _currentUser;
  bool _initialized = false;
  bool _authenticated = false;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await ApiService.initialize();
    final token = await SharedPrefsService.getAuthToken();
    final userData = await SharedPrefsService.getUserData();
    final onboardingCompleted = await SharedPrefsService.isOnboardingCompleted();
    
    setState(() {
      _authenticated = token != null;
      _currentUser = userData; // Восстанавливаем данные пользователя
      _onboardingCompleted = onboardingCompleted;
      _initialized = true;
    });
  }

  void _onAuthenticated(User user) async {
    // Сохраняем данные пользователя
    await SharedPrefsService.saveUserData(user);
    
    setState(() {
      _currentUser = user;
      _authenticated = true;
    });
  }

  void _onOnboardingCompleted() async {
    await SharedPrefsService.setOnboardingCompleted();
    setState(() {
      _onboardingCompleted = true;
    });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    await SharedPrefsService.clearAuthData();
    setState(() {
      _currentUser = null;
      _authenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_authenticated) {
      return MainNavigationScreen(
        user: _currentUser ?? User(id: '', name: null, region: '', gardenType: ''),
        onLogout: _logout,
      );
    }

    // Если онбординг не завершен, показываем его
    if (!_onboardingCompleted) {
      return OnboardingScreen(onCompleted: _onOnboardingCompleted);
    }

    // После онбординга показываем экран аутентификации
    return AuthScreen(onAuthenticated: _onAuthenticated);
  }
}