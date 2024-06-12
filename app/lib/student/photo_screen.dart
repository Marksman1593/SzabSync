import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:szabsync/widgets/custom_icon.dart';

class PhotoScreen extends StatefulWidget {
  String url;

  PhotoScreen({required this.url});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: CupertinoColors.black,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Hero(
          tag: "photo",
          child: CachedNetworkImage(
            fit: BoxFit.fill,
            imageUrl: widget.url,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                LinearProgressIndicator(
              value: downloadProgress.progress,
            ),
            errorWidget: (context, url, error) => CustomIcon(
              icon: Icon(
                Icons.error,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
