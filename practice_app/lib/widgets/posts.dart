import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:practice_app/providers/user_provider.dart';
import 'package:practice_app/providers/post_delete_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class Posts extends StatefulWidget {
  final String? location;
  final String? caption;
  final String postId;
  final List<String> mediaUrls;

  const Posts({
    super.key,
    required this.location,
    required this.caption,
    required this.postId,
    required this.mediaUrls,
  });

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  bool isLiked = false;
  User? currentUser = FirebaseAuth.instance.currentUser;

  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    super.dispose();
  }

  VideoPlayerController _getVideoController(String videoUrl) {
    if (!_videoControllers.containsKey(videoUrl)) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      controller
          .initialize()
          .then((_) {
            setState(() {
              _videoControllers[videoUrl] = controller;
              controller.play();
            });
          })
          .catchError((error) {
            debugPrint("Video initialization error: $error");
          });
      controller.setLooping(true);
      _videoControllers[videoUrl] = controller;
    }
    return _videoControllers[videoUrl]!;
  }

  Widget _buildMedia(String mediaUrl) {
    if (mediaUrl.endsWith('.mp4') || mediaUrl.endsWith('.mov')) {
      return _buildVideo(mediaUrl);
    } else {
      return CachedNetworkImage(
        imageUrl: mediaUrl,
        placeholder:
            (context, url) => Center(child: const CircularProgressIndicator()),
        cacheManager: CacheManager(
          Config(
            'customCacheKey',
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 100,
          ),
        ),
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildVideo(String videoUrl) {
    final controller = _getVideoController(videoUrl);
    return GestureDetector(
      onTap: () {
        setState(() {
          controller.value.isPlaying ? controller.pause() : controller.play();
        });
      },
      child:
          controller.value.isInitialized
              ? Container(
                color:
                    Colors
                        .black, // Ensures black bars appear instead of transparent background
                child: FittedBox(
                  fit:
                      BoxFit
                          .contain, // Maintains original aspect ratio and adds black bars
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return Consumer<PostDeleteProvider>(
            builder: (context, postProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Image.asset('assets/images/app_logo.png'),
                    ),
                    title: Padding(
                      padding: EdgeInsets.only(
                        top:
                            (widget.location == null ||
                                    widget.location!.isEmpty)
                                ? 10.0
                                : 0,
                      ),
                      child: Text(
                        userProvider.username,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    subtitle:
                        widget.location != null
                            ? Text(
                              widget.location ?? '',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                            : const SizedBox.shrink(),
                    trailing: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                'Do you want to delete this post?',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    Fluttertoast.showToast(
                                      msg: 'Deleting Post...',
                                      toastLength: Toast.LENGTH_SHORT,
                                      backgroundColor: Colors.white,
                                      textColor: Colors.black,
                                      gravity: ToastGravity.BOTTOM,
                                      fontSize: 16.0,
                                    );
                                    Future.delayed(Duration(microseconds: 500));

                                    bool success = await postProvider
                                        .deletePost(
                                          widget.postId,
                                          widget.mediaUrls,
                                        );

                                    String msg =
                                        success
                                            ? 'Post deleted'
                                            : 'Failed to delete post';
                                    Fluttertoast.showToast(
                                      msg: msg,
                                      toastLength: Toast.LENGTH_SHORT,
                                      backgroundColor: Colors.white,
                                      textColor: Colors.black,
                                      gravity: ToastGravity.BOTTOM,
                                      fontSize: 16.0,
                                    );
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 5 / 4,
                    width: double.infinity,
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.mediaUrls.length,
                      itemBuilder: (context, index) {
                        return AspectRatio(
                          aspectRatio: 4 / 5,
                          child: _buildMedia(widget.mediaUrls[index]),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                        },
                        icon:
                            !isLiked
                                ? Icon(FontAwesomeIcons.heart)
                                : Icon(FontAwesomeIcons.solidHeart),
                      ),
                      IconButton(
                        icon: Icon(FontAwesomeIcons.comment),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(FontAwesomeIcons.share),
                        onPressed: () {},
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(FontAwesomeIcons.bookmark),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      '@${userProvider.username}  ${widget.caption}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Add a comment',
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const Divider(thickness: 1),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
