import 'package:flutter/material.dart';
import '../models/job_category.dart';
import '../services/staff_service.dart';

class JobCategoryDropdown extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;

  const JobCategoryDropdown({
    super.key,
    this.initialValue,
    this.onChanged,
    this.validator,
  });

  @override
  State<JobCategoryDropdown> createState() => _JobCategoryDropdownState();
}

class _JobCategoryDropdownState extends State<JobCategoryDropdown> {
  List<JobCategory>? _categories;
  bool _isLoading = true;
  String? _selectedKey;

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.initialValue;
    _load();
  }

  Future<void> _load() async {
    try {
      final cats = await StaffService.instance.getJobCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_categories == null) {
      return TextButton(onPressed: _load, child: const Text('Retry'));
    }

    return DropdownButtonFormField<String>(
      value: _selectedKey,
      decoration: InputDecoration(
        labelText: 'Job Category',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _categories!
          .map((cat) => DropdownMenuItem<String>(
                value: cat.key,
                child: Text('${cat.icon} ${cat.labelJa}'),
              ))
          .toList(),
      onChanged: (value) {
        setState(() => _selectedKey = value);
        widget.onChanged?.call(value);
      },
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a job category.';
            }
            return null;
          },
    );
  }
}
