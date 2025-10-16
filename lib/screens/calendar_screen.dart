import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/care_event.dart';
import 'care_guide_screen.dart';

class CalendarScreen extends StatefulWidget {
  final User user;

  const CalendarScreen({super.key, required this.user});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<CareEvent> _allEvents = []; // Здесь будут события из базы

  List<CareEvent> get _selectedDateEvents {
    return _allEvents.where((event) {
      return event.date.year == _selectedDate.year &&
          event.date.month == _selectedDate.month &&
          event.date.day == _selectedDate.day;
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Календарь садовода',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.filter_list, color: Colors.black),
          //   onPressed: _showFilterDialog,
          // ),
        ],
      ),
      body: Column(
        children: [
          // Заголовок с месяцем и годом
          _buildMonthHeader(),
          const SizedBox(height: 16),

          // Сетка календаря
          _buildCalendarGrid(),
          const SizedBox(height: 24),

          // Задачи на выбранную дату
          _buildTasksSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateCalendar,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.autorenew),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black),
            onPressed: _previousMonth,
          ),
          Text(
            '${_getMonthName(_selectedDate.month)} ${_selectedDate.year} г.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.black),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final weekdayOffset = firstDayOfMonth.weekday - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Дни недели
          _buildWeekDays(),
          const SizedBox(height: 8),

          // Сетка чисел
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: 42, // 6 строк по 7 дней
            itemBuilder: (context, index) {
              final dayNumber = index - weekdayOffset + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final currentDate = DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
              final hasEvents = _allEvents.any((event) =>
              event.date.year == currentDate.year &&
                  event.date.month == currentDate.month &&
                  event.date.day == currentDate.day);
              final isSelected = _selectedDate.day == dayNumber;

              return _buildDayCell(dayNumber, hasEvents, isSelected, currentDate);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    const weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return Row(
      children: weekDays.map((day) {
        return Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(int day, bool hasEvents, bool isSelected, DateTime date) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            if (hasEvents)
              const Icon(Icons.circle, size: 6, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Задачи на ${_selectedDate.day} ${_getMonthName(_selectedDate.month)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _selectedDateEvents.isEmpty
                ? _buildEmptyTasks()
                : _buildTasksList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTasks() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'На этот день нет запланированных задач.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _generateCalendar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Сгенерировать/Обновить календарь'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _selectedDateEvents.length,
        itemBuilder: (context, index) {
          final event = _selectedDateEvents[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: _getEventIcon(event.title),
              title: Text(
                event.title,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                event.description,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CareGuideScreen(event: event),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Icon _getEventIcon(String title) {
    if (title.toLowerCase().contains('подкормка')) {
      return const Icon(Icons.eco, size: 20, color: Colors.green);
    } else if (title.toLowerCase().contains('обработка')) {
      return const Icon(Icons.medical_services, size: 20, color: Colors.blue);
    } else if (title.toLowerCase().contains('полив')) {
      return const Icon(Icons.water_drop, size: 20, color: Colors.blue);
    }
    return const Icon(Icons.calendar_today, size: 20);
  }

  String _getMonthName(int month) {
    const months = [
      'январь', 'февраль', 'март', 'апрель', 'май', 'июнь',
      'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь'
    ];
    return months[month - 1];
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
  }

  // void _showFilterDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Фильтр'),
  //       content: const Text('Выберите растения для отображения в календаре'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Отмена'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             // Здесь будет логика фильтрации
  //           },
  //           child: const Text('Применить'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _generateCalendar() {
    // Здесь будет логика генерации/обновления календаря
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Календарь обновлен'),
        backgroundColor: Colors.green,
      ),
    );
  }
}