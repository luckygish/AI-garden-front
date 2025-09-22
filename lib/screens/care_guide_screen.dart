import 'package:flutter/material.dart';
import '../models/care_event.dart';

class CareGuideScreen extends StatefulWidget {
  final CareEvent event;

  const CareGuideScreen({super.key, required this.event});

  @override
  State<CareGuideScreen> createState() => _CareGuideScreenState();
}

class _CareGuideScreenState extends State<CareGuideScreen> {
  bool _mineralExpanded = true;
  bool _organicExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Подробнее об уходе',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок мероприятия
            _buildEventTitle(),
            const SizedBox(height: 20),

            // Причины и назначение
            _buildReasonsSection(),
            const SizedBox(height: 24),

            // Варианты ухода
            _buildCareOptions(context),
            const SizedBox(height: 24),

            // Отдельный блок с предложением покупки
            _buildPartnerProductCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTitle() {
    return Text(
      widget.event.title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildReasonsSection() {
    return Card(
      elevation: 0,
      color: const Color(0xFFF8F9FA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Причины/Назначение',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.event.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Сроки:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Май - Июль',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Минеральные удобрения - раскрывающаяся секция
        _buildExpandableSection(
          title: 'Минеральные удобрения',
          isExpanded: _mineralExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _mineralExpanded = expanded;
              if (expanded) _organicExpanded = false;
            });
          },
          content: Column(
            children: [
              _buildFertilizerCard(
                context: context,
                title: 'Мастер Азот+',
                dosage: '10 г на 5 л воды',
                instructions: 'Применять раз в 14 дней утром или вечером, избегая прямого солнечного света. Опрыскивать листья до полного смачивания.',
                price: null,
                showAnalogButton: true,
              ),
              const SizedBox(height: 16),
              _buildFertilizerCard(
                context: context,
                title: 'Калиевая Селитра',
                dosage: '5 г на 3 л воды',
                instructions: 'Использовать каждые 10 дней для стимуляции цветения. Хорошо растворить в теплой воде перед применением.',
                price: null,
                showAnalogButton: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Органические удобрения - раскрывающаяся секция
        _buildExpandableSection(
          title: 'Органические удобрения',
          isExpanded: _organicExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _organicExpanded = expanded;
              if (expanded) _mineralExpanded = false;
            });
          },
          content: Column(
            children: [
              _buildFertilizerCard(
                context: context,
                title: 'Биогумус',
                dosage: '100 г на 1 л воды',
                instructions: 'Натуральное органическое удобрение пролонгированного действия. Применять каждые 3-4 недели.',
                price: null,
                showAnalogButton: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerProductCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Специальное комплексное удобрение',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Натуральное органическое удобрение пролонгированного действия',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '500 ₽',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                ElevatedButton(
                  onPressed: _openPartnerWebsite,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Купить на сайте партнера'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required Function(bool) onExpansionChanged,
    required Widget content,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizerCard({
    required BuildContext context,
    required String title,
    required String dosage,
    required String instructions,
    required String? price,
    required bool showAnalogButton,
  }) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF8F9FA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и цена
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (price != null)
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Дозировка
            if (dosage.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Дозировка: $dosage',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),

            // Инструкции
            Text(
              instructions,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Кнопка аналогов
            if (showAnalogButton)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showAlternativesDialog(context, title);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Подробнее / Аналоги'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAlternativesDialog(BuildContext context, String productName) {
    final alternatives = {
      'Мастер Азот+': ['Азофоска', 'Нитроаммофоска', 'Аммиачная селитра'],
      'Калиевая Селитра': ['Калий сернокислый', 'Калимагнезия', 'Древесная зола'],
      'Биогумус': ['Компост', 'Перегной', 'Куриный помёт'],
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Аналоги для $productName'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: (alternatives[productName] ?? []).map((alternative) {
              return ListTile(
                title: Text(alternative),
                onTap: () {
                  Navigator.pop(context);
                  // Логика выбора аналога
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _openPartnerWebsite() {
    // Логика открытия сайта партнера
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Переход на сайт партнера...'),
        backgroundColor: Colors.green,
      ),
    );
  }
}