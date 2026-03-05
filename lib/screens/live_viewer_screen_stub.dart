import 'package:flutter/material.dart';
import '../models/live_stream.dart';

// Webプラットフォーム用のスタブ
class LiveViewerScreen extends StatelessWidget {
  final LiveStream liveStream;

  const LiveViewerScreen({
    super.key,
    required this.liveStream,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ライブ視聴')),
      body: const Center(
        child: Text('ライブ配信機能はモバイルアプリでのみ利用できます'),
      ),
    );
  }
}
