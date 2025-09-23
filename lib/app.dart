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

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await ApiService.initialize();
    final token = await SharedPrefsService.getAuthToken();
    setState(() {
      _authenticated = token != null;
      _initialized = true;
    });
  }

  void _onAuthenticated(User user) {
    setState(() {
      _currentUser = user;
      _authenticated = true;
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

    // Показываем экран аутентификации (вместо онбординга, при необходимости можно цепочкой)
    return AuthScreen(onAuthenticated: _onAuthenticated);
  }
}