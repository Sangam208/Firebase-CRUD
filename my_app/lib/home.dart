import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/cloudinary_service.dart';
import 'package:my_app/create_post.dart';
import 'package:my_app/login.dart';
import 'package:my_app/preview_image.dart';
import 'package:my_app/preview_video.dart';
import 'package:my_app/task_card.dart';
// import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // List<StreamSubscription>? _subscriptions;

  Color hexToColor(String hex) {
    // Remove any leading hash (#) if present
    hex = hex.replaceAll('#', '');
    // If the string length is 6, add 'FF' for the alpha value (fully opaque)
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    // Parse the hex string to an integer and return the color
    return Color(int.parse(hex, radix: 16));
  }

  // Firestore update method
  Future<void> _updateContent(
      String updatedTitle, String updatedDescription, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(documentId)
          .update({
        'title': updatedTitle,
        'description': updatedDescription,
      });

      // if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Post updated')));
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update post. Try again.')));
      }
    }
  }

  // Check user's existence
  void _checkUserStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Refresh user to check if they still exist
        await user.reload();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'user-disabled') {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Login()),
            );
          }
        }
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Widget _buildMediaWidget(String url) {
    if (url.contains(".mp4") ||
        url.contains(".mov") ||
        url.contains(".avi") ||
        url.contains(".mkv") ||
        url.contains(".webm")) {
      return Center(
        child: Icon(Icons.videocam,
            size: 40, color: Colors.white), // Placeholder for video
      );
    } else {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(Icons.broken_image, size: 40, color: Colors.white),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 160, 160),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 240, 160, 160),
        title: Text(
          'My Tasks',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: const Color.fromARGB(255, 145, 51, 51)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Builder(builder: (context) {
              return IconButton(
                onPressed: Scaffold.of(context).openEndDrawer,
                icon: Icon(Icons.menu),
              );
            }),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    CreatePost(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                      position: animation.drive(tween), child: child);
                },
              ),
            );
          },
          icon: const Icon(Icons.add),
          iconSize: 32,
          color: const Color.fromARGB(255, 145, 51, 51),
        ),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseAuth.instance.currentUser == null
              ? null
              : FirebaseFirestore.instance
                  .collection("posts")
                  .where('creator',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData) {
              return const Text('No data available');
            }

            return SizedBox(
              width: containerWidth,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Dismissible(
                      key: ValueKey(index),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        final result = await deleteFromCloudinary(
                            snapshot.data!.docs[index]['file_id'],
                            snapshot.data!.docs[index]['extension']);
                        String documentId = snapshot.data!.docs[index].id;
                        if (result) {
                          try {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Post has been deleted.')),
                              );
                            }
                            // await Future.delayed(Duration(milliseconds: 300));
                            await FirebaseFirestore.instance
                                .collection("posts")
                                .doc(documentId)
                                .delete();
                            setState(() {
                              snapshot.data!.docs.removeAt(index);
                            });
                          } catch (e) {
                            debugPrint("Failed to delete post from Firestore");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to delete post. Try again.')),
                            );
                          }
                        } else {
                          debugPrint("Failed to delete file from Cloudinary");
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Task card on the left
                          Expanded(
                            child: TaskCard(
                              title: snapshot.data!.docs[index].data()['title'],
                              description: snapshot.data!.docs[index]
                                  .data()['description'],
                              scheduledDate:
                                  snapshot.data!.docs[index].data()['date'],
                              color: hexToColor(
                                  snapshot.data!.docs[index].data()['color']),
                              documentId: snapshot.data!.docs[index].id,
                              onSave: (updatedTitle, updatedDescription) =>
                                  _updateContent(
                                      updatedTitle,
                                      updatedDescription,
                                      snapshot.data!.docs[index].id),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 5.0),
                            child: snapshot.data!.docs[index]
                                    .data()
                                    .containsKey('url')
                                ? GestureDetector(
                                    onLongPress: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return ListTile(
                                            leading: Icon(Icons.download),
                                            title: Text("Download"),
                                            onTap: () async {
                                              final downloadResult =
                                                  await downloadFromCloudinary(
                                                      snapshot.data!.docs[index]
                                                          ['url'],
                                                      snapshot.data!.docs[index]
                                                          ['file_name']);
                                              if (downloadResult) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            'File Downloaded')));
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            'Download Failed')));
                                              }
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      );
                                    },
                                    onTap: () {
                                      if (["jpg", "jpeg", "png", "gif", "webp"]
                                          .contains(snapshot
                                              .data!.docs[index]['extension']
                                              .toLowerCase())) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PreviewImage(
                                                        imageUrl: snapshot.data!
                                                                .docs[index]
                                                            ['url'])));
                                      } else if ([
                                        "mp4",
                                        "mov",
                                        "avi",
                                        "mkv",
                                        "webm"
                                      ].contains(snapshot
                                          .data!.docs[index]['extension']
                                          .toLowerCase())) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PreviewVideo(
                                                        videoUrl: snapshot.data!
                                                                .docs[index]
                                                            ['url'])));
                                      }
                                    },
                                    child: Container(
                                      width: 120,
                                      height: 105,
                                      color: Colors.grey.shade700,
                                      child: _buildMediaWidget(
                                          snapshot.data!.docs[index]['url']),
                                    ),
                                  )
                                : Center(
                                    child: Text('No file uploaded'),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6, // 60% width
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.redAccent),
                child: Center(
                  child: Text(
                    "Menu",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () async {
                Navigator.pop(context);
                try {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Logging out...')));
                  // _subscriptions?.forEach((sub) => sub.cancel());

                  await FirebaseAuth.instance.signOut();
                  Future.delayed(Duration(seconds: 2), () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Login()), // Your login page
                      );
                    }
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to log out. Try again.')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
