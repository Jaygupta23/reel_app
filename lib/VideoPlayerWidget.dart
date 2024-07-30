import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  VideoPlayerWidget({required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  bool _showControlIcon = false;
  Timer? _hideControlIconTimer;
  Duration? _lastPosition;
  double _sliderValue = 0.0;
  double _sliderMax = 1.0;
  Timer? _sliderUpdateTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {
          _sliderMax = _controller.value.duration.inSeconds.toDouble();
          if (_lastPosition != null) {
            _controller.seekTo(_lastPosition!);
          }
          _controller.play();
          _startSliderUpdateTimer(); // Start the timer to update slider
        });
      });

    _controller.addListener(() {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
        if (!_isPlaying) {
          _lastPosition = _controller.value.position;
        }
        if (_sliderValue >= _sliderMax) {
          _controller.seekTo(Duration.zero);
          _controller.play();
        }
      });
    });
  }

  void _startSliderUpdateTimer() {
    _sliderUpdateTimer?.cancel();
    _sliderUpdateTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (_controller.value.isInitialized) {
        setState(() {
          _sliderValue = _controller.value.position.inSeconds.toDouble();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _hideControlIconTimer?.cancel();
    _sliderUpdateTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
        _showControlIcon = true;
        _startHideControlIconTimer();
      } else {
        _controller.play();
        _showControlIcon = true;
        _startHideControlIconTimer();
      }
    });
  }

  void _startHideControlIconTimer() {
    _hideControlIconTimer?.cancel();
    _hideControlIconTimer = Timer(Duration(seconds: 1), () {
      setState(() {
        _showControlIcon = false;
      });
    });
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;
      _controller.seekTo(Duration(seconds: value.toInt()));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _lastPosition = _controller.value.position;
      _controller.pause();
    }
    if (state == AppLifecycleState.resumed) {
      _controller.seekTo(_lastPosition ?? Duration.zero);
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? GestureDetector(
              onTap: _togglePlayPause,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: VideoPlayer(_controller),
                  ),
                  if (_showControlIcon)
                    Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 70.0,
                      color: Colors.white,
                    ),
                ],
              ),
            )
                : CircularProgressIndicator(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              child: Slider(
                value: _sliderValue,
                min: 0.0,
                max: _sliderMax,
                onChanged: _onSliderChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
