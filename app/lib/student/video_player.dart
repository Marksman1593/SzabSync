import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  String url;

  VideoScreen({required this.url});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(
      Uri.parse(
        widget.url,
      ),
    );

    controller!.initialize();
    controller!.play();
    controller!.setLooping(true);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: controller == null
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Hero(
              tag: "video",
              child: VideoPlayer(
                controller!,
              ),
            ),
    );
  }
}
