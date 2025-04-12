import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PreviewVideo extends StatefulWidget {
  final String videoUrl;
  const PreviewVideo({super.key, required this.videoUrl});

  @override
  State<PreviewVideo> createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {}); // Ensure the UI updates once the video is ready
      }).catchError((error) {
        debugPrint('Error initializing video: $error');
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Preview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(
                color: Colors.white,
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child:
            Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}
