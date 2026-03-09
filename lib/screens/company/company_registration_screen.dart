import 'package:flutter/material.dart';
import '../../models/company.dart';

/// 企業編集画面（既存企業の編集用）
class CompanyRegistrationScreen extends StatefulWidget {
  final Company? company;
  
  const CompanyRegistrationScreen({
    super.key,
    this.company,
  });

  @override
  State<CompanyRegistrationScreen> createState() => _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState extends State<CompanyRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('企業情報編集'),
      ),
      body: const Center(
        child: Text('企業編集画面（実装予定）'),
      ),
    );
  }
}
