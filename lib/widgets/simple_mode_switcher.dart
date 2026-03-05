import 'package:flutter/material.dart';

/// シンプルなモード切り替えボタン（Androidではサポートなし）
class SimpleModeDropdown extends StatelessWidget {
  const SimpleModeDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_outline,
            size: 16,
            color: Color(0xFF667EEA),
          ),
          SizedBox(width: 6),
          Text(
            'ユーザー',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// スタッフモードドロップダウン（Androidではサポートなし）
class StaffModeDropdown extends StatelessWidget {
  const StaffModeDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.business_center,
            size: 16,
            color: Color(0xFF667EEA),
          ),
          SizedBox(width: 6),
          Text(
            'スタッフ',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
