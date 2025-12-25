import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';

class BusinessHoursScreen extends StatefulWidget {
  const BusinessHoursScreen({super.key});

  @override
  State<BusinessHoursScreen> createState() => _BusinessHoursScreenState();
}

class _BusinessHoursScreenState extends State<BusinessHoursScreen> {
  Map<String, Map<String, dynamic>> _businessHours = {
    'monday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
    'tuesday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
    'wednesday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
    'thursday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
    'friday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
    'saturday': {'isOpen': true, 'open': '09:00', 'close': '18:00'},
    'sunday': {'isOpen': false, 'open': '09:00', 'close': '18:00'},
  };

  final Map<String, String> _dayNames = {
    'monday': '月曜日',
    'tuesday': '火曜日',
    'wednesday': '水曜日',
    'thursday': '木曜日',
    'friday': '金曜日',
    'saturday': '土曜日',
    'sunday': '日曜日',
  };

  @override
  void initState() {
    super.initState();
    _loadBusinessHours();
  }

  void _loadBusinessHours() {
    try {
      final hoursJson = html.window.localStorage['staff_business_hours'];
      if (hoursJson != null && hoursJson.isNotEmpty) {
        final hours = jsonDecode(hoursJson) as Map<String, dynamic>;
        setState(() {
          hours.forEach((day, data) {
            _businessHours[day] = Map<String, dynamic>.from(data);
          });
        });
      }
    } catch (e) {
      debugPrint('営業時間データの読み込みエラー: $e');
    }
  }

  void _saveBusinessHours() {
    try {
      html.window.localStorage['staff_business_hours'] = jsonEncode(_businessHours);

      // staff_profileにも追加
      final profileJson = html.window.localStorage['staff_profile'];
      if (profileJson != null) {
        final profile = jsonDecode(profileJson) as Map<String, dynamic>;
        profile['businessHours'] = _businessHours;
        html.window.localStorage['staff_profile'] = jsonEncode(profile);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('営業時間を保存しました'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存エラー: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('営業時間設定'),
        actions: [
          TextButton(
            onPressed: _saveBusinessHours,
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _businessHours.keys.map((day) {
          final dayData = _businessHours[day]!;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dayNames[day]!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: dayData['isOpen'],
                        onChanged: (value) {
                          setState(() {
                            _businessHours[day]!['isOpen'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                  if (dayData['isOpen']) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimePicker(
                            context,
                            '開始時刻',
                            dayData['open'],
                            (time) {
                              setState(() {
                                _businessHours[day]!['open'] = time;
                              });
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('〜'),
                        ),
                        Expanded(
                          child: _buildTimePicker(
                            context,
                            '終了時刻',
                            dayData['close'],
                            (time) {
                              setState(() {
                                _businessHours[day]!['close'] = time;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '定休日',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context, String label, String time, Function(String) onTimeSelected) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(time.split(':')[0]),
            minute: int.parse(time.split(':')[1]),
          ),
        );
        if (picked != null) {
          final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          onTimeSelected(formattedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
