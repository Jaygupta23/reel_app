import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  VideoPlayerWidget({required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isPlaying = true;
  bool _showControlIcon = false;
  Timer? _hideControlIconTimer;
  Duration? _lastPosition;
  double _sliderValue = 0.0;
  double _sliderMax = 1.0;
  Timer? _sliderUpdateTimer;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideoPlayerFuture = _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.network(widget.url);
    await _controller!.initialize();
    setState(() {
      _sliderMax = _controller!.value.duration.inSeconds.toDouble();
      if (_lastPosition != null) {
        _controller!.seekTo(_lastPosition!);
      }
      _controller!.play();
      _startSliderUpdateTimer(); // Start the timer to update slider
    });

    _controller!.addListener(() {
      if (_controller!.value.isInitialized) {
        setState(() {
          _isPlaying = _controller!.value.isPlaying;
          _sliderValue = _controller!.value.position.inSeconds.toDouble();

          if (!_isPlaying) {
            _lastPosition = _controller!.value.position;
          }

          if (_sliderValue >= _sliderMax) {
            _controller!.seekTo(Duration.zero);
            _controller!.play();
          }
        });
      }
    });
  }

  void _startSliderUpdateTimer() {
    _sliderUpdateTimer?.cancel();
    _sliderUpdateTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
      if (_controller != null && _controller!.value.isInitialized) {
        setState(() {
          _sliderValue = _controller!.value.position.inSeconds.toDouble();
          _sliderMax = _controller!.value.duration.inSeconds.toDouble();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _hideControlIconTimer?.cancel();
    _sliderUpdateTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        if (_isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }
        _isPlaying = !_isPlaying;
        _showControlIcon = true;
        _startHideControlIconTimer();
      });
    }
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
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        _sliderValue = value;
        _controller!.seekTo(Duration(seconds: value.toInt()));
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller != null && _controller!.value.isInitialized) {
      if (state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused) {
        _lastPosition = _controller!.value.position;
        _controller!.pause();
      } else if (state == AppLifecycleState.resumed) {
        _controller!.seekTo(_lastPosition ?? Duration.zero);
        _controller!.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Center(
                  child: _controller!.value.isInitialized
                      ? GestureDetector(
                          onTap: _togglePlayPause,
                          child: Column(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: VideoPlayer(_controller!),
                                ),
                              ),
                            ],
                          ),
                        )
                      : CircularProgressIndicator(),
                ),
                if (_showControlIcon)
                  Center(
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 70.0,
                      color: Colors.white,
                    ),
                  ),
                Positioned(
                  bottom: -20,
                  left: -20,
                  right: -20,
                  child: _controller!.value.isInitialized
                      ? SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: Colors
                                .white, // Color of the track when the slider is active
                            inactiveTrackColor: Colors
                                .grey, // Color of the track when the slider is inactive
                            thumbColor: Colors
                                .red, // Color of the thumb (slider handle)
                            overlayColor: Colors.red.withOpacity(
                                0.2), // Color of the overlay when the thumb is pressed
                            thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius:
                                    0), // Customize thumb shape
                            trackHeight: 2.0, // Height of the track
                            // overlayShape: RoundSliderOverlayShape(
                            //     overlayRadius: 25.0),  Customize overlay shape
                          ),
                          child: Slider(
                            value: _sliderValue,
                            min: 0.0,
                            max: _sliderMax,
                            onChanged: _onSliderChanged,
                          ),
                        )
                      : Container(),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
