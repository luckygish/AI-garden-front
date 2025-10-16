import 'package:flutter/foundation.dart';

class AppConfig {
  // URL для разных окружений
  static const String _localUrl = 'http://10.0.2.2:8080/api'; // Для эмулятора Android
  static const String _networkUrl = 'http://192.168.31.70:8080/api'; // Для локальной сети
  static const String _cloudUrl = 'http://193.227.240.20:8080/api'; // Облачный сервер reg.ru
  static const String _productionUrl = 'http://193.227.240.20:8080/api'; // Облачный сервер для продакшена
  
  // Переменная для принудительного выбора URL (можно задать через переменные окружения)
  static const String? _forcedUrl = null; // Например: 'http://10.0.2.2:8080/api'
  
  // Текущий базовый URL
  static String get baseUrl {
    // Если принудительно задан URL, используем его
    if (_forcedUrl != null) {
      return _forcedUrl!;
    }
    
    if (kDebugMode) {
      // В режиме отладки используем локальный сервер для разработки
      return _localUrl;
    } else {
      // В релизе используем облачный сервер
      return _productionUrl;
    }
  }
  
  // Методы для ручного переключения URL
  static String getLocalUrl() => _localUrl;
  static String getNetworkUrl() => _networkUrl;
  static String getCloudUrl() => _cloudUrl;
  static String getProductionUrl() => _productionUrl;
  
  // Настройки таймаута
  static const Duration requestTimeout = Duration(minutes: 2);
  static const Duration connectionTimeout = Duration(seconds: 30);
  
  // Логирование
  static void logUrl() {
    if (kDebugMode) {
      print('🌐 API Base URL: $baseUrl');
      print('🔧 Debug Mode: $kDebugMode');
      print('📱 Platform: ${defaultTargetPlatform.name}');
    }
  }
  
  // Детальная информация о конфигурации
  static void logFullConfig() {
    if (kDebugMode) {
      print('=== APP CONFIG ===');
      print('🌐 Base URL: $baseUrl');
      print('🏠 Local URL: $_localUrl');
      print('🌍 Network URL: $_networkUrl');
      print('☁️ Cloud URL: $_cloudUrl');
      print('🚀 Production URL: $_productionUrl');
      print('🔧 Debug Mode: $kDebugMode');
      print('📱 Platform: ${defaultTargetPlatform.name}');
      print('⏱️ Request Timeout: ${requestTimeout.inSeconds}s');
      print('🔌 Connection Timeout: ${connectionTimeout.inSeconds}s');
      if (_forcedUrl != null) {
        print('🔒 Forced URL: $_forcedUrl');
      }
      print('==================');
    }
  }
  
  // Информация о сервере
  static const String serverIp = '193.227.240.20';
  static const int serverPort = 8080;
  static const String serverUrl = 'http://193.227.240.20:8080';
  static const String localServerUrl = 'http://10.0.2.2:8080';
  static const String networkServerUrl = 'http://192.168.31.70:8080';
}
