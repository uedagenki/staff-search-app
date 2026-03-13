import 'package:flutter/material.dart';
import '../models/job_category.dart';
import '../services/staff_service.dart';

class JobCategoryChips extends StatefulWidget {
  final String? selectedKey;
  final ValueChanged<String?>? onSelected;

  const JobCategoryChips({
    super.key,
    this.selectedKey,
    this.onSelected,
  });

  @override
  State<JobCategoryChips> createState() => _JobCategoryChipsState();
}

class _JobCategoryChipsState extends State<JobCategoryChips> {
  List<JobCategory>? _categories;
  String? _selectedKey;

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.selectedKey;
    _load();
  }

  Future<void> _load() async {
    try {
      final cats = await StaffService.instance.getJobCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_categories == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildChip(null, 'すべて'),
          ..._categories!.map((cat) => _buildChip(cat.key, '${cat.icon} ${cat.labelJa}')),
        ],
      ),
    );
  }

  Widget _buildChip(String? key, String label) {
    final isSelected = _selectedKey == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
        ),
        onSelected: (_) {
          setState(() => _selectedKey = key);
          widget.onSelected?.call(key);
        },
      ),
    );
  }
}
