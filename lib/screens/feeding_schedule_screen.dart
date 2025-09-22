import 'package:flutter/material.dart';
import '../models/plant.dart';

class FeedingScheduleScreen extends StatelessWidget {
  final Plant plant;

  const FeedingScheduleScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'График подкормок',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название растения
            Text(
              plant.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Описание
            const Text(
              'График является ориентировочным и может корректироваться в зависимости от фактических условий и потребностей растения.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Таблица
            _buildScheduleTable(),
            const SizedBox(height: 24),

            // Разделитель
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),

            // Кнопка возврата к рекомендациям
            const SizedBox(height: 24),
            _buildBackToCareGuideButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Table(
        border: TableBorder.all(
          color: const Color(0xFFEEEEEE),
          width: 1,
        ),
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1.3),
        },
        children: [
          // Заголовок таблицы
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
            ),
            children: [
              _buildTableHeader('СРОК / ФЕНОФАЗА'),
              _buildTableHeader('УДОБРЕНИЕ /ПРЕПАРАТ'),
              _buildTableHeader('СПОСОБ ВНЕСЕНИЯ'),
            ],
          ),
          // Данные таблицы
          _buildTableRow(
            'Апрель\nНачало вегетации',
            'Азофоска\n15:15:15 (N:P:K)',
            'Корневая подкормка',
          ),
          _buildTableRow(
            'Май\nБутонизация',
            'Калимагнезия\nКалий, Магний',
            'Внекорневая подкормка',
          ),
          _buildTableRow(
            'Июнь\nАктивное цветение',
            'Комплексное удобрение\nДля роз, с микроэлементами',
            'Корневая подкормка',
          ),
          _buildTableRow(
            'Июль\nПовторное цветение',
            'Суперфосфат\nФосфор',
            'Гранулированное внесение',
          ),
          _buildTableRow(
            'Август\nПодготовка к осени',
            'Монофосфат калия\nКалий, Фосфор',
            'Полив',
          ),
          _buildTableRow(
            'Сентябрь\nОкончание вегетации',
            'Зола древесная\nКалий, Микроэлементы',
            'Поверхностное внесение',
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildTableRow(String period, String fertilizer, String method) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      children: [
        _buildTableCell(period, isPeriod: true),
        _buildTableCell(fertilizer),
        _buildTableCell(method),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isPeriod = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isPeriod ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBackToCareGuideButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // Возврат на два экрана назад (через график обратно к рекомендациям)
          Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green,
          side: const BorderSide(color: Colors.green),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('Вернуться к рекомендациям по уходу'),
      ),
    );
  }
}