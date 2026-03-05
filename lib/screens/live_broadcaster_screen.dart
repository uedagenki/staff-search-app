import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/live_stream.dart';
import '../services/live_stream_service.dart';

class LiveBroadcasterScreen extends StatefulWidget {
  const LiveBroadcasterScreen({super.key});

  @override
  State<LiveBroadcasterScreen> createState() => _LiveBroadcasterScreenState();
}

class _LiveBroadcasterScreenState extends State<LiveBroadcasterScreen> {
  final _liveStreamService = LiveStreamService();
  final _titleController = TextEditingController();
  
  RtcEngine? _engine;
  LiveStream? _currentStream;
  bool _isInitialized = false;
  bool _isBroadcasting = false;
  bool _isCameraOn = true;
  bool _isMicOn = true;
  int _viewerCount = 0;
  int _likeCount = 0;
  int _giftAmount = 0;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destroyEngine();
    super.dispose();
  }

  Future<void> _initAgora() async {
    // 権限のリクエスト
    await [Permission.camera, Permission.microphone].request();

    // Agora Engineの初期化
    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: LiveStreamService.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      // イベントハンドラーの設定
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            if (kDebugMode) {
              debugPrint('Channel joined successfully: ${connection.channelId}');
            }
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            setState(() {
              _viewerCount++;
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            setState(() {
              _viewerCount = _viewerCount > 0 ? _viewerCount - 1 : 0;
            });
          },
          onError: (ErrorCodeType err, String msg) {
            if (kDebugMode) {
              debugPrint('Agora error: $err - $msg');
            }
          },
        ),
      );

      // ビデオの有効化
      await _engine!.enableVideo();
      await _engine!.startPreview();

      // クライアントロールを配信者に設定
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize Agora: $e');
      }
    }
  }

  Future<void> _startBroadcast() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('配信タイトルを入力してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // ライブ配信を開始
      final stream = await _liveStreamService.startLiveStream(
        staffId: 'current_staff_id', // 実際のスタッフIDに置き換え
        staffName: '現在のスタッフ名',
        staffProfileImage: 'https://i.pravatar.cc/150?img=10',
        title: _titleController.text.trim(),
        category: '美容・健康',
      );

      // Agoraチャンネルに参加
      await _engine!.joinChannel(
        token: stream.token,
        channelId: stream.channelName,
        uid: 0,
        options: const ChannelMediaOptions(),
      );

      setState(() {
        _currentStream = stream;
        _isBroadcasting = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('配信を開始しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to start broadcast: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('配信開始に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopBroadcast() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配信終了'),
        content: const Text('配信を終了しますか?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('終了'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _engine!.leaveChannel();
      
      if (_currentStream != null) {
        await _liveStreamService.stopLiveStream(_currentStream!.id);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to stop broadcast: $e');
      }
    }
  }

  Future<void> _toggleCamera() async {
    try {
      await _engine!.enableLocalVideo(!_isCameraOn);
      setState(() {
        _isCameraOn = !_isCameraOn;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to toggle camera: $e');
      }
    }
  }

  Future<void> _toggleMicrophone() async {
    try {
      await _engine!.enableLocalAudio(!_isMicOn);
      setState(() {
        _isMicOn = !_isMicOn;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to toggle microphone: $e');
      }
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _engine!.switchCamera();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to switch camera: $e');
      }
    }
  }

  Future<void> _destroyEngine() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // カメラプレビュー
          if (_isCameraOn)
            SizedBox.expand(
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine!,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: Icon(
                  Icons.videocam_off,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),

          // オーバーレイUI
          SafeArea(
            child: Column(
              children: [
                // ヘッダー
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // LIVE バッジ
                      if (_isBroadcasting)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 12),
                      // 視聴者数
                      if (_isBroadcasting)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.remove_red_eye,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$_viewerCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      // 閉じるボタン
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _isBroadcasting ? _stopBroadcast : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 配信前の入力フォーム
                if (!_isBroadcasting)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '配信タイトルを入力',
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.black45,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          maxLength: 50,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _startBroadcast,
                            icon: const Icon(Icons.video_call, size: 28),
                            label: const Text(
                              '配信開始',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // コントロールボタン
                if (_isBroadcasting)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // カメラ切替
                        _buildControlButton(
                          icon: Icons.flip_camera_ios,
                          onPressed: _switchCamera,
                        ),
                        // カメラON/OFF
                        _buildControlButton(
                          icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                          onPressed: _toggleCamera,
                          isActive: _isCameraOn,
                        ),
                        // マイクON/OFF
                        _buildControlButton(
                          icon: _isMicOn ? Icons.mic : Icons.mic_off,
                          onPressed: _toggleMicrophone,
                          isActive: _isMicOn,
                        ),
                        // 終了ボタン
                        _buildControlButton(
                          icon: Icons.call_end,
                          onPressed: _stopBroadcast,
                          backgroundColor: Colors.red,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = true,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isActive ? Colors.white24 : Colors.red.withValues(alpha: 0.5)),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        iconSize: 28,
        onPressed: onPressed,
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
