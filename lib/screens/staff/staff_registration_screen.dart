// SCREEN: Staff Registration Screen | AUTH-05
import '../../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/staff_provider.dart';
import '../../services/api_client.dart';
import '../../widgets/job_category_dropdown.dart';

class StaffRegistrationScreen extends StatefulWidget {
  const StaffRegistrationScreen({super.key});

  @override
  State<StaffRegistrationScreen> createState() => _StaffRegistrationScreenState();
}

class _StaffRegistrationScreenState extends State<StaffRegistrationScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Staff Registration Screen | AUTH-05';

  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  String? _selectedJobCategory;
  bool _acceptBookings = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _jobTitleController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedJobCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a job category.'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await context.read<StaffProvider>().createProfile({
        'job_title': _jobTitleController.text.trim(),
        'job_category': _selectedJobCategory!,
        if (_locationController.text.trim().isNotEmpty) 'location': _locationController.text.trim(),
        if (_bioController.text.trim().isNotEmpty) 'bio': _bioController.text.trim(),
        'accept_bookings': _acceptBookings,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff profile created successfully.'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } on UnauthorizedException {
      if (!mounted) return;
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スタッフ登録'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.work_outline, color: Colors.white, size: 40),
                      SizedBox(height: 12),
                      Text(
                        'スタッフとして活躍しませんか？',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'あなたのスキルと経験を活かして、お客様にサービスを提供しましょう。',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  '基本情報',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Job Title
                TextFormField(
                  controller: _jobTitleController,
                  maxLength: 100,
                  decoration: InputDecoration(
                    labelText: 'Job Title',
                    hintText: 'e.g. Hair Stylist, Nail Artist',
                    prefixIcon: const Icon(Icons.work),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Job title is required.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Job Category
                JobCategoryDropdown(
                  onChanged: (key) {
                    setState(() {
                      _selectedJobCategory = key;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Location (optional)
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location (optional)',
                    hintText: 'e.g. Tokyo, Shibuya',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 16),

                // Bio (optional)
                TextFormField(
                  controller: _bioController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Bio (optional)',
                    hintText: 'Tell customers about your skills and experience...',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 16),

                // Accept Bookings toggle
                SwitchListTile(
                  title: const Text('Accept Bookings'),
                  subtitle: const Text('Allow customers to book you'),
                  value: _acceptBookings,
                  onChanged: (val) => setState(() => _acceptBookings = val),
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'スタッフとして登録する',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            '注意事項',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• スタッフとして登録すると、お客様からの予約を受け付けることができます\n'
                        '• プロフィールは後から編集可能です\n'
                        '• サービス内容や料金は追加で設定できます',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
