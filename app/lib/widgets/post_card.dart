import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/post.model.dart';
import 'package:szabsync/student/photo_screen.dart';
import 'package:szabsync/student/video_player.dart';
import 'package:szabsync/widgets/custom_icon.dart';
import 'package:video_player/video_player.dart';

class PostCard extends StatelessWidget {
  final Post post;
  bool isLiked;
  bool isAdmin;
  final VoidCallback onLike;

  PostCard({
    required this.post,
    required this.onLike,
    required this.isLiked,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        100,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.secondaryDark,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 12,
                      ),
                      child: Text(
                        post.by.split(" ").map((e) => e[0]).join(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    post.by,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isAdmin) Spacer(),
                  if (isAdmin)
                    GestureDetector(
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection("posts")
                            .doc(post.id)
                            .delete();
                      },
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    )
                ],
              ),
              subtitle: post.textContent != ""
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.textContent),
                        ],
                      ),
                    )
                  : null,
            ),
            if (post.attachments.length > 0)
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.attachments.length,
                  itemBuilder: (context, index) {
                    VideoPlayerController? controller;
                    if (post.attachments[index].type == "video") {
                      controller = VideoPlayerController.networkUrl(
                        Uri.parse(
                          post.attachments[index].contentURL,
                        ),
                      );

                      controller.initialize();
                      controller.pause();
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: post.attachments[index].type == "video"
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoScreen(
                                          url: post
                                              .attachments[index].contentURL,
                                        ),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    height: 200,
                                    width: post.attachments.length > 1
                                        ? 200
                                        : MediaQuery.of(context).size.width,
                                    child: Stack(
                                      children: [
                                        Hero(
                                          tag: "video",
                                          child: VideoPlayer(
                                            controller!,
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.secondary,
                                                  AppColors.secondaryDark,
                                                ],
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PhotoScreen(
                                          url: post
                                              .attachments[index].contentURL,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: "photo",
                                    child: Center(
                                      child: CachedNetworkImage(
                                        height: 200,
                                        width: post.attachments.length > 1
                                            ? 200
                                            : 300,
                                        fit: BoxFit.cover,
                                        imageUrl:
                                            post.attachments[index].contentURL,
                                        progressIndicatorBuilder:
                                            (context, url, downloadProgress) =>
                                                LinearProgressIndicator(
                                          value: downloadProgress.progress,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            CustomIcon(
                                          icon: Icon(
                                            Icons.play_circle_fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: onLike,
                    child: Icon(
                      isLiked
                          ? CupertinoIcons.hand_thumbsup_fill
                          : CupertinoIcons.hand_thumbsup,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                      '${post.likesCount.length} Likes | ${post.attachments.length.toString()} Attachment(s)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
