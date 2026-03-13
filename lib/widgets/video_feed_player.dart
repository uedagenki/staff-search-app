import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoFeedPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isActive;

  const VideoFeedPlayer({
    super.key,
    required this.videoUrl,
    required this.isActive,
  });

  @override
  State<VideoFeedPlayer> createState() => _VideoFeedPlayerState();
}

class _VideoFeedPlayerState extends State<VideoFeedPlayer> {
  late VideoPlayerController _controller;
  bool _showMuteIcon = false;
  bool _isMuted = true;
  Timer? _iconTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          _controller.setLooping(true);
          _controller.setVolume(0);
          if (widget.isActive) _controller.play();
          setState(() {});
        }
      });
  }

  @override
  void didUpdateWidget(VideoFeedPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _iconTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 1);
      _showMuteIcon = true;
    });
    _iconTimer?.cancel();
    _iconTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showMuteIcon = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const SizedBox.expand(child: ColoredBox(color: Colors.black));
    }

    return GestureDetector(
      onTap: _toggleMute,
      child: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          if (_showMuteIcon)
            Center(
              child: Icon(
                _isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
                size: 48,
              ),
            ),
        ],
      ),
    );
  }
}
