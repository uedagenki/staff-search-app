import 'package:flutter/material.dart';

class ContentModerationScreen extends StatelessWidget {
  const ContentModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('コンテンツ管理'),
      ),
      body: const Center(
        child: Text('コンテンツ管理機能は実装中です'),
      ),
    );
  }
}
