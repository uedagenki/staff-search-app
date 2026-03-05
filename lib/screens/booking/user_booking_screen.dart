import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';
import '../../models/staff.dart';
import '../../services/booking_service.dart';

class UserBookingScreen extends StatefulWidget {
  final Staff staff;

  const UserBookingScreen({super.key, required this.staff});

  @override
  State<UserBookingScreen> createState() => _UserBookingScreenState();
}

class _UserBookingScreenState extends State<UserBookingScreen> {
  final _bookingService = BookingService();
  final _notesController = TextEditingController();
  
  List<Service> _services = [];
  Service? _selectedService;
  DateTime _selectedDate = DateTime.now();
  TimeSlot? _selectedTimeSlot;
  List<TimeSlot> _availableTimeSlots = [];
  
  bool _isLoading = true;
  bool _isLoadingTimeSlots = false;

  String _userId = 'user_001'; // 実際にはログイン情報から取得
  String _userName = '山田太郎';
  String _userEmail = 'yamada@example.com';
  String _userPhone = '090-1234-5678';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    final services = await _bookingService.getStaffServices(widget.staff.id);
    final activeServices = services.where((s) => s.isActive).toList();

    setState(() {
      _services = activeServices;
      _isLoading = false;
    });
  }

  Future<void> _loadTimeSlots() async {
    if (_selectedService == null) return;

    setState(() {
      _isLoadingTimeSlots = true;
      _selectedTimeSlot = null;
    });

    final timeSlots = await _bookingService.getAvailableTimeSlots(
      widget.staff.id,
      _selectedDate,
      _selectedService!.duration,
    );

    setState(() {
      _availableTimeSlots = timeSlots;
      _isLoadingTimeSlots = false;
    });
  }

  Future<void> _createBooking() async {
    if (_selectedService == null || _selectedTimeSlot == null) return;

    final booking = Booking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      userId: _userId,
      userName: _userName,
      userEmail: _userEmail,
      userPhone: _userPhone,
      staffId: widget.staff.id,
      staffName: widget.staff.name,
      staffAvatar: widget.staff.profileImage,
      serviceId: _selectedService!.id,
      serviceName: _selectedService!.name,
      serviceDescription: _selectedService!.description,
      price: _selectedService!.price,
      dateTime: _selectedTimeSlot!.startTime,
      duration: _selectedService!.duration,
      status: 'pending',
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      createdAt: DateTime.now(),
    );

    final result = await _bookingService.createBooking(booking);

    if (result != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          title: const Text('予約完了'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('予約が完了しました'),
              const SizedBox(height: 16),
              _buildConfirmationRow('スタッフ', widget.staff.name),
              _buildConfirmationRow('サービス', _selectedService!.name),
              _buildConfirmationRow(
                '日時',
                DateFormat('yyyy年M月d日 (E) HH:mm', 'ja')
                    .format(_selectedTimeSlot!.startTime),
              ),
              _buildConfirmationRow('所要時間', '${_selectedService!.duration}分'),
              _buildConfirmationRow('料金', '¥${_selectedService!.price.toStringAsFixed(0)}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('予約に失敗しました。時間帯が既に予約されている可能性があります。'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.staff.name} - 予約'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStaffInfo(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('1. サービスを選択'),
                        const SizedBox(height: 12),
                        _buildServiceSelection(),
                        if (_selectedService != null) ...[
                          const SizedBox(height: 24),
                          _buildSectionTitle('2. 日付を選択'),
                          const SizedBox(height: 12),
                          _buildDateSelection(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('3. 時間を選択'),
                          const SizedBox(height: 12),
                          _buildTimeSlotSelection(),
                        ],
                        if (_selectedTimeSlot != null) ...[
                          const SizedBox(height: 24),
                          _buildSectionTitle('4. 備考 (任意)'),
                          const SizedBox(height: 12),
                          _buildNotesField(),
                          const SizedBox(height: 24),
                          _buildBookingButton(),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '現在予約可能なサービスがありません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: widget.staff.profileImage.isNotEmpty
                  ? NetworkImage(widget.staff.profileImage)
                  : null,
              child: widget.staff.profileImage.isEmpty
                  ? const Icon(Icons.person, size: 30)
                  : null,
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
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.staff.rating.toStringAsFixed(1)} (${widget.staff.reviewCount}件)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Column(
      children: _services.map((service) {
        final isSelected = _selectedService?.id == service.id;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected ? Colors.blue.shade50 : null,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedService = service;
                _selectedTimeSlot = null;
              });
              _loadTimeSlots();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.blue)
                  else
                    const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              '${service.duration}分',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.attach_money, size: 14, color: Colors.green),
                            Text(
                              '¥${service.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy年 M月d日 (E)', 'ja').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                      locale: const Locale('ja', 'JP'),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                        _selectedTimeSlot = null;
                      });
                      _loadTimeSlots();
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('変更'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotSelection() {
    if (_isLoadingTimeSlots) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_availableTimeSlots.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'この日は予約可能な時間がありません',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableTimeSlots.map((slot) {
        final isSelected = _selectedTimeSlot == slot;
        final isAvailable = slot.isAvailable;

        return InkWell(
          onTap: isAvailable
              ? () {
                  setState(() {
                    _selectedTimeSlot = slot;
                  });
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue
                  : isAvailable
                      ? Colors.white
                      : Colors.grey.shade200,
              border: Border.all(
                color: isSelected
                    ? Colors.blue
                    : isAvailable
                        ? Colors.grey.shade300
                        : Colors.grey.shade400,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormat('HH:mm').format(slot.startTime),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : isAvailable
                        ? Colors.black87
                        : Colors.grey.shade500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      decoration: const InputDecoration(
        hintText: '要望や質問があれば入力してください',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildBookingButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _createBooking,
        icon: const Icon(Icons.check),
        label: const Text('この内容で予約する'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
