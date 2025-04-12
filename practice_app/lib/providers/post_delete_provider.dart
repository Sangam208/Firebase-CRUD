import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice_app/services/cloudinary_services.dart'; // Import the Cloudinary service

class PostDeleteProvider with ChangeNotifier {
  // Function to delete post from Firestore and Cloudinary
  Future<bool> deletePost(String postId, List<String> mediaUrls) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      // First, delete the media from Cloudinary
      bool cloudinarySuccess = await deleteFromCloudinary(mediaUrls);
      if (!cloudinarySuccess) {
        debugPrint('Failed to delete media from Cloudinary');
        return false;
      }

      // Then, delete the post from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('posts')
          .doc(postId)
          .delete();

      debugPrint('Post and media deleted!');
      notifyListeners(); // Notify listeners if necessary

      return true;
    } catch (e) {
      debugPrint('Failed to delete post: ${e.toString()}');
      return false;
    }
  }
}
