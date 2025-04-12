import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostsProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<QuerySnapshot>? _postsStream;

  PostsProvider() {
    _initializeStream();
  }

  void _initializeStream() {
    final user = _auth.currentUser;
    if (user != null) {
      _postsStream =
          FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .collection('posts')
              .where('creator_id', isEqualTo: user.uid)
              .snapshots();
      notifyListeners();
    }
  }

  Stream<QuerySnapshot>? get postsStream => _postsStream;
}
