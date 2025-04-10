import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice_app/services/cloudinary_services.dart';
import 'package:uuid/uuid.dart';

class DbServices {
  // creating user
  Future<String> createUserWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
            'username': username,
            'email': email,
            'created_at': FieldValue.serverTimestamp(),
          });
      await FirebaseAuth.instance.signOut();

      debugPrint('User Created: ${userCredential.user}');
      return 'Sign up successful!';
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Signup failed. Please try again.";

      if (e.code == 'email-already-in-use') {
        errorMessage = "User already exists";
      } else if (e.code == 'network-request-failed') {
        errorMessage = "Network error, please try again later.";
      } else {
        debugPrint('Error Code: ${e.code}');
        debugPrint('Error Message: ${e.message}');
      }
      return errorMessage;
    } catch (e) {
      debugPrint("$e");
      return 'Unexpected error occured!';
    }
  }

  // User login
  Future<String> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      debugPrint('Logged in\nUser: ${userCredential.user}');
      return 'Log in successful!';
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Log in failed. Please try again.';
      if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid credentials';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many failed attempts. Try again later.';
      } else if (e.code == "network-request-failed") {
        errorMessage = 'Please check your internet connection.';
      }
      return errorMessage;
    } catch (e) {
      debugPrint(e.toString());
      return 'Unexpected error occured';
    }
  }

  // Logout Method
  Future<String> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return 'Logged out';
    } catch (e) {
      debugPrint(e.toString());
      return 'Failed to log out. Please try again.';
    }
  }

  // Upload data to Firebase Firestore Database
  Future<bool> uploadPostToDb(
    String? caption,
    String? location,
    FilePickerResult? files,
  ) async {
    try {
      final id = const Uuid().v8();
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      List<Map<String, dynamic>> uploadedFiles = [];

      // Upload each file to Cloudinary and store metadata
      for (var file in files!.files) {
        var uploadResult = await uploadToCloudinary(
          FilePickerResult([file]),
          id,
        );
        if (uploadResult != null) {
          uploadedFiles.addAll(uploadResult);
        }
      }

      if (uploadedFiles.isEmpty) {
        return false;
      }

      DocumentSnapshot userDocs =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(currentUser.uid)
              .get();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .collection("posts")
          .doc(id)
          .set({
            "username": userDocs.exists ? userDocs.get('username') : '',
            "caption": caption,
            "location": location,
            "creator_id": currentUser.uid,
            "post_id": id,
            "files": uploadedFiles,
          });

      return true;
    } catch (e) {
      debugPrint('Error uploading post: $e');
      return false;
    }
  }
}
