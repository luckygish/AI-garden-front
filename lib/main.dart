import 'package:flutter/material.dart';
import 'api/api_service.dart';
import 'api/shared_prefs_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Загружаем сохраненный токен при запуске
  final savedToken = await SharedPrefsService.getAuthToken();
  if (savedToken != null) {
    ApiService.authToken = savedToken;
  }

  runApp(const GardenHelperApp());
}

class GardenHelperApp extends StatelessWidget {
  const GardenHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Садовый Помощник',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const App(),
      debugShowCheckedModeBanner: false,
    );
  }
}