import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:practice_app/widgets/create_post.dart';
import 'package:practice_app/widgets/posts.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final postsSnapshot = Provider.of<QuerySnapshot?>(context);

    return CustomScrollView(
      slivers: [
        // **SliverAppBar remains fixed**
        SliverAppBar(
          automaticallyImplyLeading: false,
          expandedHeight: 70,
          pinned: false,
          floating: true,
          title: Text(
            "Posty",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Color.fromARGB(255, 255, 190, 7),
              fontSize: 35,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CreatePost(),
                );
              },
              icon: Icon(Icons.add_box_outlined, size: 28),
            ),
            IconButton(onPressed: () {}, icon: Icon(FontAwesomeIcons.heart)),
            IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: Icon(Icons.menu),
            ),
          ],
        ),

        // **Handle loading and empty states**
        if (postsSnapshot == null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (postsSnapshot.docs.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'No posts to show',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.amber),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              var post =
                  postsSnapshot.docs[index].data() as Map<String, dynamic>? ??
                  {};
              var postFiles = post['files'] ?? [];
              List<String> mediaUrls = [];

              if (postFiles is List) {
                mediaUrls =
                    postFiles.map((file) => file['url'] as String).toList();
              }

              return Posts(
                location: post['location'] ?? 'Unknown Location',
                caption: post['caption'] ?? '',
                postId: post['post_id'] ?? '',
                mediaUrls: mediaUrls,
              );
            }, childCount: postsSnapshot.docs.length),
          ),
      ],
    );
  }
}
