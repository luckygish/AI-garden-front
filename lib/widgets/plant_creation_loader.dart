import 'package:flutter/material.dart';
import 'dart:async';

class PlantCreationLoader extends StatefulWidget {
  final String plantName;
  final VoidCallback? onCancel;
  final Function(double progress, String message)? onProgressUpdate;
  final Duration? minDisplayTime; // Минимальное время показа лоадера
  final Duration? maxDisplayTime; // Максимальное время показа лоадера

  const PlantCreationLoader({
    super.key,
    required this.plantName,
    this.onCancel,
    this.onProgressUpdate,
    this.minDisplayTime,
    this.maxDisplayTime,
  });

  @override
  State<PlantCreationLoader> createState() => _PlantCreationLoaderState();
}

class _PlantCreationLoaderState extends State<PlantCreationLoader>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  double _progress = 0.0;
  String _currentMessage = 'Инициализация...';
  Timer? _progressTimer;
  DateTime? _startTime;
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    
    // Записываем время начала
    _startTime = DateTime.now();
    
    // Регистрируем состояние для внешних обновлений
    PlantCreationLoaderUtils._currentLoaderState = this;
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 1), // Короткая анимация для плавности
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startLoading();
  }

  void _startLoading() {
    _pulseController.repeat(reverse: true);
    // Устанавливаем начальный прогресс
    updateProgress(0.0, 'Инициализация...');
    
    // Добавляем автоматические обновления для длительных операций
    _startProgressSimulation();
  }

  void _startProgressSimulation() {
    // Симулируем прогресс для длительных операций
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Если прогресс меньше 50%, показываем что ищем в источниках
      if (_progress < 0.5) {
        updateProgress(_progress + 0.05, 'В нашей базе недостаточно информации по растению, ищем в официальных источниках...');
      }
      // Если прогресс между 50% и 90%, показываем анализ
      else if (_progress < 0.9) {
        updateProgress(_progress + 0.03, 'Анализируем агротехнические данные...');
      }
      // Если прогресс больше 90%, показываем финальную обработку
      else if (_progress < 0.95) {
        updateProgress(_progress + 0.02, 'Формируем план ухода...');
      }
      
      // Останавливаем симуляцию если прогресс достиг 95%
      if (_progress >= 0.95) {
        timer.cancel();
      }
    });
  }

  void updateProgress(double progress, String message) {
    if (!mounted) return;
    
    setState(() {
      _progress = progress.clamp(0.0, 1.0);
      _currentMessage = message;
    });
    
    // Анимируем прогресс
    _progressController.animateTo(_progress);
    
    // Если прогресс достиг 100%, проверяем можно ли закрыть
    if (_progress >= 1.0) {
      _checkCanClose();
    }
  }

  void _checkCanClose() {
    if (_startTime == null) return;
    
    final elapsed = DateTime.now().difference(_startTime!);
    final minTime = widget.minDisplayTime ?? const Duration(seconds: 2);
    
    // Если прошло минимальное время, разрешаем закрытие
    if (elapsed >= minTime) {
      _canClose = true;
      // Уведомляем внешний код что можно закрыть
      widget.onProgressUpdate?.call(_progress, _currentMessage);
    } else {
      // Ждем минимальное время
      Timer(minTime - elapsed, () {
        if (mounted) {
          _canClose = true;
          widget.onProgressUpdate?.call(_progress, _currentMessage);
        }
      });
    }
  }

  bool get canClose => _canClose;

  @override
  void dispose() {
    // Очищаем регистрацию состояния
    PlantCreationLoaderUtils._currentLoaderState = null;
    
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Иконка растения с анимацией
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      size: 40,
                      color: Colors.green,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Название растения
            Text(
              widget.plantName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Прогресс бар
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Процент выполнения
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Text(
                  '${(_progress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Текущее сообщение
            Text(
              _currentMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Кнопка отмены
            if (widget.onCancel != null)
              TextButton(
                onPressed: widget.onCancel,
                child: const Text(
                  'Закрыть',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Утилитарный класс для показа лоадера
class PlantCreationLoaderUtils {
  static _PlantCreationLoaderState? _currentLoaderState;
  
  static void show({
    required BuildContext context,
    required String plantName,
    VoidCallback? onCancel,
    Function(double progress, String message)? onProgressUpdate,
    Duration? minDisplayTime,
    Duration? maxDisplayTime,
  }) {
    final loader = PlantCreationLoader(
      plantName: plantName,
      onCancel: onCancel,
      onProgressUpdate: onProgressUpdate,
      minDisplayTime: minDisplayTime,
      maxDisplayTime: maxDisplayTime,
    );
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => loader,
    );
  }

  static void updateProgress(double progress, String message) {
    if (_currentLoaderState != null) {
      _currentLoaderState!.updateProgress(progress, message);
    }
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
    _currentLoaderState = null;
  }

  static bool get canClose => _currentLoaderState?.canClose ?? false;
}
