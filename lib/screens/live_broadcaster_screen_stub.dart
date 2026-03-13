// SCREEN: Live Broadcaster Screen (Web Stub) | LIVE-03
import 'package:flutter/material.dart';
import '../models/live_stream.dart';

// Webプラットフォーム用のスタブ
class LiveBroadcasterScreen extends StatelessWidget {
  const LiveBroadcasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    debugPrint('📱 SCREEN: Live Broadcaster Screen (Web Stub) | LIVE-03'); // debug only

    return Scaffold(
      appBar: AppBar(title: const Text('ライブ配信')),
      body: const Center(
        child: Text('ライブ配信機能はモバイルアプリでのみ利用できます'),
      ),
    );
  }
}
