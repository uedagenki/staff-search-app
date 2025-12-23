import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/staff.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingCalendarScreen extends StatefulWidget {
  final Staff staff;

  const BookingCalendarScreen({super.key, required this.staff});

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  final BookingService _bookingService = BookingService();
  final TextEditingController _messageController = TextEditingController();

  // 第1〜3希望の選択状態
  DateTime? _firstChoiceDate;
  TimeOfDay? _firstChoiceTime;
  DateTime? _secondChoiceDate;
  TimeOfDay? _secondChoiceTime;
  DateTime? _thirdChoiceDate;
  TimeOfDay? _thirdChoiceTime;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(int choice) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (choice == 1) _firstChoiceDate = picked;
        if (choice == 2) _secondChoiceDate = picked;
        if (choice == 3) _thirdChoiceDate = picked;
      });
    }
  }

  Future<void> _selectTime(int choice) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (choice == 1) _firstChoiceTime = picked;
        if (choice == 2) _secondChoiceTime = picked;
        if (choice == 3) _thirdChoiceTime = picked;
      });
    }
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return '未選択';
    return '${date.year}年${date.month}月${date.day}日 ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submitBooking() async {
    if (_firstChoiceDate == null || _firstChoiceTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('第1希望の日時を選択してください')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // 第2希望（オプション）
    DateTime? secondChoice;
    if (_secondChoiceDate != null && _secondChoiceTime != null) {
      secondChoice = DateTime(
        _secondChoiceDate!.year,
        _secondChoiceDate!.month,
        _secondChoiceDate!.day,
        _secondChoiceTime!.hour,
        _secondChoiceTime!.minute,
      );
    }

    // 第3希望（オプション）
    DateTime? thirdChoice;
    if (_thirdChoiceDate != null && _thirdChoiceTime != null) {
      thirdChoice = DateTime(
        _thirdChoiceDate!.year,
        _thirdChoiceDate!.month,
        _thirdChoiceDate!.day,
        _thirdChoiceTime!.hour,
        _thirdChoiceTime!.minute,
      );
    }

    // 時間スロットのフォーマット
    final timeSlot = '${_firstChoiceTime!.hour}:${_firstChoiceTime!.minute.toString().padLeft(2, '0')}';
    
    final booking = Booking(
      id: DateTime.now().toString(),
      staffId: widget.staff.id,
      staffName: widget.staff.name,
      staffImage: widget.staff.profileImage,
      staffJobTitle: widget.staff.jobTitle,
      date: _firstChoiceDate!,
      timeSlot: timeSlot,
      status: BookingStatus.pending,
      notes: _messageController.text.isNotEmpty ? _messageController.text : null,
      // 第2・第3希望を保存（実際にはBookingモデルの拡張が必要）
    );

    await _bookingService.addBooking(booking);

    if (mounted) {
      Navigator.pop(context);
      
      // 予約確認メッセージ
      String message = '予約リクエストを送信しました\n第1希望: ${_formatDateTime(_firstChoiceDate, _firstChoiceTime)}';
      if (secondChoice != null) {
        message += '\n第2希望: ${_formatDateTime(_secondChoiceDate, _secondChoiceTime)}';
      }
      if (thirdChoice != null) {
        message += '\n第3希望: ${_formatDateTime(_thirdChoiceDate, _thirdChoiceTime)}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予約する'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // スタッフ情報
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: widget.staff.profileImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.staff.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.staff.jobTitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 第1希望
              _buildChoiceSection(
                '第1希望',
                1,
                _firstChoiceDate,
                _firstChoiceTime,
                required: true,
              ),

              const SizedBox(height: 20),

              // 第2希望
              _buildChoiceSection(
                '第2希望（任意）',
                2,
                _secondChoiceDate,
                _secondChoiceTime,
                required: false,
              ),

              const SizedBox(height: 20),

              // 第3希望
              _buildChoiceSection(
                '第3希望（任意）',
                3,
                _thirdChoiceDate,
                _thirdChoiceTime,
                required: false,
              ),

              const SizedBox(height: 24),

              // メッセージ
              const Text(
                'メッセージ（任意）',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '要望や質問を記入してください...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),

              const SizedBox(height: 32),

              // 送信ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '予約リクエストを送信',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceSection(
    String title,
    int choice,
    DateTime? selectedDate,
    TimeOfDay? selectedTime, {
    required bool required,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (required)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  '*',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: OutlinedButton.icon(
                onPressed: () => _selectDate(choice),
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  selectedDate != null
                      ? '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}'
                      : '日付を選択',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: () => _selectTime(choice),
                icon: const Icon(Icons.access_time),
                label: Text(
                  selectedTime != null
                      ? '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}'
                      : '時間',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        if (selectedDate != null && selectedTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _formatDateTime(selectedDate, selectedTime),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
      ],
    );
  }
}
