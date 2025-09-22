import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'models/user.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  User? _currentUser;
  bool _showOnboarding = true;

  void _completeOnboarding(User user) {
    setState(() {
      _currentUser = user;
      _showOnboarding = false;
    });

    // После сохранения пользователя сразу переходим к главному экрану
    if (!_showOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainNavigationScreen(user: _currentUser!, onLogout: _logout),
        ),
      );
    }
  }

  void _logout() {
    setState(() {
      _currentUser = null;
      _showOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    return MainNavigationScreen(user: _currentUser!, onLogout: _logout);
  }
}