import 'package:flutter/material.dart';
import '../models/user.dart';
import 'my_garden_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import '../services/plant_notification_service.dart';

class MainNavigationScreen extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;

  const MainNavigationScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      MyGardenScreen(user: widget.user),
      CalendarScreen(user: widget.user),
      ProfileScreen(user: widget.user, onLogout: widget.onLogout),
    ];
    
    // Запускаем проверку ожидающих растений
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PlantNotificationService.startPeriodicCheck(context);
    });
  }

  @override
  void dispose() {
    // Останавливаем проверку при закрытии экрана
    PlantNotificationService.stopPeriodicCheck();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Мой сад',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Календарь',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}